//
//  HomeViewModel.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 05.09.2025.
//

import RxSwift
import RxCocoa

final class HomeViewModel {
    enum Action {
        case openPaygate
    }
    
    private lazy var tournamentManager = TournamentManager()
    private lazy var teamManager = TeamManager()
}

// MARK: Public
extension HomeViewModel {
    struct Input {
        let didTapPaygate: Signal<Void>
        let didTapPreset: Signal<TournamentPreset>
        let didTapAddFirstBracket: Signal<Void>
        let didChangeFilter: Signal<HomeFilterItemButton.Filter>
    }
    
    struct Output {
        let elements: Driver<[HomeTableElement]>
        let action: Driver<Action>
        let activeSubscription: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        let teams = makeTeams()
        let currentFilter = makeCurrentFilter(didChangeFilter: input.didChangeFilter)
        let singleEliminations = makeSingleEliminations()
        let singleEliminationsResults = makeSingleEliminationsResults(singleEliminations: singleEliminations)
        let singleEliminationsElements = makeSingleEliminationsElements(
            singleEliminations: singleEliminations,
            singleEliminationsResults: singleEliminationsResults,
            teams: teams
        )
        let bracketsElements = makeBracketsElements(
            currentFilter: currentFilter,
            singleEliminationsElements: singleEliminationsElements
        )
        
        return Output(
            elements: makeElements(
                currentFilter: currentFilter,
                bracketsElements: bracketsElements
            ),
            action: makeAction(didTapPaygate: input.didTapPaygate),
            activeSubscription: makeActiveSubscription()
        )
    }
}

// MARK: Private
private extension HomeViewModel {
    func makeElements(
        currentFilter: Driver<HomeFilterItemButton.Filter>,
        bracketsElements: Driver<[HomeTableBracketElement]>
    ) -> Driver<[HomeTableElement]> {
        Driver
            .combineLatest(currentFilter, bracketsElements) { currentFilter, bracketsElements -> [HomeTableElement] in
                var elements: [HomeTableElement] = [.presets, .title]
                
                if bracketsElements.isEmpty {
                    elements.append(contentsOf: [.addFirstBracket, .demo])
                } else {
                    elements.append(.filter(currentFilter))
                    
                    let bracketsFiltered: [HomeTableElement] = {
                        bracketsElements
                            .filter { element -> Bool in
                                switch currentFilter {
                                case .all:
                                    return true
                                case .inProgress:
                                    return element.state.isInProgress
                                case .completed:
                                    return element.state.isCompleted
                                }
                            }
                            .map { .bracket($0) }
                    }()
                    elements.append(contentsOf: bracketsFiltered)
                }
                
                return elements
            }
    }
    
    // TODO: объединить с double eliminations и round robin
    func makeBracketsElements(
        currentFilter: Driver<HomeFilterItemButton.Filter>,
        singleEliminationsElements: Driver<[HomeTableBracketElement]>
    ) -> Driver<[HomeTableBracketElement]> {
        singleEliminationsElements
            .map { elements -> [HomeTableBracketElement] in
                elements.sorted(by: { $0.bracket.createdAt < $1.bracket.createdAt})
            }
    }
    
    func makeSingleEliminationsElements(
        singleEliminations: Driver<[SingleElimination]>,
        singleEliminationsResults: Driver<[SingleEliminationResult]>,
        teams: Driver<[Team]>
    ) -> Driver<[HomeTableBracketElement]> {
        Driver
            .combineLatest(singleEliminations, singleEliminationsResults)
            .withLatestFrom(teams) { ($0.0, $0.1, $1) }
            .map { singleEliminations, singleEliminationsResults, teams -> [HomeTableBracketElement] in
                singleEliminations.map { singleElimination -> HomeTableBracketElement in
                    let state: HomeTableBracketElement.State = {
                        guard let result = singleEliminationsResults.first(where: { $0.singleEliminationId == singleElimination.id }) else {
                            return .inProgress
                        }
                        
                        let winner: Team = {
                            if let winner = teams.first(where: { $0.id == result.winner }) {
                                return winner
                            }
                            
                            return Team.unknownTeam()
                        }()
                        
                        return .completed(winner)
                    }()
                    
                    return HomeTableBracketElement(
                        state: state,
                        bracket: .singleElimination(singleElimination)
                    )
                }
            }
    }
    
    func makeCurrentFilter(didChangeFilter: Signal<HomeFilterItemButton.Filter>) -> Driver<HomeFilterItemButton.Filter> {
        didChangeFilter
            .startWith(.all)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeAction(
        didTapPaygate: Signal<Void>
    ) -> Driver<Action> {
        let openPaygate = didTapPaygate
            .map { Action.openPaygate }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(openPaygate)
    }
    
    func makeActiveSubscription() -> Driver<Bool> {
        PurchaseValidationObserver.shared
            .didValidatedWithActiveSubscription
            .map { SessionManager().hasActiveSubscriptions() }
            .startWith(SessionManager().hasActiveSubscriptions())
            .asDriver(onErrorJustReturn: false)
    }
    
    func makeSingleEliminations() -> Driver<[SingleElimination]> {
        let initial = tournamentManager
            .fetchSingleEliminations()
            .asDriver(onErrorJustReturn: [])
        
        return initial
            .flatMapLatest { initial -> Driver<[SingleElimination]> in
                TournamentMediator.shared
                    .didCreatedSingleElimination
                    .scan(initial) { array, new -> [SingleElimination] in
                        array + [new]
                    }
                    .startWith(initial)
                    .asDriver(onErrorJustReturn: [])
            }
    }
    
    func makeSingleEliminationsResults(singleEliminations: Driver<[SingleElimination]>) -> Driver<[SingleEliminationResult]> {
        singleEliminations
            .flatMapLatest { [weak self] singleEliminations -> Driver<[SingleEliminationResult]> in
                guard let self else { return .never() }
                
                let ids = singleEliminations.map { $0.id }
                
                let initial = tournamentManager
                    .fetchSingleEliminationsResults(singleEliminationsIds: ids)
                    .asDriver(onErrorJustReturn: [])
                
                return initial
                    .flatMapLatest { initial -> Driver<[SingleEliminationResult]> in
                        TournamentMediator.shared
                            .didCreatedSingleEliminationResult
                            .scan(initial) { array, new -> [SingleEliminationResult] in
                                array + [new]
                            }
                            .startWith(initial)
                            .asDriver(onErrorJustReturn: [])
                    }
            }
    }
    
    func makeTeams() -> Driver<[Team]> {
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
                let created = TeamMediator.shared.didCreatedTeam
                    .map { Action.created($0) }
                    .asDriver(onErrorDriveWith: .never())
                
                let deleted = TeamMediator.shared.didDeletedTeamId
                    .map { Action.deleted($0) }
                    .asDriver(onErrorDriveWith: .never())
                
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
            }
    }
}

// MARK: Additional
private extension Team {
    static func unknownTeam() -> Team {
        Team(id: "-1", name: "", createdAt: Date().timeIntervalSince1970)
    }
}
