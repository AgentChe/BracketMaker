//
//  TeamsViewModel.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 24.08.2025.
//

import RxSwift
import RxCocoa

final class TeamsViewModel {
    enum Action {
        case openPaygate
        case confirmDelete(String)
    }
    
    private lazy var teamManager = TeamManager()
}

// MARK: Public
extension TeamsViewModel {
    struct Input {
        let didTapPaygate: Signal<Void>
        let didDeleteTeam: Signal<String>
        let didConfirmDeleteTeam: Signal<String>
        let didCreateTeam: Signal<String>
        let didAttemptCreateWhenLockPaygate: Signal<Void>
    }
    
    struct Output {
        let action: Driver<Action>
        let activeSubscription: Driver<Bool>
        let elements: Driver<[TeamTableElement]>
        let canCreateTeam: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        let teams = makeTeams(
            didCreateTeam: input.didCreateTeam,
            didConfirmDeleteTeam: input.didConfirmDeleteTeam
        )
        let activeSubscription = makeActiveSubscription()
        
        return Output(
            action: makeAction(
                didTapPaygate: input.didTapPaygate,
                didDeleteTeam: input.didDeleteTeam,
                didAttemptCreateWhenLockPaygate: input.didAttemptCreateWhenLockPaygate
            ),
            activeSubscription: activeSubscription,
            elements: makeElements(teams: teams),
            canCreateTeam: makeCanCreateTeam(
                activeSubscription: activeSubscription,
                teams: teams
            )
        )
    }
}

// MARK: Private
private extension TeamsViewModel {
    func makeCanCreateTeam(
        activeSubscription: Driver<Bool>,
        teams: Driver<[Team]>
    ) -> Driver<Bool> {
        Driver
            .combineLatest(activeSubscription, teams)
            .map { activeSubscription, teams -> Bool in
                if activeSubscription {
                    return true
                }
                
                return teams.count < 3
            }
    }
    
    func makeAction(
        didTapPaygate: Signal<Void>,
        didDeleteTeam: Signal<String>,
        didAttemptCreateWhenLockPaygate: Signal<Void>
    ) -> Driver<Action> {
        let openPaygate = Signal
            .merge(didTapPaygate, didAttemptCreateWhenLockPaygate)
            .map { Action.openPaygate }
            .asDriver(onErrorDriveWith: .never())
        
        let confirmDelete = didDeleteTeam
            .map { Action.confirmDelete($0) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(openPaygate, confirmDelete)
    }
    
    func makeElements(teams: Driver<[Team]>) -> Driver<[TeamTableElement]> {
        teams
            .map { teams -> [TeamTableElement] in
                guard !teams.isEmpty else {
                    return []
                }
                
                return [.title] + teams.map { .team($0) }
            }
    }
    
    func makeTeams(
        didCreateTeam: Signal<String>,
        didConfirmDeleteTeam: Signal<String>
    ) -> Driver<[Team]> {
        enum Action {
            case initial([Team])
            case created(Team)
            case deleted(String)
        }
        
        let initial = teamManager
            .fetchTeams()
            .asDriver(onErrorJustReturn: [])
        
        return initial
            .flatMapLatest { initialTeams -> Driver<[Team]> in
                let created = didCreateTeam
                    .flatMapLatest { [weak self] name -> Driver<Action> in
                        guard let self else { return .never() }
                        
                        return teamManager
                            .createTeam(name: name)
                            .asDriver(onErrorDriveWith: .never())
                            .map { Action.created($0) }
                    }
                
                let deleted = didConfirmDeleteTeam
                    .flatMapLatest { [weak self] id -> Driver<Action> in
                        guard let self else { return .never() }
                        
                        return teamManager
                            .delete(teamId: id)
                            .asDriver(onErrorDriveWith: .never())
                            .map { Action.deleted($0) }
                    }
                
                return Driver
                    .merge(created, deleted)
                    .startWith(.initial(initialTeams))
                    .scan(initialTeams) { teams, action -> [Team] in
                        switch action {
                        case .initial(let teams):
                            return teams
                        case .created(let team):
                            var result = teams
                            result.append(team)
                            return result
                        case .deleted(let id):
                            var result = teams
                            result.removeAll(where: { $0.id == id })
                            return result
                        }
                    }
                    .map { teams -> [Team] in
                        teams.sorted(by: { $0.name < $1.name })
                    }
            }
    }
    
    func makeActiveSubscription() -> Driver<Bool> {
        PurchaseValidationObserver.shared
            .didValidatedWithActiveSubscription
            .map { SessionManager().hasActiveSubscriptions() }
            .startWith(SessionManager().hasActiveSubscriptions())
            .asDriver(onErrorJustReturn: false)
    }
}
