//
//  DoubleEliminationViewModel.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 21.09.2025.
//

import RxSwift
import RxCocoa

final class DoubleEliminationViewModel {
    enum Action {
        case requestConfirmDelete
        case close
        case share(URL) // пока не используем
    }
    
    private let doubleElimination: Driver<DoubleElimination>
    
    private lazy var tournamentManager = TournamentManager()
    private lazy var teamManager = TeamManager()
    
    init(doubleElimination: DoubleElimination) {
        self.doubleElimination = BehaviorRelay(value: doubleElimination).asDriver()
    }
}

// MARK: Public
extension DoubleEliminationViewModel {
    struct Input {
        let didTapDelete: Signal<Void>
        let didConfirmDelete: Signal<Void>
        let didSelectWinner: Signal<(gameId: String, teamId: String)>
        let didTapShare: Signal<Void> // игнорируем
    }
    
    struct Output {
        let action: Driver<Action>
        let tournament: Driver<DETournamentView.Tournament>
        let selectWinnerPlaceholderHidden: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        let teams = makeTeams()
        let gamesAndResults = makeGamesAndResults(
            doubleElimination: doubleElimination,
            didSelectWinner: input.didSelectWinner
        )
        let tournamentResult = makeTournamentResult(doubleElimination: doubleElimination)
        
        return Output(
            action: makeAction(
                doubleElimination: doubleElimination,
                teams: teams,
                gamesAndResults: gamesAndResults,
                tournamentResult: tournamentResult,
                didTapDelete: input.didTapDelete,
                didConfirmDelete: input.didConfirmDelete,
                didTapShare: input.didTapShare
            ),
            tournament: makeTournament(
                teams: teams,
                gamesAndResults: gamesAndResults,
                tournamentResult: tournamentResult
            ),
            selectWinnerPlaceholderHidden: makeSelectWinnerPlaceholderHidden(gamesAndResults: gamesAndResults)
        )
    }
}

// MARK: Private
private extension DoubleEliminationViewModel {
    func makeSelectWinnerPlaceholderHidden(
        gamesAndResults: Driver<([DoubleEliminationGame], [DoubleEliminationGameResult])>
    ) -> Driver<Bool> {
        gamesAndResults.map { !$0.1.isEmpty }
    }
    
    func makeAction(
        doubleElimination: Driver<DoubleElimination>,
        teams: Driver<[Team]>,
        gamesAndResults: Driver<([DoubleEliminationGame], [DoubleEliminationGameResult])>,
        tournamentResult: Driver<DoubleEliminationResult?>,
        didTapDelete: Signal<Void>,
        didConfirmDelete: Signal<Void>,
        didTapShare: Signal<Void>
    ) -> Driver<Action> {
        let requestConfirmDelete = didTapDelete
            .map { Action.requestConfirmDelete }
            .asDriver(onErrorDriveWith: .never())
        
        let delete = didConfirmDelete
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(doubleElimination)
            .flatMapLatest { [weak self] de -> Driver<Action> in
                guard let self else { return .never() }
                return tournamentManager
                    .delete(doubleEliminationId: de.id)
                    .map { Action.close }
                    .asDriver(onErrorDriveWith: .never())
            }
        
        let share = didTapShare
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(doubleElimination)
            .withLatestFrom(teams) { ($0, $1) }
            .withLatestFrom(gamesAndResults) { ($0.0, $0.1, $1) }
            .withLatestFrom(tournamentResult) { ($0.0, $0.1, $0.2, $1) }
            .map { doubleElimination, teams, gamesAndResults, tournamentResult -> Action in
                let input = DoubleEliminationPDFGenerator.Input(
                    title: doubleElimination.name,
                    subtitle: "DoubleElimination.PDFTttle".localized,
                    teams: teams,
                    games: gamesAndResults.0,
                    gameResults: gamesAndResults.1,
                    tournamentResult: tournamentResult
                )
                let url = DoubleEliminationPDFGenerator().makePDF(input)
                return .share(url)
            }
        
        return Driver
            .merge(requestConfirmDelete, delete, share)
    }
    
    func makeTournament(
        teams: Driver<[Team]>,
        gamesAndResults: Driver<([DoubleEliminationGame], [DoubleEliminationGameResult])>,
        tournamentResult: Driver<DoubleEliminationResult?>
    ) -> Driver<DETournamentView.Tournament> {
        Driver
            .combineLatest(teams, gamesAndResults, tournamentResult)
            .map { teams, pair, tr in
                let (games, results) = pair
                let byGame = Dictionary(uniqueKeysWithValues: results.map { ($0.gameId, $0) })
                
                let winners = games.filter { $0.bracket == .winner }
                let losers  = games.filter { $0.bracket == .loser }
                
                let wRounds = Self.buildRounds(from: winners, teams: teams, resByGame: byGame)
                let lRounds = Self.buildRounds(from: losers,  teams: teams, resByGame: byGame)
                
                let winner = tr.map { r -> SETeamView.Team in
                    SETeamView.Team(
                        teamId: r.winner,
                        teamName: teams.first(where: { $0.id == r.winner })?.name ?? r.winner,
                        isWinner: true,
                        isBye: false
                    )
                }
                
                return DETournamentView.Tournament(
                    winnersRounds: wRounds,
                    losersRounds: lRounds,
                    winner: winner
                )
            }
    }
    
