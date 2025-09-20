//
//  SingleEliminationViewModel.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 18.09.2025.
//

import RxSwift
import RxCocoa

// TODO:
// 3. round games - позиционирование игр
// 4. шаринг
// 5. placeholder с тапом для выбора победителя
final class SingleEliminationViewModel {
    enum Action {
        case requestConfirmDelete
        case close
    }
    
    private let singleElimination: Driver<SingleElimination>
    
    private lazy var tournamentManager = TournamentManager()
    private lazy var teamManager = TeamManager()
    
    init(singleElimination: SingleElimination) {
        self.singleElimination = BehaviorRelay(value: singleElimination).asDriver()
    }
}

// MARK: Public
extension SingleEliminationViewModel {
    struct Input {
        let didTapDelete: Signal<Void>
        let didConfirmDelete: Signal<Void>
        let didSelectWinner: Signal<(gameId: String, teamId: String)>
    }
    
    struct Output {
        let action: Driver<Action>
        let tournament: Driver<SETournamentView.Tournament>
    }
    
    func configure(input: Input) -> Output {
        let gamesAndResults = makeGamesAndResults(
            singleElimination: singleElimination,
            didSelectWinner: input.didSelectWinner
        )
        
        return Output(
            action: makeAction(
                singleElimination: singleElimination,
                didTapDelete: input.didTapDelete,
                didConfirmDelete: input.didConfirmDelete
            ),
            tournament: makeTournament(
                teams: makeTeams(),
                gamesAndResults: gamesAndResults,
                tournamentResult: makeTournamentResult(singleElimination: singleElimination)
            )
        )
    }
}

// MARK: Private
private extension SingleEliminationViewModel {
    func makeAction(
        singleElimination: Driver<SingleElimination>,
        didTapDelete: Signal<Void>,
        didConfirmDelete: Signal<Void>
    ) -> Driver<Action> {
        let requestConfirmDelete = didTapDelete
            .map { Action.requestConfirmDelete }
            .asDriver(onErrorDriveWith: .never())
        
        let delete = didConfirmDelete
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(singleElimination)
            .flatMapLatest { [weak self] singleElimination -> Driver<Action> in
                guard let self else { return .never() }
                
                return tournamentManager
                    .delete(singleEliminationId: singleElimination.id)
                    .map { Action.close }
                    .asDriver(onErrorDriveWith: .never())
            }
        
        return Driver
            .merge(requestConfirmDelete, delete)
    }
    
    func makeTournament(
        teams: Driver<[Team]>,
        gamesAndResults: Driver<([SingleEliminationGame], [SingleEliminationGameResult])>,
        tournamentResult: Driver<SingleEliminationResult?>
    ) -> Driver<SETournamentView.Tournament> {
        Driver
            .combineLatest(teams, gamesAndResults, tournamentResult)
            .map { teams, gamesAndResults, tournamentResult in
                let (games, gamesResults) = gamesAndResults
                
                let rounds = Self.buildRounds(from: games, teams: teams, results: gamesResults)
                let winner = tournamentResult
                    .map { tournamentResult -> SETeamView.Team in
                        SETeamView.Team(
                            teamId: tournamentResult.winner,
                            teamName: teams.first(where: { $0.id == tournamentResult.winner })?.name ?? tournamentResult.winner,
                            isWinner: true,
                            isBye: false
                        )
                    }
                return SETournamentView.Tournament(rounds: rounds, winner: winner)
            }
    }
    
