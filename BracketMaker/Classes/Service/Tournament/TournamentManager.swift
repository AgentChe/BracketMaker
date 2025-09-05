//
//  TournamentManager.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 05.09.2025.
//

import GRDB
import RxSwift

protocol TournamentManagerProtocol {
    func createGame(
        team1Id: String,
        team2Id: String,
        sort: Int
    ) -> Single<Game>
    func fetchGames(ids: [String]) -> Single<[Game]>
    func createGameResult(
        gameId: String,
        winnerTeamId: String,
        loserTeamId: String?
    ) -> Single<GameResult>
    func fetchGameResult(gameId: String) -> Single<GameResult?>
    func fetchGamesResults(gamesIds: [String]) -> Single<[GameResult]>
    
    func createSingleElimination(
        name: String,
        teamsIds: [String]
    ) -> Single<SingleElimination>
    func fetchSingleEliminations() -> Single<[SingleElimination]>
    
    func createSingleEliminationResult(
        singleEliminationId: String,
        winner: String
    ) -> Single<SingleEliminationResult>
    func fetchSingleEliminationResult(singleEliminationId: String) -> Single<SingleEliminationResult?>
    
    func createSingleEliminationTournamentRound(
        singleEliminationId: String,
        gamesIds: [String],
        round: Int
    ) -> Single<SingleEliminationTournamentRound>
    func fetchSingleEliminationTournamentRounds(singleEliminationId: String) -> Single<[SingleEliminationTournamentRound]>
}

final class TournamentManager {
    private lazy var dbQueue = Database.shared.dbQueue()
}

// MARK: TournamentManagerProtocol
extension TournamentManager: TournamentManagerProtocol {
    func createGame(
        team1Id: String,
        team2Id: String,
        sort: Int
    ) -> Single<Game> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }
            
            let game = Game(
                id: UUID().uuidString,
                team1Id: team1Id,
                team2Id: team2Id,
                sort: sort,
                createdAt: Date().timeIntervalSince1970
            )
            
            do {
                try dbQueue.write { db in
                    try game.insert(db)
                }
                single(.success(game))
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }

    func fetchGames(ids: [String]) -> Single<[Game]> {
        if ids.isEmpty { return .just([]) }
        
        return Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }
            
            do {
                let games = try dbQueue.read { db -> [Game] in
                    try Game
                        .filter(ids.contains(Column("id")))
                        .order(Column("sort").asc, Column("createdAt").asc)
                        .fetchAll(db)
                }
                single(.success(games))
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }

    func createGameResult(
        gameId: String,
        winnerTeamId: String,
        loserTeamId: String?
    ) -> Single<GameResult> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }
            
            let result = GameResult(
                id: UUID().uuidString,
                gameId: gameId,
                winnerTeamId: winnerTeamId,
                loserTeamId: loserTeamId,
                createdAt: Date().timeIntervalSince1970
            )
            
            do {
                try dbQueue.write { db in
                    try result.insert(db)
                }
                single(.success(result))
                
                TournamentMediator.shared.created(gameResult: result)
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }

    func fetchGameResult(gameId: String) -> Single<GameResult?> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }
            
            do {
                let res = try dbQueue.read { db -> GameResult? in
                    try GameResult
                        .filter(Column("gameId") == gameId)
                        .fetchOne(db)
                }
                single(.success(res))
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }

    func fetchGamesResults(gamesIds: [String]) -> Single<[GameResult]> {
        if gamesIds.isEmpty { return .just([]) }
        
        return Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }
            
            do {
                let results = try dbQueue.read { db -> [GameResult] in
                    try GameResult
                        .filter(gamesIds.contains(Column("gameId")))
                        .order(Column("createdAt").asc)
                        .fetchAll(db)
                }
                single(.success(results))
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }

    func createSingleElimination(
        name: String,
        teamsIds: [String]
    ) -> Single<SingleElimination> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }
            
            let tournament = SingleElimination(
                id: UUID().uuidString,
                name: name,
                teamsIds: teamsIds,
                createdAt: Date().timeIntervalSince1970
            )
            
            do {
                try dbQueue.write { db in
                    try tournament.insert(db)
                }
                single(.success(tournament))
                
                TournamentMediator.shared.created(singleElimination: tournament)
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }

    func fetchSingleEliminations() -> Single<[SingleElimination]> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }
            
            do {
                let items = try dbQueue.read { db -> [SingleElimination] in
                    try SingleElimination
                        .order(Column("createdAt").desc)
                        .fetchAll(db)
                }
                single(.success(items))
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }

    func createSingleEliminationResult(
        singleEliminationId: String,
        winner: String
    ) -> Single<SingleEliminationResult> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }
            
            let result = SingleEliminationResult(
                id: UUID().uuidString,
                singleEliminationId: singleEliminationId,
                winner: winner,
                createdAt: Date().timeIntervalSince1970
            )
            
            do {
                try dbQueue.write { db in
                    try result.insert(db)
                }
                single(.success(result))
                
                TournamentMediator.shared.created(singleEliminationResult: result)
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }

    func fetchSingleEliminationResult(singleEliminationId: String) -> Single<SingleEliminationResult?> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }
            
            do {
                let res = try dbQueue.read { db -> SingleEliminationResult? in
                    try SingleEliminationResult
                        .filter(Column("singleEliminationId") == singleEliminationId)
                        .fetchOne(db)
                }
                single(.success(res))
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }

    func createSingleEliminationTournamentRound(
        singleEliminationId: String,
        gamesIds: [String],
        round: Int
    ) -> Single<SingleEliminationTournamentRound> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }
            
            let roundItem = SingleEliminationTournamentRound(
                id: UUID().uuidString,
                singleEliminationId: singleEliminationId,
                gamesIds: gamesIds,
                round: round,
                createdAt: Date().timeIntervalSince1970
            )
            
            do {
                try dbQueue.write { db in
                    try roundItem.insert(db)
                }
                single(.success(roundItem))
                
                TournamentMediator.shared.created(singleEliminationTournamentRound: roundItem)
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }

    func fetchSingleEliminationTournamentRounds(singleEliminationId: String) -> Single<[SingleEliminationTournamentRound]> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }
            
            do {
                let rounds = try dbQueue.read { db -> [SingleEliminationTournamentRound] in
                    try SingleEliminationTournamentRound
                        .filter(Column("singleEliminationId") == singleEliminationId)
                        .order(Column("round").asc, Column("createdAt").asc)
                        .fetchAll(db)
                }
                single(.success(rounds))
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
}