    func makeGamesAndResults(
        doubleElimination: Driver<DoubleElimination>,
        didSelectWinner: Signal<(gameId: String, teamId: String)>
    ) -> Driver<([DoubleEliminationGame], [DoubleEliminationGameResult])> {
        let games: Driver<[DoubleEliminationGame]> = {
            let initial = doubleElimination
                .flatMapLatest { [weak self] de -> Driver<[DoubleEliminationGame]> in
                    guard let self else { return .never() }
                    return tournamentManager
                        .fetchDoubleEliminationGames(doubleEliminationId: de.id)
                        .asDriver(onErrorJustReturn: [])
                }
            
            let select = didSelectWinner
                .asDriver(onErrorDriveWith: .never())
                .withLatestFrom(doubleElimination) { ($0, $1) }
                .flatMapLatest { [weak self] args -> Driver<[DoubleEliminationGame]> in
                    guard let self else { return .never() }
                    
                    let ((gameId, teamId), de) = args
                    
                    return tournamentManager
                        .setWinnerForDoubleEliminationGame(gameId: gameId, winnerTeamId: teamId)
                        .asDriver(onErrorDriveWith: .never())
                        .flatMap { _ -> Driver<[DoubleEliminationGame]> in
                            self.tournamentManager
                                .fetchDoubleEliminationGames(doubleEliminationId: de.id)
                                .asDriver(onErrorJustReturn: [])
                        }
                }
            
            return Driver
                .merge(initial, select)
        }()
        
        return games
            .flatMapLatest { [weak self] games -> Driver<([DoubleEliminationGame], [DoubleEliminationGameResult])> in
                guard let self else { return .never() }
                
                return tournamentManager
                    .fetchDoubleEliminationGamesResults(gamesIds: games.map { $0.id })
                    .asDriver(onErrorJustReturn: [])
                    .map { (games, $0) }
            }
    }
    
    func makeTournamentResult(
        doubleElimination: Driver<DoubleElimination>
    ) -> Driver<DoubleEliminationResult?> {
        let initial = doubleElimination
            .flatMapLatest { [weak self] de -> Driver<DoubleEliminationResult?> in
                guard let self else { return .never() }
                
                return tournamentManager
                    .fetchDoubleEliminationResult(doubleEliminationId: de.id)
                    .asDriver(onErrorJustReturn: nil)
            }
        
        let created = TournamentMediator.shared.didCreatedDoubleEliminationResult
            .asDriver(onErrorDriveWith: .never())
            .map { res -> DoubleEliminationResult? in res }
        
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
private extension DoubleEliminationViewModel {
    static func buildRounds(
        from games: [DoubleEliminationGame],
        teams: [Team],
        resByGame: [String: DoubleEliminationGameResult]
    ) -> [SERoundGamesView.Round] {
        guard !games.isEmpty else { return [] }
        
        let grouped = Dictionary(grouping: games, by: { $0.round })
        let keys = grouped.keys.sorted()
        
        return keys.map { r in
            let roundGames = (grouped[r] ?? []).sorted { $0.sort < $1.sort }
            
            return SERoundGamesView.Round(
                games: roundGames.map { mapGame($0, teams: teams, resByGame: resByGame) },
                round: r
            )
        }
    }
    
    static func mapGame(
        _ game: DoubleEliminationGame,
        teams: [Team],
        resByGame: [String: DoubleEliminationGameResult]
    ) -> SEGameView.Game {
        SEGameView.Game(
            gameId: game.id,
            team1: mapSlot(game.slot1, teams: teams, resByGame: resByGame, current: resByGame[game.id]),
            team2: mapSlot(game.slot2, teams: teams, resByGame: resByGame, current: resByGame[game.id])
        )
    }
    
    static func mapSlot(
        _ slot: DoubleEliminationGame.DoubleEliminationSlot,
        teams: [Team],
        resByGame: [String: DoubleEliminationGameResult],
        current: DoubleEliminationGameResult?
    ) -> SETeamView.Team? {
        switch slot {
        case .team(let id):
            let name = teams.first(where: { $0.id == id })?.name ?? id
            let isWinner: Bool? = {
                guard let r = current else { return nil }
                if r.winnerTeamId == id { return true }
                if r.loserTeamId == id { return false }
                return nil
            }()
            return SETeamView.Team(teamId: id, teamName: name, isWinner: isWinner, isBye: false)
        case .winnerOf(let gid):
            guard let r = resByGame[gid] else { return nil }
            let id = r.winnerTeamId
            let name = teams.first(where: { $0.id == id })?.name ?? id
            let isWinner: Bool? = {
                guard let cur = current else { return nil }
                if cur.winnerTeamId == id { return true }
                if cur.loserTeamId == id { return false }
                return nil
            }()
            return SETeamView.Team(teamId: id, teamName: name, isWinner: isWinner, isBye: false)
        case .loserOf(let gid):
            guard let r = resByGame[gid], let id = r.loserTeamId else { return nil }
            let name = teams.first(where: { $0.id == id })?.name ?? id
            let isWinner: Bool? = {
                guard let cur = current else { return nil }
                if cur.winnerTeamId == id { return true }
                if cur.loserTeamId == id { return false }
                return nil
            }()
            return SETeamView.Team(teamId: id, teamName: name, isWinner: isWinner, isBye: false)
        case .bye:
            return SETeamView.Team(
                teamId: "bye",
                teamName: "DoubleElimination.Bye".localized,
                isWinner: nil,
                isBye: true
            )
        }
    }
}
