//
//  CreateRRGameResultViewModel.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 16.09.2025.
//

import RxSwift
import RxCocoa

final class CreateRRGameResultViewModel {
    enum Action {
        case close
    }
    
    private let gameId: Driver<String>
    
    private lazy var tournamentManager = TournamentManager()
    private lazy var teamManager = TeamManager()
    
    init(gameId: String) {
        self.gameId = BehaviorRelay(value: gameId).asDriver()
    }
}

// MARK: Public
extension CreateRRGameResultViewModel {
    struct Input {
        let didIncrementGoalsForTeam1: Signal<Void>
        let didDicrementGoalsForTeam1: Signal<Void>
        let didIncrementGoalsForTeam2: Signal<Void>
        let didDicrementGoalsForTeam2: Signal<Void>
        let didTapSave: Signal<Void>
    }
    
    struct Output {
        let goalsForTeam1: Driver<Int>
        let goalsForTeam2: Driver<Int>
        let teams: Driver<(team1: Team, team2: Team)>
        let action: Driver<Action>
    }
    
    func configure(input: Input) -> Output {
        let goalsForTeam1 = makeGoalsForTeam(
            didIncrementGoalsForTeam: input.didIncrementGoalsForTeam1,
            didDicrementGoalsForTeam: input.didDicrementGoalsForTeam1
        )
        let goalsForTeam2 = makeGoalsForTeam(
            didIncrementGoalsForTeam: input.didIncrementGoalsForTeam2,
            didDicrementGoalsForTeam: input.didDicrementGoalsForTeam2
        )
        
        return Output(
            goalsForTeam1: goalsForTeam1,
            goalsForTeam2: goalsForTeam2,
            teams: makeTeams(gameId: gameId),
            action: makeAction(
                didTapSave: input.didTapSave,
                gameId: gameId,
                goalsForTeam1: goalsForTeam1,
                goalsForTeam2: goalsForTeam2
            )
        )
    }
}

// MARK: Private
private extension CreateRRGameResultViewModel {
    func makeGoalsForTeam(
        didIncrementGoalsForTeam: Signal<Void>,
        didDicrementGoalsForTeam: Signal<Void>
    ) -> Driver<Int> {
        Signal
            .merge(
                didIncrementGoalsForTeam.map { 1 },
                didDicrementGoalsForTeam.map { -1 }
            )
            .scan(0) { value, changed -> Int in
                max(0, (value + changed))
            }
            .asDriver(onErrorJustReturn: 0)
            .startWith(0)
    }
    
    func makeTeams(gameId: Driver<String>) -> Driver<(team1: Team, team2: Team)> {
        gameId
            .flatMapLatest { [weak self] gameId -> Driver<(team1: Team, team2: Team)> in
                guard let self else { return .never() }
                
                return tournamentManager
                    .fetchGames(ids: [gameId])
                    .compactMap { $0.first(where: { $0.id == gameId }) }
                    .asDriver(onErrorDriveWith: .never())
                    .flatMap { game -> Driver<(team1: Team, team2: Team)> in
                        self.teamManager
                            .fetchTeams()
                            .compactMap { teams -> (team1: Team, team2: Team)? in
                                guard
                                    let team1 = teams.first(where: { $0.id == game.team1Id }),
                                    let team2 = teams.first(where: { $0.id == game.team2Id })
                                else { return nil }
                                
                                return (team1: team1, team2: team2)
                            }
                            .asDriver(onErrorDriveWith: .never())
                    }
            }
    }
    
    func makeAction(
        didTapSave: Signal<Void>,
        gameId: Driver<String>,
        goalsForTeam1: Driver<Int>,
        goalsForTeam2: Driver<Int>
    ) -> Driver<Action> {
        didTapSave
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(gameId)
            .withLatestFrom(goalsForTeam1) { ($0, $1) }
            .withLatestFrom(goalsForTeam2) { ($0.0, $0.1, $1) }
            .flatMapLatest { [weak self] gameId, goalsForTeam1, goalsForTeam2 -> Driver<Action> in
                guard let self else { return .never() }
                
                return tournamentManager
                    .createRoundRobinGameResult(
                        gameId: gameId,
                        team1GoalsFor: goalsForTeam1,
                        team1GoalsAgainst: goalsForTeam2,
                        team2GoalsFor: goalsForTeam2,
                        team2GoalsAgainst: goalsForTeam1
                    )
                    .map { _ in Action.close }
                    .asDriver(onErrorDriveWith: .never())
            }
    }
}
