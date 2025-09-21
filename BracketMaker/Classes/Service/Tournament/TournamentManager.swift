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
    
    func createSingleElimination(name: String) -> Single<SingleElimination>
    func delete(singleEliminationId: String) -> Single<Void>
    func fetchSingleEliminations() -> Single<[SingleElimination]>
    func createSingleEliminationGames(
        singleEliminationId: String,
        initialTeams: [String]
    ) -> Single<[SingleEliminationGame]>
    func fetchSingleEliminationGames(singleEliminationId: String) -> Single<[SingleEliminationGame]>
    func setWinnerForSingleEliminationGame(
        gameId: String,
        winnerTeamId: String
    ) -> Single<(SingleEliminationGameResult, SingleEliminationResult?)>
    func fetchSingleEliminationGamesResults(gamesIds: [String]) -> Single<[SingleEliminationGameResult]>
    func fetchSingleEliminationResult(singleEliminationId: String) -> Single<SingleEliminationResult?>
    func fetchSingleEliminationsResults(singleEliminationsIds: [String]) -> Single<[SingleEliminationResult]>
    
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
    
    func createDoubleElimination(name: String) -> Single<DoubleElimination>
    func delete(doubleEliminationId: String) -> Single<Void>
    func fetchDoubleEliminations() -> Single<[DoubleElimination]>
    func createDoubleEliminationParticipants(
        doubleEliminationId: String,
        teamsIds: [String]
    ) -> Single<[DoubleEliminationParticipant]>
    func fetchDoubleEliminationParticipants(doubleEliminationId: String) -> Single<[DoubleEliminationParticipant]>
    func createDoubleEliminationGames(doubleEliminationId: String) -> Single<[DoubleEliminationGame]>
    func fetchDoubleEliminationGames(doubleEliminationId: String) -> Single<[DoubleEliminationGame]>
    func setWinnerForDoubleEliminationGame(
        gameId: String,
        winnerTeamId: String
    ) -> Single<(DoubleEliminationGameResult, DoubleEliminationResult?)>
    func fetchDoubleEliminationGamesResults(gamesIds: [String]) -> Single<[DoubleEliminationGameResult]>
    func fetchDoubleEliminationResult(doubleEliminationId: String) -> Single<DoubleEliminationResult?>
    func fetchDoubleEliminationsResults(doubleEliminationsIds: [String]) -> Single<[DoubleEliminationResult]>
    
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
    
    func createSingleElimination(name: String) -> Single<SingleElimination> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }
            
            let item = SingleElimination(
                id: UUID().uuidString,
                name: name,
                createdAt: Date().timeIntervalSince1970
            )
            
            do {
                try dbQueue.write { db in
                    try item.insert(db)
                }
                
                single(.success(item))
                
                TournamentMediator.shared.created(singleElimination: item)
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    func delete(singleEliminationId: String) -> Single<Void> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }

            do {
                try dbQueue.write { db in
                    let exists = try SingleElimination
                        .filter(Column("id") == singleEliminationId)
                        .fetchCount(db) > 0
                    guard exists else { throw ContentError(.notContent) }

                    let gameIds = try SingleEliminationGame
                        .filter(Column("singleEliminationId") == singleEliminationId)
                        .fetchAll(db)
                        .map { $0.id }

                    if !gameIds.isEmpty {
                        try SingleEliminationGameResult
                            .filter(gameIds.contains(Column("gameId")))
                            .deleteAll(db)
                    }

                    try SingleEliminationGame
                        .filter(Column("singleEliminationId") == singleEliminationId)
                        .deleteAll(db)

                    try SingleEliminationResult
                        .filter(Column("singleEliminationId") == singleEliminationId)
                        .deleteAll(db)

                    try SingleElimination
                        .filter(Column("id") == singleEliminationId)
                        .deleteAll(db)
                }

                single(.success(()))
                TournamentMediator.shared.deleted(singleEliminationId: singleEliminationId)
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
                let items = try dbQueue.read { db in
                    try SingleElimination.order(Column("createdAt").desc).fetchAll(db)
                }
                single(.success(items))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func createSingleEliminationGames(
        singleEliminationId: String,
        initialTeams: [String]
    ) -> Single<[SingleEliminationGame]> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }

            func nextPow2(_ n: Int) -> Int {
                var p = 1
                while p < max(1,n) {
                    p <<= 1
                }
                return p
            }
            let slots = nextPow2(initialTeams.count)
            let byes = max(0, slots - initialTeams.count)
            let participants: [SingleEliminationGame.Team] = initialTeams.map { .team($0) } + Array(repeating: .bye, count: byes)

            let now = Date().timeIntervalSince1970
            var games: [SingleEliminationGame] = []

            var sort = 0
            for i in stride(from: 0, to: slots, by: 2) {
                games.append(SingleEliminationGame(
                    id: UUID().uuidString,
                    singleEliminationId: singleEliminationId,
                    sort: sort,
                    round: 0,
                    team1: participants[i],
                    team2: participants[i+1],
                    createdAt: now + TimeInterval(sort) * 1e-6
                ))
                sort += 1
            }

            var gamesInRound = slots / 4
            var round = 1
            while gamesInRound > 0 {
                for j in 0..<gamesInRound {
                    games.append(SingleEliminationGame(
                        id: UUID().uuidString,
                        singleEliminationId: singleEliminationId,
                        sort: j,
                        round: round,
                        team1: .scheduled,
                        team2: .scheduled,
                        createdAt: now + 10 + TimeInterval(round*100 + j) * 1e-6
                    ))
                }
                round += 1
                gamesInRound >>= 1
            }

            do {
                try dbQueue.write { db in
                    for g in games { try g.insert(db) }
                    try self.autoAdvanceByes(db: db, singleEliminationId: singleEliminationId)
                }
                single(.success(games.sorted { ($0.round,$0.sort) < ($1.round,$1.sort) }))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func fetchSingleEliminationGames(singleEliminationId: String) -> Single<[SingleEliminationGame]> {
        Single.create { [weak self] s in
            guard let self, let dbQueue = self.dbQueue else {
                s(.failure(ContentError(.notContent)))
                return Disposables.create()
            }
            do {
                let items = try dbQueue.read { db in
                    try SingleEliminationGame
                        .filter(Column("singleEliminationId") == singleEliminationId)
                        .order(Column("round").asc, Column("sort").asc)
                        .fetchAll(db)
                }
                s(.success(items))
            } catch { s(.failure(error)) }
            return Disposables.create()
        }
    }

    func setWinnerForSingleEliminationGame(
        gameId: String,
        winnerTeamId: String
    ) -> Single<(SingleEliminationGameResult, SingleEliminationResult?)> {
        Single.create { [weak self] s in
            guard let self, let dbQueue = self.dbQueue else {
                s(.failure(ContentError(.notContent)))
                return Disposables.create()
            }

            var createdNew = false
            var tournamentResToNotify: SingleEliminationResult? = nil

            do {
                let tuple = try dbQueue.write { db -> (SingleEliminationGameResult, SingleEliminationResult?) in
                    if let exists: SingleEliminationGameResult = try SingleEliminationGameResult
                        .filter(Column("gameId") == gameId)
                        .fetchOne(db) {
                        return (exists, nil)
                    }

                    guard let game = try SingleEliminationGame.fetchOne(db, key: gameId) else {
                        throw ContentError(.notContent)
                    }

                    func id(from t: SingleEliminationGame.Team) -> String? {
                        if case let .team(x) = t { return x } else { return nil }
                    }
                    guard let team1Id = id(from: game.team1),
                          let team2Id = id(from: game.team2) else {
                        throw ContentError(.notContent)
                    }
                    guard winnerTeamId == team1Id || winnerTeamId == team2Id else {
                        throw ContentError(.notContent)
                    }

                    let loserId = (winnerTeamId == team1Id) ? team2Id : team1Id

                    let res = SingleEliminationGameResult(
                        id: UUID().uuidString,
                        gameId: game.id,
                        winnerTeamId: winnerTeamId,
                        loserTeamId: loserId
                    )
                    try res.insert(db)
                    createdNew = true

                    let parentRound = game.round + 1
                    let parentSort = game.sort / 2

                    if let parent = try SingleEliminationGame
                        .filter(Column("singleEliminationId") == game.singleEliminationId &&
                                Column("round") == parentRound &&
                                Column("sort") == parentSort)
                        .fetchOne(db) {

                        let putToTeam1 = (game.sort % 2 == 0)
                        let updatedParent = SingleEliminationGame(
                            id: parent.id,
                            singleEliminationId: parent.singleEliminationId,
                            sort: parent.sort,
                            round: parent.round,
                            team1: putToTeam1 ? .team(winnerTeamId) : parent.team1,
                            team2: putToTeam1 ? parent.team2 : .team(winnerTeamId),
                            createdAt: parent.createdAt
                        )
                        try updatedParent.update(db)

                        return (res, nil)
                    } else {
                        let tournamentRes = SingleEliminationResult(
                            id: UUID().uuidString,
                            singleEliminationId: game.singleEliminationId,
                            winner: winnerTeamId
                        )
                        try tournamentRes.insert(db)
                        tournamentResToNotify = tournamentRes
                        return (res, tournamentRes)
                    }
                }

                s(.success(tuple)) 

                // затем уведомления
                if createdNew {
                    TournamentMediator.shared.created(singleEliminationGameResult: tuple.0)
                    if let tr = tournamentResToNotify {
                        TournamentMediator.shared.created(singleEliminationResult: tr)
                    }
                }
            } catch {
                s(.failure(error))
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
                        .fetchAll(db)
                }
                single(.success(results))
            } catch {
                single(.failure(error))
            }

            return Disposables.create()
        }
    }
    
    func fetchSingleEliminationResult(singleEliminationId: String) -> Single<SingleEliminationResult?> {
        Single.create { [weak self] s in
            guard let self, let dbQueue = self.dbQueue else {
                s(.failure(ContentError(.notContent)))
                return Disposables.create()
            }
            
            do {
                let res = try dbQueue.read { db in
                    try SingleEliminationResult
                        .filter(Column("singleEliminationId") == singleEliminationId)
                        .fetchOne(db)
                }
                s(.success(res))
            } catch { s(.failure(error)) }
            return Disposables.create()
        }
    }
    
    func fetchSingleEliminationsResults(singleEliminationsIds: [String]) -> Single<[SingleEliminationResult]> {
        if singleEliminationsIds.isEmpty { return .just([]) }
        
        return Single.create { [weak self] s in
            guard let self, let dbQueue = self.dbQueue else {
                s(.failure(ContentError(.notContent)))
                return Disposables.create()
            }
            
            do {
                let results = try dbQueue.read { db in
                    try SingleEliminationResult
                        .filter(singleEliminationsIds.contains(Column("singleEliminationId")))
                        .fetchAll(db)
                }
                s(.success(results))
            } catch {
                s(.failure(error))
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
    
    func createDoubleElimination(name: String) -> Single<DoubleElimination> {
        Single.create { [weak self] s in
            guard let self, let dbQueue = self.dbQueue else {
                s(.failure(ContentError(.notContent))); return Disposables.create()
            }
            let de = DoubleElimination(id: UUID().uuidString, name: name, createdAt: Date().timeIntervalSince1970)
            do {
                try dbQueue.write { db in try de.insert(db) }
                s(.success(de))
                
                TournamentMediator.shared.created(doubleElimination: de)
            } catch { s(.failure(error)) }
            return Disposables.create()
        }
    }

    func delete(doubleEliminationId: String) -> Single<Void> {
        Single.create { [weak self] s in
            guard let self, let dbQueue = self.dbQueue else {
                s(.failure(ContentError(.notContent))); return Disposables.create()
            }
            do {
                try dbQueue.write { db in
                    guard try DoubleElimination.filter(Column("id") == doubleEliminationId).fetchCount(db) > 0
                    else { throw ContentError(.notContent) }

                    let gameIds = try DoubleEliminationGame
                        .filter(Column("doubleEliminationId") == doubleEliminationId)
                        .fetchAll(db).map { $0.id }

                    if !gameIds.isEmpty {
                        try DoubleEliminationGameResult
                            .filter(gameIds.contains(Column("gameId"))).deleteAll(db)
                    }

                    try DoubleEliminationGame
                        .filter(Column("doubleEliminationId") == doubleEliminationId).deleteAll(db)
                    try DoubleEliminationParticipant
                        .filter(Column("doubleEliminationId") == doubleEliminationId).deleteAll(db)
                    try DoubleEliminationResult
                        .filter(Column("doubleEliminationId") == doubleEliminationId).deleteAll(db)
                    try DoubleElimination
                        .filter(Column("id") == doubleEliminationId).deleteAll(db)
                }
                s(.success(()))
                
                TournamentMediator.shared.deleted(doubleEliminationId: doubleEliminationId)
            } catch { s(.failure(error)) }
            return Disposables.create()
        }
    }

    func fetchDoubleEliminations() -> Single<[DoubleElimination]> {
        Single.create { [weak self] s in
            guard let self, let dbQueue = self.dbQueue else {
                s(.failure(ContentError(.notContent))); return Disposables.create()
            }
            do {
                let items = try dbQueue.read { db in
                    try DoubleElimination.order(Column("createdAt").desc).fetchAll(db)
                }
                s(.success(items))
            } catch { s(.failure(error)) }
            return Disposables.create()
        }
    }

    func createDoubleEliminationParticipants(
        doubleEliminationId: String,
        teamsIds: [String]
    ) -> Single<[DoubleEliminationParticipant]> {
        if teamsIds.isEmpty { return .just([]) }
        return Single.create { [weak self] s in
            guard let self, let dbQueue = self.dbQueue else {
                s(.failure(ContentError(.notContent))); return Disposables.create()
            }
            let t0 = Date().timeIntervalSince1970
            let parts = teamsIds.enumerated().map { i, t in
                DoubleEliminationParticipant(
                    id: UUID().uuidString,
                    doubleEliminationId: doubleEliminationId,
                    teamId: t,
                    seed: i + 1,
                    createdAt: t0 + TimeInterval(i) * 1e-6
                )
            }
            do {
                try dbQueue.write { db in
                    for p in parts { try p.insert(db) }
                }
                s(.success(parts))
            } catch { s(.failure(error)) }
            return Disposables.create()
        }
    }

    func fetchDoubleEliminationParticipants(doubleEliminationId: String) -> Single<[DoubleEliminationParticipant]> {
        Single.create { [weak self] s in
            guard let self, let dbQueue = self.dbQueue else {
                s(.failure(ContentError(.notContent))); return Disposables.create()
            }
            do {
                let items = try dbQueue.read { db in
                    try DoubleEliminationParticipant
                        .filter(Column("doubleEliminationId") == doubleEliminationId)
                        .order(Column("seed").asc)
                        .fetchAll(db)
                }
                s(.success(items))
            } catch { s(.failure(error)) }
            return Disposables.create()
        }
    }

    func createDoubleEliminationGames(doubleEliminationId: String) -> Single<[DoubleEliminationGame]> {
        Single.create { [weak self] s in
            guard let self, let dbQueue = self.dbQueue else {
                s(.failure(ContentError(.notContent))); return Disposables.create()
            }
            do {
                let games = try dbQueue.write { db -> [DoubleEliminationGame] in
                    let parts = try DoubleEliminationParticipant
                        .filter(Column("doubleEliminationId") == doubleEliminationId)
                        .order(Column("seed").asc)
                        .fetchAll(db)

                    let teamIds = parts.map { $0.teamId }
                    let n = teamIds.count
                    guard n >= 2 else { throw ContentError(.notContent) }

                    func nextPow2(_ x: Int) -> Int { var p = 1; while p < x { p <<= 1 }; return p }
                    let slots = nextPow2(n)
                    let pad = slots - n
                    
                    // Для пары 1..S: i vs S-1-i
                    var roundGames: [[DoubleEliminationGame]] = []
                    var allGames: [DoubleEliminationGame] = []
                    let t0 = Date().timeIntervalSince1970

                    // Winners R0
                    var winnersR0: [DoubleEliminationGame] = []
                    for i in 0..<(slots/2) {
                        let aIdx = i
                        let bIdx = slots - 1 - i
                        let a = aIdx < n ? DoubleEliminationGame.DoubleEliminationSlot.team(teamIds[aIdx]) : .bye
                        let b = bIdx < n ? DoubleEliminationGame.DoubleEliminationSlot.team(teamIds[bIdx]) : .bye
                        let g = DoubleEliminationGame(
                            id: UUID().uuidString,
                            doubleEliminationId: doubleEliminationId,
                            sort: i,
                            round: 0,
                            bracket: .winner,
                            slot1: a,
                            slot2: b,
                            createdAt: t0 + TimeInterval(i) * 1e-6
                        )
                        winnersR0.append(g)
                    }
                    try winnersR0.forEach { try $0.insert(db) }
                    roundGames.append(winnersR0)
                    allGames.append(contentsOf: winnersR0)

                    // Winners next rounds
                    var prev = winnersR0
                    var winnersRounds: [[DoubleEliminationGame]] = [winnersR0]
                    var wRound = 1
                    while prev.count > 1 {
                        var cur: [DoubleEliminationGame] = []
                        for i in 0..<(prev.count/2) {
                            let g = DoubleEliminationGame(
                                id: UUID().uuidString,
                                doubleEliminationId: doubleEliminationId,
                                sort: i,
                                round: wRound,
                                bracket: .winner,
                                slot1: .winnerOf(prev[2*i].id),
                                slot2: .winnerOf(prev[2*i+1].id),
                                createdAt: t0 + 10 + TimeInterval(wRound*100+i) * 1e-6
                            )
                            cur.append(g)
                        }
                        try cur.forEach { try $0.insert(db) }
                        winnersRounds.append(cur)
                        roundGames.append(cur)
                        allGames.append(contentsOf: cur)
                        prev = cur
                        wRound += 1
                    }
                    let winnersFinal = winnersRounds.last!    // 1 игра

                    // Losers bracket
                    // L0: losers of adjacent W0 pairs
                    var losersRounds: [[DoubleEliminationGame]] = []
                    if winnersRounds.count >= 2 {
                        var L0: [DoubleEliminationGame] = []
                        for i in 0..<(winnersRounds[0].count/2) {
                            let g = DoubleEliminationGame(
                                id: UUID().uuidString,
                                doubleEliminationId: doubleEliminationId,
                                sort: i,
                                round: 0,
                                bracket: .loser,
                                slot1: .loserOf(winnersRounds[0][2*i].id),
                                slot2: .loserOf(winnersRounds[0][2*i+1].id),
                                createdAt: t0 + 20 + TimeInterval(i) * 1e-6
                            )
                            L0.append(g)
                        }
                        try L0.forEach { try $0.insert(db) }
                        losersRounds.append(L0); allGames.append(contentsOf: L0)

                        // For r = 1 .. k-2
                        if winnersRounds.count > 2 {
                            for r in 1..<(winnersRounds.count - 1) {
                                // odd: winners of previous L vs loser of W_r
                                let prevL = losersRounds.last!
                                var Lodd: [DoubleEliminationGame] = []
                                for i in 0..<winnersRounds[r].count {
                                    let g = DoubleEliminationGame(
                                        id: UUID().uuidString,
                                        doubleEliminationId: doubleEliminationId,
                                        sort: i,
                                        round: 2*r - 1,
                                        bracket: .loser,
                                        slot1: .winnerOf(prevL[i].id),
                                        slot2: .loserOf(winnersRounds[r][i].id),
                                        createdAt: t0 + 30 + TimeInterval(r*100 + i) * 1e-6
                                    )
                                    Lodd.append(g)
                                }
                                try Lodd.forEach { try $0.insert(db) }
                                losersRounds.append(Lodd); allGames.append(contentsOf: Lodd)

                                // even: winners of Lodd in pairs
                                var Leven: [DoubleEliminationGame] = []
                                for i in 0..<(Lodd.count/2) {
                                    let g = DoubleEliminationGame(
                                        id: UUID().uuidString,
                                        doubleEliminationId: doubleEliminationId,
                                        sort: i,
                                        round: 2*r,
                                        bracket: .loser,
                                        slot1: .winnerOf(Lodd[2*i].id),
                                        slot2: .winnerOf(Lodd[2*i+1].id),
                                        createdAt: t0 + 40 + TimeInterval(r*100 + i) * 1e-6
                                    )
                                    Leven.append(g)
                                }
                                try Leven.forEach { try $0.insert(db) }
                                losersRounds.append(Leven); allGames.append(contentsOf: Leven)
                            }
                        }

                        // Last L round: winner of previous L vs loser of winners final
                        let prevL = losersRounds.last!
                        let Llast = DoubleEliminationGame(
                            id: UUID().uuidString,
                            doubleEliminationId: doubleEliminationId,
                            sort: 0,
                            round: max(1, (losersRounds.count) * 1),
                            bracket: .loser,
                            slot1: .winnerOf(prevL.last!.id),
                            slot2: .loserOf(winnersFinal.first!.id),
                            createdAt: t0 + 50
                        )
                        try Llast.insert(db)
                        losersRounds.append([Llast]); allGames.append(Llast)
                    }

                    // Grand Final: winner WB vs winner LB
                    let grandFinal = DoubleEliminationGame(
                        id: UUID().uuidString,
                        doubleEliminationId: doubleEliminationId,
                        sort: 0,
                        round: winnersRounds.count, // после финала WB
                        bracket: .winner,
                        slot1: .winnerOf(winnersFinal.first!.id),
                        slot2: .winnerOf(losersRounds.last!.first!.id),
                        createdAt: t0 + 60
                    )
                    try grandFinal.insert(db)
                    allGames.append(grandFinal)

                    // авто-проходы по bye в W0
                    try self.de_autoAdvanceByes(db: db, doubleEliminationId: doubleEliminationId)

                    return allGames
                }
                s(.success(games.sorted { ($0.bracket.rawValue, $0.round, $0.sort) < ($1.bracket.rawValue, $1.round, $1.sort) }))
            } catch { s(.failure(error)) }
            return Disposables.create()
        }
    }

    func fetchDoubleEliminationGames(doubleEliminationId: String) -> Single<[DoubleEliminationGame]> {
        Single.create { [weak self] s in
            guard let self, let dbQueue = self.dbQueue else {
                s(.failure(ContentError(.notContent))); return Disposables.create()
            }
            do {
                let items = try dbQueue.read { db in
                    try DoubleEliminationGame
                        .filter(Column("doubleEliminationId") == doubleEliminationId)
                        .order(Column("bracket").asc, Column("round").asc, Column("sort").asc)
                        .fetchAll(db)
                }
                s(.success(items))
            } catch { s(.failure(error)) }
            return Disposables.create()
        }
    }

    func setWinnerForDoubleEliminationGame(
        gameId: String,
        winnerTeamId: String
    ) -> Single<(DoubleEliminationGameResult, DoubleEliminationResult?)> {
        Single.create { [weak self] s in
            guard let self, let dbQueue = self.dbQueue else {
                s(.failure(ContentError(.notContent))); return Disposables.create()
            }
            var createdNew = false
            var tournamentResToNotify: DoubleEliminationResult? = nil
            do {
                let tuple = try dbQueue.write { db -> (DoubleEliminationGameResult, DoubleEliminationResult?) in
                    if let existed: DoubleEliminationGameResult = try DoubleEliminationGameResult
                        .filter(Column("gameId") == gameId).fetchOne(db) { return (existed, nil) }

                    guard let game = try DoubleEliminationGame.fetchOne(db, key: gameId) else {
                        throw ContentError(.notContent)
                    }
                    func teamId(from slot: DoubleEliminationGame.DoubleEliminationSlot) -> String? {
                        if case let .team(id) = slot { return id } else { return nil }
                    }
                    guard let t1 = teamId(from: game.slot1),
                          let t2 = teamId(from: game.slot2) else { throw ContentError(.notContent) }
                    guard winnerTeamId == t1 || winnerTeamId == t2 else { throw ContentError(.notContent) }
                    let loserId = (winnerTeamId == t1) ? t2 : t1

                    let res = DoubleEliminationGameResult(
                        id: UUID().uuidString,
                        gameId: game.id,
                        winnerTeamId: winnerTeamId,
                        loserTeamId: loserId
                    )
                    try res.insert(db)
                    createdNew = true

                    try self.de_propagate(db: db, doubleEliminationId: game.doubleEliminationId,
                                          sourceGameId: game.id,
                                          winnerTeamId: winnerTeamId,
                                          loserTeamId: loserId)

                    let hasNextWinnerRef = try self.de_hasWinnerReference(db: db, gameId: game.id)
                    if !hasNextWinnerRef {
                        let tr = DoubleEliminationResult(
                            id: UUID().uuidString,
                            doubleEliminationId: game.doubleEliminationId,
                            winner: winnerTeamId
                        )
                        try tr.insert(db)
                        tournamentResToNotify = tr
                        return (res, tr)
                    }
                    return (res, nil)
                }
                s(.success(tuple))
                if createdNew {
                    TournamentMediator.shared.created(doubleEliminationGameResult: tuple.0)
                    if let tr = tournamentResToNotify {
                        TournamentMediator.shared.created(doubleEliminationResult: tr)
                    }
                }
            } catch { s(.failure(error)) }
            return Disposables.create()
        }
    }

    func fetchDoubleEliminationGamesResults(gamesIds: [String]) -> Single<[DoubleEliminationGameResult]> {
        if gamesIds.isEmpty { return .just([]) }
        return Single.create { [weak self] s in
            guard let self, let dbQueue = self.dbQueue else {
                s(.failure(ContentError(.notContent))); return Disposables.create()
            }
            do {
                let items = try dbQueue.read { db in
                    try DoubleEliminationGameResult
                        .filter(gamesIds.contains(Column("gameId")))
                        .fetchAll(db)
                }
                s(.success(items))
            } catch { s(.failure(error)) }
            return Disposables.create()
        }
    }

    func fetchDoubleEliminationResult(doubleEliminationId: String) -> Single<DoubleEliminationResult?> {
        Single.create { [weak self] s in
            guard let self, let dbQueue = self.dbQueue else {
                s(.failure(ContentError(.notContent))); return Disposables.create()
            }
            do {
                let res = try dbQueue.read { db in
                    try DoubleEliminationResult
                        .filter(Column("doubleEliminationId") == doubleEliminationId)
                        .fetchOne(db)
                }
                s(.success(res))
            } catch { s(.failure(error)) }
            return Disposables.create()
        }
    }

    func fetchDoubleEliminationsResults(doubleEliminationsIds: [String]) -> Single<[DoubleEliminationResult]> {
        if doubleEliminationsIds.isEmpty { return .just([]) }
        return Single.create { [weak self] s in
            guard let self, let dbQueue = self.dbQueue else {
                s(.failure(ContentError(.notContent))); return Disposables.create()
            }
            do {
                let res = try dbQueue.read { db in
                    try DoubleEliminationResult
                        .filter(doubleEliminationsIds.contains(Column("doubleEliminationId")))
                        .fetchAll(db)
                }
                s(.success(res))
            } catch { s(.failure(error)) }
            return Disposables.create()
        }
    }
    
    func tournamentsTotalCount() -> Single<Int> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent))); return Disposables.create()
            }
            do {
                let total = try dbQueue.read { db -> Int in
                    let se = try SingleElimination.fetchCount(db)
                    let rr = try RoundRobin.fetchCount(db)
                    let de = try DoubleElimination.fetchCount(db) 
                    return se + rr + de
                }
                single(.success(total))
            } catch { single(.failure(error)) }
            return Disposables.create()
        }
    }
}

