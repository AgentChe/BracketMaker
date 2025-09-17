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
                ptsElements: makePtsElements(
                    roundRobin: roundRobin,
                    teams: teams,
                    games: games,
                    gamesResults: gamesResults
                ),
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
    func makeElements(
        ptsElements: Driver<[RoundRobinTablePtsTeamElement]>,
        gamesElements: Driver<[RoundRobinTableGameElement]>
    ) -> Driver<[RoundRobinTableElement]> {
        Driver
            .combineLatest(ptsElements, gamesElements)
            .map { ptsElements, gamesElements -> [RoundRobinTableElement] in
                [.ptsHeader] + ptsElements.map { .ptsTeam($0) } + gamesElements.map { .game($0) }
            }
    }
    
    func makePtsElements(
        roundRobin: Driver<RoundRobin>,
        teams: Driver<[Team]>,
        games: Driver<[Game]>,
        gamesResults: Driver<[RoundRobinGameResult]>
    ) -> Driver<[RoundRobinTablePtsTeamElement]> {
        Driver
            .combineLatest(roundRobin, teams, games, gamesResults)
            .map { roundRobin, teams, games, gamesResults -> [RoundRobinTablePtsTeamElement] in
                let teamById = Dictionary(uniqueKeysWithValues: teams.map { ($0.id, $0) })
                let orderedTeams = roundRobin.teamsIds.compactMap { teamById[$0] }

                let gameById = Dictionary(uniqueKeysWithValues: games.map { ($0.id, $0) })

                struct Agg { var w = 0, d = 0, l = 0, f = 0, a = 0 }
                
                var agg: [String: Agg] = [:]

                for gameResult in gamesResults {
                    guard let game = gameById[gameResult.gameId], let t2Id = game.team2Id else { continue }
                    
                    let t1Id = game.team1Id

                    var a1 = agg[t1Id] ?? Agg()
                    var a2 = agg[t2Id] ?? Agg()

                    a1.f += gameResult.team1GoalsFor
                    a1.a += gameResult.team1GoalsAgainst
                    a2.f += gameResult.team2GoalsFor
                    a2.a += gameResult.team2GoalsAgainst

                    if gameResult.team1GoalsFor > gameResult.team2GoalsFor {
                        a1.w += 1
                        a2.l += 1
                    } else if gameResult.team1GoalsFor < gameResult.team2GoalsFor {
                        a2.w += 1
                        a1.l += 1
                    } else {
                        a1.d += 1
                        a2.d += 1
                    }

                    agg[t1Id] = a1
                    agg[t2Id] = a2
                }

                return orderedTeams.enumerated().map { idx, team in
                    if let a = agg[team.id] {
                        return RoundRobinTablePtsTeamElement(
                            team: team,
                            w: a.w,
                            d: a.d,
                            l: a.l,
                            f: a.f,
                            a: a.a,
                            pts: a.w * 3 + a.d,
                            style: idx.isMultiple(of: 2) ? .white : .gray
                        )
                    } else {
                        return RoundRobinTablePtsTeamElement(
                            team: team,
                            w: nil, d: nil, l: nil, f: nil, a: nil, pts: nil,
                            style: idx.isMultiple(of: 2) ? .white : .gray
                        )
                    }
                }
            }
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
