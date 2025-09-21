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
        case createBracket(TournamentPreset?)
        case openSingleElimination(SingleElimination)
        case openDoubleElimination(DoubleElimination)
        case openRoundRobin(RoundRobin)
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
        let didSelectBracket: Signal<HomeTableBracketElement.Bracket>
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
        let doubleEliminations = makeDoubleEliminations()
        let doubleEliminationsResults = makeDoubleEliminationsResults(doubleEliminations: doubleEliminations)
        let doubleEliminationsElements = makeDoubleEliminationsElements(
            doubleEliminations: doubleEliminations,
            doubleEliminationsResults: doubleEliminationsResults,
            teams: teams
        )
        let roundRobins = makeRoundRobins()
        let roundRobinsResults = makeRoundRobinsResults(roundRobins: roundRobins)
        let roundRobinsElements = makeRoundRobinsElements(
            roundRobins: roundRobins,
            roundRobinsResults: roundRobinsResults,
            teams: teams
        )
        let bracketsElements = makeBracketsElements(
            currentFilter: currentFilter,
            singleEliminationsElements: singleEliminationsElements,
            doubleEliminationsElements: doubleEliminationsElements,
            roundRobinsElements: roundRobinsElements
        )
        
        return Output(
            elements: makeElements(
                currentFilter: currentFilter,
                bracketsElements: bracketsElements
            ),
            action: makeAction(
                didTapPaygate: input.didTapPaygate,
                didTapAddFirstBracket: input.didTapAddFirstBracket,
                didTapPreset: input.didTapPreset,
                didSelectBracket: input.didSelectBracket
            ),
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
    
    func makeBracketsElements(
        currentFilter: Driver<HomeFilterItemButton.Filter>,
        singleEliminationsElements: Driver<[HomeTableBracketElement]>,
        doubleEliminationsElements: Driver<[HomeTableBracketElement]>,
        roundRobinsElements: Driver<[HomeTableBracketElement]>
    ) -> Driver<[HomeTableBracketElement]> {
        Driver
            .combineLatest(
                singleEliminationsElements,
                doubleEliminationsElements,
                roundRobinsElements
            ) { $0 + $1 + $2 }
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
    
    func makeDoubleEliminationsElements(
        doubleEliminations: Driver<[DoubleElimination]>,
        doubleEliminationsResults: Driver<[DoubleEliminationResult]>,
        teams: Driver<[Team]>
    ) -> Driver<[HomeTableBracketElement]> {
        Driver
            .combineLatest(doubleEliminations, doubleEliminationsResults)
            .withLatestFrom(teams) { ($0.0, $0.1, $1) }
            .map { doubleEliminations, doubleEliminationsResults, teams -> [HomeTableBracketElement] in
                doubleEliminations.map { doubleElimination -> HomeTableBracketElement in
                    let state: HomeTableBracketElement.State = {
                        guard let result = doubleEliminationsResults.first(where: { $0.doubleEliminationId == doubleElimination.id }) else {
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
                        bracket: .doubleElimination(doubleElimination)
                    )
                }
            }
    }
    
    func makeRoundRobinsElements(
        roundRobins: Driver<[RoundRobin]>,
        roundRobinsResults: Driver<[RoundRobinResult]>,
        teams: Driver<[Team]>
    ) -> Driver<[HomeTableBracketElement]> {
        Driver
            .combineLatest(roundRobins, roundRobinsResults)
            .withLatestFrom(teams) { ($0.0, $0.1, $1) }
            .map { roundRobins, roundRobinsResults, teams -> [HomeTableBracketElement] in
                roundRobins.map { roundRobin -> HomeTableBracketElement in
                    let state: HomeTableBracketElement.State = {
                        guard let result = roundRobinsResults.first(where: { $0.roundRobinId == roundRobin.id }) else {
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
                        bracket: .roundRobin(roundRobin)
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
        didTapPaygate: Signal<Void>,
        didTapAddFirstBracket: Signal<Void>,
        didTapPreset: Signal<TournamentPreset>,
        didSelectBracket: Signal<HomeTableBracketElement.Bracket>
    ) -> Driver<Action> {
        let openPaygate = didTapPaygate
            .map { Action.openPaygate }
            .asDriver(onErrorDriveWith: .never())
        
        let createBracket = Signal
            .merge(
                didTapAddFirstBracket
                    .map { Action.createBracket(nil) },
                didTapPreset
                    .map { Action.createBracket($0) }
            )
            .asDriver(onErrorDriveWith: .never())
        
        let openBracket = didSelectBracket
            .map { bracket -> Action in
                switch bracket {
                case .singleElimination(let singleElimination):
                    return .openSingleElimination(singleElimination)
                case .doubleElimination(let doubleElimination):
                    return .openDoubleElimination(doubleElimination)
                case .roundRobin(let roundRobin):
                    return .openRoundRobin(roundRobin)
                }
            }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(openPaygate, createBracket, openBracket)
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
        
        enum Action {
            case created(SingleElimination)
            case deleted(String)
        }
        
        return initial
            .flatMapLatest { initial -> Driver<[SingleElimination]> in
                let action = Signal
                    .merge(
                        TournamentMediator.shared
                            .didCreatedSingleElimination
                            .map { Action.created($0) },
                        
                        TournamentMediator.shared
                            .didDeletedSingleElimination
                            .map { Action.deleted($0) }
                    )
                
                return action
                    .scan(initial) { array, action -> [SingleElimination] in
                        switch action {
                        case .created(let singleElimination):
                            return array + [singleElimination]
                        case .deleted(let id):
                            var result = array
                            result.removeAll(where: { $0.id == id })
                            return result
                        }
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
    
    func makeDoubleEliminations() -> Driver<[DoubleElimination]> {
        let initial = tournamentManager
            .fetchDoubleEliminations()
            .asDriver(onErrorJustReturn: [])
        
        enum Action {
            case created(DoubleElimination)
            case deleted(String)
        }
        
        return initial
            .flatMapLatest { initial -> Driver<[DoubleElimination]> in
                let action = Signal
                    .merge(
                        TournamentMediator.shared
                            .didCreatedDoubleElimination
                            .map { Action.created($0) },
                        
                        TournamentMediator.shared
                            .didDeletedDoubleElimination
                            .map { Action.deleted($0) }
                    )
                
                return action
                    .scan(initial) { array, action -> [DoubleElimination] in
                        switch action {
                        case .created(let doubleElimination):
                            return array + [doubleElimination]
                        case .deleted(let id):
                            var result = array
                            result.removeAll(where: { $0.id == id })
                            return result
                        }
                    }
                    .startWith(initial)
                    .asDriver(onErrorJustReturn: [])
            }
    }
    
    func makeDoubleEliminationsResults(doubleEliminations: Driver<[DoubleElimination]>) -> Driver<[DoubleEliminationResult]> {
        doubleEliminations
            .flatMapLatest { [weak self] doubleEliminations -> Driver<[DoubleEliminationResult]> in
                guard let self else { return .never() }
                
                let ids = doubleEliminations.map { $0.id }
                
                let initial = tournamentManager
                    .fetchDoubleEliminationsResults(doubleEliminationsIds: ids)
                    .asDriver(onErrorJustReturn: [])
                
                return initial
                    .flatMapLatest { initial -> Driver<[DoubleEliminationResult]> in
                        TournamentMediator.shared
                            .didCreatedDoubleEliminationResult
                            .scan(initial) { array, new -> [DoubleEliminationResult] in
                                array + [new]
                            }
                            .startWith(initial)
                            .asDriver(onErrorJustReturn: [])
                    }
            }
    }
    
    func makeRoundRobins() -> Driver<[RoundRobin]> {
        let initial = tournamentManager
            .fetchRoundRobins()
            .asDriver(onErrorJustReturn: [])
        
        enum Action {
            case created(RoundRobin)
            case deleted(String)
        }
        
        return initial
            .flatMapLatest { initial -> Driver<[RoundRobin]> in
                let action = Signal
                    .merge(
                        TournamentMediator.shared
                            .didCreatedRoundRobin
                            .map { Action.created($0) },
                        
                        TournamentMediator.shared
                            .didDeletedRoundRobin
                            .map { Action.deleted($0) }
                    )
                
                return action
                    .scan(initial) { array, action -> [RoundRobin] in
                        switch action {
                        case .created(let roundRobin):
                            return array + [roundRobin]
                        case .deleted(let id):
                            var result = array
                            result.removeAll(where: { $0.id == id })
                            return result
                        }
                    }
                    .startWith(initial)
                    .asDriver(onErrorJustReturn: [])
            }
    }
    
    func makeRoundRobinsResults(roundRobins: Driver<[RoundRobin]>) -> Driver<[RoundRobinResult]> {
        roundRobins
            .flatMapLatest { [weak self] roundRobins -> Driver<[RoundRobinResult]> in
                guard let self else { return .never() }
                
                let ids = roundRobins.map { $0.id }
                
                let initial = tournamentManager
                    .fetchRoundRobinsResults(roundRobinsIds: ids)
                    .asDriver(onErrorJustReturn: [])
                
                return initial
                    .flatMapLatest { initial -> Driver<[RoundRobinResult]> in
                        TournamentMediator.shared
                            .didCreatedRoundRobinResult
                            .scan(initial) { array, new -> [RoundRobinResult] in
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