// MARK: Additional
private extension TournamentManager {
    func autoAdvanceByes(db: GRDB.Database, singleEliminationId: String) throws {
        let firstRound = try SingleEliminationGame
            .filter(Column("singleEliminationId") == singleEliminationId && Column("round") == 0)
            .order(Column("sort").asc)
            .fetchAll(db)

        for game in firstRound {
            switch (game.team1, game.team2) {
            case (.team(let t1), .bye):
                try advanceByeWinner(db: db, game: game, winnerId: t1)
            case (.bye, .team(let t2)):
                try advanceByeWinner(db: db, game: game, winnerId: t2)
            default:
                break
            }
        }
    }

    func advanceByeWinner(db: GRDB.Database, game: SingleEliminationGame, winnerId: String) throws {
        if try SingleEliminationGameResult
            .filter(Column("gameId") == game.id)
            .fetchOne(db) == nil
        {
            let res = SingleEliminationGameResult(
                id: UUID().uuidString,
                gameId: game.id,
                winnerTeamId: winnerId,
                loserTeamId: "BYE"
            )
            try res.insert(db)
            TournamentMediator.shared.created(singleEliminationGameResult: res)
        }

        let parentRound = game.round + 1
        let parentSort = game.sort / 2

        guard let parent = try SingleEliminationGame
            .filter(Column("singleEliminationId") == game.singleEliminationId &&
                    Column("round") == parentRound &&
                    Column("sort") == parentSort)
            .fetchOne(db)
        else { return }

        let putToTeam1 = (game.sort % 2 == 0)
        let updatedParent = SingleEliminationGame(
            id: parent.id,
            singleEliminationId: parent.singleEliminationId,
            sort: parent.sort,
            round: parent.round,
            team1: putToTeam1 ? .team(winnerId) : parent.team1,
            team2: putToTeam1 ? parent.team2 : .team(winnerId),
            createdAt: parent.createdAt
        )
        try updatedParent.update(db)
    }
    
