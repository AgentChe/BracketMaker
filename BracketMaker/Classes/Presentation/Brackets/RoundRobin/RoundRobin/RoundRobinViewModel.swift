//
//  RoundRobinViewModel.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 16.09.2025.
//

import RxSwift
import RxCocoa

final class RoundRobinViewModel {
    enum Action {
        case createGameResult(String)
        case requestConfirmDelete
        case close
    }
    
    private let roundRobin: Driver<RoundRobin>
    
    private lazy var tournamentManager = TournamentManager()
    private lazy var teamManager = TeamManager()
    
    init(roundRobin: RoundRobin) {
        self.roundRobin = BehaviorRelay(value: roundRobin).asDriver()
    }
}

// MARK: Public
extension RoundRobinViewModel {
    struct Input {
        let didSelectGameElement: Signal<RoundRobinTableGameElement>
        let didTapDelete: Signal<Void>
        let didConfirmDelete: Signal<Void>
    }
    
    struct Output {
        let elements: Driver<[RoundRobinTableElement]>
        let action: Driver<Action>
    }
    
    func configure(input: Input) -> Output {
        let teams = makeTeams()
        let games = makeGames(roundRobin: roundRobin)
        let gamesResults = makeGamesResults(games: games)
        
        return Output(
            elements: makeElements(
                gamesElements: makeGamesElements(
                    teams: teams,
                    games: games,
                    gamesResults: gamesResults
                )
            ),
            action: makeAction(
                roundRobin: roundRobin,
                didSelectGameElement: input.didSelectGameElement,
                didTapDelete: input.didTapDelete,
                didConfirmDelete: input.didConfirmDelete
            )
        )
    }
}

// MARK: Private
private extension RoundRobinViewModel {
    func makeElements(gamesElements: Driver<[RoundRobinTableGameElement]>) -> Driver<[RoundRobinTableElement]> {
        gamesElements.map { $0.map { .game($0) } }
    }
    
    func makeGamesElements(
        teams: Driver<[Team]>,
        games: Driver<[Game]>,
        gamesResults: Driver<[RoundRobinGameResult]>
    ) -> Driver<[RoundRobinTableGameElement]> {
        Driver
            .combineLatest(teams, games, gamesResults)
            .map { teams, games, gamesResults -> [RoundRobinTableGameElement] in
                games.compactMap { game -> RoundRobinTableGameElement? in
                    let team1 = teams.first(where: { $0.id == game.team1Id })
                    let team2 = teams.first(where: { $0.id == game.team2Id })
                    guard let team1, let team2 else { return nil }
                    
                    let result = gamesResults.first(where: { $0.gameId == game.id })
                    
                    let team1Data = RoundRobinTeamView.Team(
                        name: team1.name,
                        state: {
                            guard let result else { return .none }
                            
                            if result.team1GoalsFor > result.team2GoalsFor {
                                return .winner(result.team1GoalsFor)
                            } else if result.team1GoalsFor < result.team2GoalsFor {
                                return .loser(result.team1GoalsFor)
                            } else {
                                return .draw(result.team1GoalsFor)
                            }
                        }()
                    )
                    
                    let team2Data = RoundRobinTeamView.Team(
                        name: team2.name,
                        state: {
                            guard let result else { return .none }
                            
                            if result.team1GoalsFor > result.team2GoalsFor {
                                return .loser(result.team2GoalsFor)
                            } else if result.team1GoalsFor < result.team2GoalsFor {
                                return .winner(result.team2GoalsFor)
                            } else {
                                return .draw(result.team2GoalsFor)
                            }
                        }()
                    )
                    
                    return RoundRobinTableGameElement(
                        gameId: game.id,
                        team1: team1Data,
                        team2: team2Data
                    )
                }
            }
    }
    
    func makeGames(roundRobin: Driver<RoundRobin>) -> Driver<[Game]> {
        roundRobin
            .flatMapLatest { [weak self] roundRobin -> Driver<[Game]> in
                guard let self else { return .never() }
                
                return tournamentManager
                    .fetchRoundRobinGames(roundRobinId: roundRobin.id)
                    .asDriver(onErrorDriveWith: .never())
                    .flatMap { rrGames -> Driver<[Game]> in
                        self.tournamentManager
                            .fetchGames(ids: rrGames.gamesIds)
                            .asDriver(onErrorJustReturn: [])
                    }
            }
    }
    
    func makeGamesResults(games: Driver<[Game]>) -> Driver<[RoundRobinGameResult]> {
        let initial = games
            .flatMapLatest { [weak self] games -> Driver<[RoundRobinGameResult]> in
                guard let self else { return .never() }
                
                return tournamentManager
                    .fetchRoundRobinGamesResults(gamesIds: games.map { $0.id })
                    .asDriver(onErrorJustReturn: [])
            }
        
        enum Action {
            case created(RoundRobinGameResult)
        }
        
        return initial
            .flatMapLatest { initialResult -> Driver<[RoundRobinGameResult]> in
                let action = TournamentMediator.shared
                    .didCreatedRoundRobinGameResult
                    .map { Action.created($0) }
                    .asDriver(onErrorDriveWith: .never())
                
                return action
                    .scan(initialResult) { results, action -> [RoundRobinGameResult] in
                        switch action {
                        case .created(let result):
                            results + [result]
                        }
                    }
                    .startWith(initialResult)
            }
    }
    
    func makeTeams() -> Driver<[Team]> {
        teamManager
            .fetchTeams()
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeAction(
        roundRobin: Driver<RoundRobin>,
        didSelectGameElement: Signal<RoundRobinTableGameElement>,
        didTapDelete: Signal<Void>,
        didConfirmDelete: Signal<Void>
    ) -> Driver<Action> {
        let createGameResult = didSelectGameElement
            .asDriver(onErrorDriveWith: .never())
            .compactMap { element -> Action? in
                (element.team1.state.isNone && element.team2.state.isNone) ? Action.createGameResult(element.gameId) : nil
            }
        
        let requestConfirmDelete = didTapDelete
            .map { Action.requestConfirmDelete }
            .asDriver(onErrorDriveWith: .never())
        
        let delete = didConfirmDelete
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(roundRobin)
            .flatMapLatest { [weak self] roundRobin -> Driver<Action> in
                guard let self else { return .never() }
                
                return tournamentManager
                    .delete(roundRobinId: roundRobin.id)
                    .map { Action.close }
                    .asDriver(onErrorDriveWith: .never())
            }
        
        return Driver
            .merge(createGameResult, requestConfirmDelete, delete)
    }
}
