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
    func createGames(array: [
        (team1Id: String,
         team2Id: String,
         sort: Int)
    ]) -> Single<[Game]>
    func fetchGames(ids: [String]) -> Single<[Game]>
    
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
    func fetchSingleEliminationsResults(singleEliminationsIds: [String]) -> Single<[SingleEliminationResult]>
    func createSingleEliminationTournamentRound(
        singleEliminationId: String,
        gamesIds: [String],
        round: Int
    ) -> Single<SingleEliminationTournamentRound>
    func fetchSingleEliminationTournamentRounds(singleEliminationId: String) -> Single<[SingleEliminationTournamentRound]>
    func createSingleEliminationGameResult(
        gameId: String,
        winnerTeamId: String,
        loserTeamId: String?
    ) -> Single<SingleEliminationGameResult>
    func fetchSingleEliminationGamesResults(gamesIds: [String]) -> Single<[SingleEliminationGameResult]>
    
    func createRoundRobin(
        name: String,
        teamsIds: [String]
    ) -> Single<RoundRobin>
    func delete(roundRobinId: String) -> Single<Void>
    func fetchRoundRobins() -> Single<[RoundRobin]>
    func createRoundRobinGames(
        roundRobinId: String,
        gamesIds: [String]
    ) -> Single<RoundRobinGames>
    func fetchRoundRobinGames(roundRobinId: String) -> Single<RoundRobinGames>
    func createRoundRobinGameResult(
        gameId: String,
        team1GoalsFor: Int,
        team1GoalsAgainst: Int,
        team2GoalsFor: Int,
        team2GoalsAgainst: Int
    ) -> Single<RoundRobinGameResult>
    func fetchRoundRobinGamesResults(gamesIds: [String]) -> Single<[RoundRobinGameResult]>
    func create(
        roundRobinId: String,
        winner: String
    ) -> Single<RoundRobinResult>
    func fetchRoundRobinResult(roundRobinId: String) -> Single<RoundRobinResult?>
    func fetchRoundRobinsResults(roundRobinsIds: [String]) -> Single<[RoundRobinResult]>
    
    func tournamentsTotalCount() -> Single<Int>
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

    func createGames(array: [
        (team1Id: String, team2Id: String, sort: Int)
    ]) -> Single<[Game]> {
        if array.isEmpty { return .just([]) }

        return Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }

            let baseTime = Date().timeIntervalSince1970
            let games: [Game] = array.enumerated().map { idx, item in
                Game(
                    id: UUID().uuidString,
                    team1Id: item.team1Id,
                    team2Id: item.team2Id,
                    sort: item.sort,
                    createdAt: baseTime + TimeInterval(idx) * 1e-6
                )
            }

            do {
                try dbQueue.write { db in
                    for game in games {
                        try game.insert(db)
                    }
                    // Если в цикле упадёт throw — весь write откатится одной транзакцией.
                }
                single(.success(games))
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

    func createSingleElimination(
        name: String,
        teamsIds: [String],
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
    
    func fetchSingleEliminationsResults(singleEliminationsIds: [String]) -> Single<[SingleEliminationResult]> {
        if singleEliminationsIds.isEmpty { return .just([]) }
        
        return Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }
            
            do {
                let results = try dbQueue.read { db -> [SingleEliminationResult] in
                    try SingleEliminationResult
                        .filter(singleEliminationsIds.contains(Column("singleEliminationId")))
                        .fetchAll(db)
                }
                single(.success(results))
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
    
    func createSingleEliminationGameResult(
        gameId: String,
        winnerTeamId: String,
        loserTeamId: String?
    ) -> Single<SingleEliminationGameResult> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }
            
            let result = SingleEliminationGameResult(
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
                
                TournamentMediator.shared.created(singleEliminationGameResult: result)
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
    
    func fetchSingleEliminationGamesResults(gamesIds: [String]) -> Single<[SingleEliminationGameResult]> {
        if gamesIds.isEmpty { return .just([]) }
        
        return Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }
            
            do {
                let results = try dbQueue.read { db -> [SingleEliminationGameResult] in
                    try SingleEliminationGameResult
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

    func createRoundRobin(
        name: String,
        teamsIds: [String]
    ) -> Single<RoundRobin> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }

            let item = RoundRobin(
                id: UUID().uuidString,
                name: name,
                teamsIds: teamsIds,
                createdAt: Date().timeIntervalSince1970
            )

            do {
                try dbQueue.write { db in
                    try item.insert(db)
                }
                single(.success(item))
                
                TournamentMediator.shared.created(roundRobin: item)
            } catch {
                single(.failure(error))
            }

            return Disposables.create()
        }
    }
    
    func delete(roundRobinId: String) -> Single<Void> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }

            do {
                try dbQueue.write { db in
                    let exists = try RoundRobin
                        .filter(Column("id") == roundRobinId)
                        .fetchCount(db) > 0
                    guard exists else { throw ContentError(.notContent) }

                    let rrGames = try RoundRobinGames
                        .filter(Column("roundRobinId") == roundRobinId)
                        .fetchOne(db)
                    let gamesIds = rrGames?.gamesIds ?? []

                    if !gamesIds.isEmpty {
                        try RoundRobinGameResult
                            .filter(gamesIds.contains(Column("gameId")))
                            .deleteAll(db)
                        try Game
                            .filter(gamesIds.contains(Column("id")))
                            .deleteAll(db)
                    }

                    try RoundRobinGames
                        .filter(Column("roundRobinId") == roundRobinId)
                        .deleteAll(db)

                    try RoundRobinResult
                        .filter(Column("roundRobinId") == roundRobinId)
                        .deleteAll(db)

                    try RoundRobin
                        .filter(Column("id") == roundRobinId)
                        .deleteAll(db)
                }

                single(.success(()))
                
                TournamentMediator.shared.deleted(roundRobinId: roundRobinId)
            } catch {
                single(.failure(error))
            }

            return Disposables.create()
        }
    }

    func fetchRoundRobins() -> Single<[RoundRobin]> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }

            do {
                let items = try dbQueue.read { db -> [RoundRobin] in
                    try RoundRobin
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

    func createRoundRobinGames(
        roundRobinId: String,
        gamesIds: [String]
    ) -> Single<RoundRobinGames> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }

            let item = RoundRobinGames(
                id: UUID().uuidString,
                roundRobinId: roundRobinId,
                gamesIds: gamesIds,
                createdAt: Date().timeIntervalSince1970
            )

            do {
                try dbQueue.write { db in
                    try item.insert(db)
                }
                single(.success(item))
            } catch {
                single(.failure(error))
            }

            return Disposables.create()
        }
    }

    func fetchRoundRobinGames(roundRobinId: String) -> Single<RoundRobinGames> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }

            do {
                let item = try dbQueue.read { db -> RoundRobinGames? in
                    try RoundRobinGames
                        .filter(Column("roundRobinId") == roundRobinId)
                        .fetchOne(db)
                }
                if let item { single(.success(item)) }
                else { single(.failure(ContentError(.notContent))) }
            } catch {
                single(.failure(error))
            }

            return Disposables.create()
        }
    }

    func createRoundRobinGameResult(
        gameId: String,
        team1GoalsFor: Int,
        team1GoalsAgainst: Int,
        team2GoalsFor: Int,
        team2GoalsAgainst: Int
    ) -> Single<RoundRobinGameResult> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }

            let res = RoundRobinGameResult(
                id: UUID().uuidString,
                gameId: gameId,
                team1GoalsFor: team1GoalsFor,
                team1GoalsAgainst: team1GoalsAgainst,
                team2GoalsFor: team2GoalsFor,
                team2GoalsAgainst: team2GoalsAgainst,
                createdAt: Date().timeIntervalSince1970
            )

            do {
                try dbQueue.write { db in
                    try res.insert(db)
                }
                single(.success(res))
                
                TournamentMediator.shared.created(roundRobinGameResult: res)
            } catch {
                single(.failure(error))
            }

            return Disposables.create()
        }
    }

    func fetchRoundRobinGamesResults(gamesIds: [String]) -> Single<[RoundRobinGameResult]> {
        if gamesIds.isEmpty { return .just([]) }

        return Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }

            do {
                let results = try dbQueue.read { db -> [RoundRobinGameResult] in
                    try RoundRobinGameResult
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

    func create(
        roundRobinId: String,
        winner: String
    ) -> Single<RoundRobinResult> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }

            let result = RoundRobinResult(
                id: UUID().uuidString,
                roundRobinId: roundRobinId,
                winner: winner,
                createdAt: Date().timeIntervalSince1970
            )

            do {
                try dbQueue.write { db in
                    try result.insert(db)
                }
                single(.success(result))
                
                TournamentMediator.shared.created(roundRobinResult: result)
            } catch {
                single(.failure(error))
            }

            return Disposables.create()
        }
    }

    func fetchRoundRobinResult(roundRobinId: String) -> Single<RoundRobinResult?> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }

            do {
                let res = try dbQueue.read { db -> RoundRobinResult? in
                    try RoundRobinResult
                        .filter(Column("roundRobinId") == roundRobinId)
                        .fetchOne(db)
                }
                single(.success(res))
            } catch {
                single(.failure(error))
            }

            return Disposables.create()
        }
    }

    func fetchRoundRobinsResults(roundRobinsIds: [String]) -> Single<[RoundRobinResult]> {
        if roundRobinsIds.isEmpty { return .just([]) }

        return Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }

            do {
                let results = try dbQueue.read { db -> [RoundRobinResult] in
                    try RoundRobinResult
                        .filter(roundRobinsIds.contains(Column("roundRobinId")))
                        .fetchAll(db)
                }
                single(.success(results))
            } catch {
                single(.failure(error))
            }

            return Disposables.create()
        }
    }
    
    // TODO: добавить Double Elimination
    func tournamentsTotalCount() -> Single<Int> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }

            do {
                let total = try dbQueue.read { db -> Int in
                    let seCount = try SingleElimination.fetchCount(db)
                    let rrCount = try RoundRobin.fetchCount(db)
                    return seCount + rrCount
                }
                single(.success(total))
            } catch {
                single(.failure(error))
            }

            return Disposables.create()
        }
    }
}