    func de_autoAdvanceByes(db: GRDB.Database, doubleEliminationId: String) throws {
        let games = try DoubleEliminationGame
            .filter(Column("doubleEliminationId") == doubleEliminationId &&
                    Column("bracket") == DoubleEliminationGame.Bracket.winner &&
                    Column("round") == 0)
            .order(Column("sort").asc)
            .fetchAll(db)

        for g in games {
            let s1 = g.slot1, s2 = g.slot2
            switch (s1, s2) {
            case (.team(let t), .bye), (.bye, .team(let t)):
                if try DoubleEliminationGameResult
                    .filter(Column("gameId") == g.id)
                    .fetchOne(db) == nil
                {
                    let res = DoubleEliminationGameResult(
                        id: UUID().uuidString,
                        gameId: g.id,
                        winnerTeamId: t,
                        loserTeamId: nil
                    )
                    try res.insert(db)
                    
                    TournamentMediator.shared.created(doubleEliminationGameResult: res)
                    
                    try de_propagate(db: db, doubleEliminationId: g.doubleEliminationId,
                                     sourceGameId: g.id,
                                     winnerTeamId: t,
                                     loserTeamId: nil)
                }
            default: break
            }
        }
        // После проставления bye возможны новые bye в L-играх; прогоняем цикл до стабилизации
        var progressed = true
        while progressed {
            progressed = false
            let all = try DoubleEliminationGame
                .filter(Column("doubleEliminationId") == doubleEliminationId)
                .fetchAll(db)
            for g in all {
                guard try DoubleEliminationGameResult
                        .filter(Column("gameId") == g.id).fetchOne(db) == nil else { continue }
                if case let .team(t1) = g.slot1, case .bye = g.slot2 {
                    let res = DoubleEliminationGameResult(id: UUID().uuidString, gameId: g.id, winnerTeamId: t1, loserTeamId: nil)
                    try res.insert(db); progressed = true
                    
                    TournamentMediator.shared.created(doubleEliminationGameResult: res)
                    
                    try de_propagate(db: db, doubleEliminationId: g.doubleEliminationId,
                                     sourceGameId: g.id, winnerTeamId: t1, loserTeamId: nil)
                } else if case .bye = g.slot1, case let .team(t2) = g.slot2 {
                    let res = DoubleEliminationGameResult(id: UUID().uuidString, gameId: g.id, winnerTeamId: t2, loserTeamId: nil)
                    try res.insert(db); progressed = true
                    
                    TournamentMediator.shared.created(doubleEliminationGameResult: res)
                    
                    try de_propagate(db: db, doubleEliminationId: g.doubleEliminationId,
                                     sourceGameId: g.id, winnerTeamId: t2, loserTeamId: nil)
                }
            }
        }
    }