    func makeGamesAndResults(
        singleElimination: Driver<SingleElimination>,
        didSelectWinner: Signal<(gameId: String, teamId: String)>
    ) -> Driver<([SingleEliminationGame], [SingleEliminationGameResult])> {
        let games: Driver<[SingleEliminationGame]> = {
            let initial = singleElimination
                .flatMapLatest { [weak self] singleElimination -> Driver<[SingleEliminationGame]> in
                    guard let self else { return .never() }
                    
                    return tournamentManager
                        .fetchSingleEliminationGames(singleEliminationId: singleElimination.id)
                        .asDriver(onErrorJustReturn: [])
                }
            
            let select = didSelectWinner
                .asDriver(onErrorDriveWith: .never())
                .withLatestFrom(singleElimination) { ($0, $1) }
                .flatMapLatest { [weak self] args -> Driver<[SingleEliminationGame]> in
                    guard let self else { return .never() }
                    
                    let ((gameId, teamId), singleElimination) = args
                    
                    return tournamentManager
                        .setWinnerForSingleEliminationGame(gameId: gameId, winnerTeamId: teamId)
                        .asDriver(onErrorDriveWith: .never())
                        .flatMap { _ -> Driver<[SingleEliminationGame]> in
                            self.tournamentManager
                                .fetchSingleEliminationGames(singleEliminationId: singleElimination.id)
                                .asDriver(onErrorJustReturn: [])
                        }
                }

            return Driver
                .merge(initial, select)
        }()
        
        return games
            .flatMapLatest { [weak self] games -> Driver<([SingleEliminationGame], [SingleEliminationGameResult])> in
                guard let self else { return .never() }
                
                return tournamentManager
                    .fetchSingleEliminationGamesResults(gamesIds: games.map { $0.id })
                    .asDriver(onErrorJustReturn: [])
                    .map { (games, $0) }
            }
    }
    
    func makeTournamentResult(singleElimination: Driver<SingleElimination>) -> Driver<SingleEliminationResult?> {
        let initial = singleElimination
            .flatMapLatest { [weak self] singleElimination -> Driver<SingleEliminationResult?> in
                guard let self else { return .never() }
                
                return tournamentManager
                    .fetchSingleEliminationResult(singleEliminationId: singleElimination.id)
                    .asDriver(onErrorJustReturn: nil)
            }
        
        let created = TournamentMediator.shared.didCreatedSingleEliminationResult
            .asDriver(onErrorDriveWith: .never())
            .map { result -> SingleEliminationResult? in result }
        
        return Driver
            .merge(initial, created)
    }
    
    func makeTeams() -> Driver<[Team]> {
        teamManager
            .fetchTeams()
            .asDriver(onErrorJustReturn: [])
    }
}

// MARK: Additional
private extension SingleEliminationViewModel {
    static func buildRounds(
        from games: [SingleEliminationGame],
        teams: [Team],
        results: [SingleEliminationGameResult]
    ) -> [SERoundGamesView.Round] {
        guard !games.isEmpty else { return [] }

        let resByGame = Dictionary(uniqueKeysWithValues: results.map { ($0.gameId, $0) })
        let grouped = Dictionary(grouping: games, by: { $0.round })
        let orderedRoundKeys = grouped.keys.sorted()

        return orderedRoundKeys.map { roundKey in
            let roundGames = (grouped[roundKey] ?? []).sorted { $0.sort < $1.sort }
            return SERoundGamesView.Round(
                games: roundGames.map { mapGame($0, teams: teams, result: resByGame[$0.id]) },
                round: roundKey
            )
        }
    }
    
    static func mapGame(
        _ game: SingleEliminationGame,
        teams: [Team],
        result: SingleEliminationGameResult?
    ) -> SEGameView.Game {
        SEGameView.Game(
            gameId: game.id,
            team1: mapTeam(game.team1, teams: teams, result: result),
            team2: mapTeam(game.team2, teams: teams, result: result)
        )
    }
    
    static func mapTeam(
        _ team: SingleEliminationGame.Team,
        teams: [Team],
        result: SingleEliminationGameResult?
    ) -> SETeamView.Team? {
        switch team {
        case .team(let teamId):
            let name = teams.first(where: { $0.id == teamId })?.name ?? teamId
            let isWinner: Bool? = {
                guard let r = result else { return nil }
                if r.winnerTeamId == teamId { return true }
                if r.loserTeamId == teamId { return false }
                return nil
            }()
            return SETeamView.Team(teamId: teamId, teamName: name, isWinner: isWinner, isBye: false)

        case .bye:
            return SETeamView.Team(teamId: "bye", teamName: "SingleElimination.Bye".localized, isWinner: nil, isBye: true)
        case .scheduled:
            return nil
        }
    }
}
