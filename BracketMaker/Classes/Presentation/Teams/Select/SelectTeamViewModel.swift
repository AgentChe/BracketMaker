//
//  SelectTeamViewModel.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 10.09.2025.
//

import RxSwift
import RxCocoa

final class SelectTeamViewModel {
    enum Action {
        case openPaygate
        case selected(Team)
    }
    
    private lazy var teamManager = TeamManager()
}

// MARK: Public
extension SelectTeamViewModel {
    struct Input {
        let didCreateTeam: Signal<String>
        let didAttemptCreateWhenLockPaygate: Signal<Void>
        let didSelectTeam: Signal<Team>
    }
    
    struct Output {
        let action: Driver<Action>
        let elements: Driver<[TeamTableElement]>
        let canCreateTeam: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        let teams = makeTeams(didCreateTeam: input.didCreateTeam)
        
        return Output(
            action: makeAction(
                didAttemptCreateWhenLockPaygate: input.didAttemptCreateWhenLockPaygate,
                didSelectTeam: input.didSelectTeam
            ),
            elements: makeElements(teams: teams),
            canCreateTeam: makeCanCreateTeam(
                activeSubscription:  makeActiveSubscription(),
                teams: teams
            )
        )
    }
}

// MARK: Private
private extension SelectTeamViewModel {
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
        didAttemptCreateWhenLockPaygate: Signal<Void>,
        didSelectTeam: Signal<Team>
    ) -> Driver<Action> {
        let openPaygate = didAttemptCreateWhenLockPaygate
            .map { Action.openPaygate }
            .asDriver(onErrorDriveWith: .never())
        
        let selectedTeam = didSelectTeam
            .map { Action.selected($0) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(openPaygate, selectedTeam)
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
    
    func makeTeams(didCreateTeam: Signal<String>) -> Driver<[Team]> {
        enum Action {
            case initial([Team])
            case created(Team)
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
                
                return created
                    .startWith(.initial(initialTeams))
                    .scan(initialTeams) { teams, action -> [Team] in
                        switch action {
                        case .initial(let teams):
                            return teams
                        case .created(let team):
                            var result = teams
                            result.append(team)
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