    func de_hasWinnerReference(db: GRDB.Database, gameId: String) throws -> Bool {
        let all = try DoubleEliminationGame.fetchAll(db)
        return all.contains { g in
            switch g.slot1 {
            case .winnerOf(let id): if id == gameId { return true }
            default: break
            }
            switch g.slot2 {
            case .winnerOf(let id): if id == gameId { return true }
            default: break
            }
            return false
        }
    }

    func de_propagate(
        db: GRDB.Database,
        doubleEliminationId: String,
        sourceGameId: String,
        winnerTeamId: String,
        loserTeamId: String?
    ) throws {
        var changedAny = false
        let targets = try DoubleEliminationGame
            .filter(Column("doubleEliminationId") == doubleEliminationId)
            .fetchAll(db)

        // helper to replace slot
        func replace(_ slot: DoubleEliminationGame.DoubleEliminationSlot,
                     winner: String, loser: String?) -> DoubleEliminationGame.DoubleEliminationSlot {
            switch slot {
            case .winnerOf(let id) where id == sourceGameId:
                return .team(winner)
            case .loserOf(let id) where id == sourceGameId:
                if let loser { return .team(loser) } else { return .bye }
            default:
                return slot
            }
        }

        for g in targets {
            let ns1 = replace(g.slot1, winner: winnerTeamId, loser: loserTeamId)
            let ns2 = replace(g.slot2, winner: winnerTeamId, loser: loserTeamId)
            if case let (a, b) = (ns1, ns2), !(String(describing: a) == String(describing: g.slot1) &&
                                               String(describing: b) == String(describing: g.slot2)) {
                let upd = DoubleEliminationGame(
                    id: g.id,
                    doubleEliminationId: g.doubleEliminationId,
                    sort: g.sort,
                    round: g.round,
                    bracket: g.bracket,
                    slot1: ns1,
                    slot2: ns2,
                    createdAt: g.createdAt
                )
                try upd.update(db)
                changedAny = true
            }
        }

        if changedAny {
            try de_autoAdvanceByes(db: db, doubleEliminationId: doubleEliminationId)
        }
    }
}
