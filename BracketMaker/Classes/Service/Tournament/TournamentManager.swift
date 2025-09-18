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
    func fetchSingleEliminations() -> Single<[SingleElimination]>
    func createSingleEliminationGames(
        singleEliminationId: String,
        initialTeams: [String]
    ) -> Single<[SingleEliminationGame]>
    func fetchSingleEliminationGames(singleEliminationId: String) -> Single<[SingleEliminationGame]>
    func setWinnerForSingleEliminationGame(
        gameId: String,
        winnerTeamId: String
    ) -> Single<SingleEliminationGameResult>
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
    ) -> Single<SingleEliminationGameResult> {
        Single.create { [weak self] s in
            guard let self, let dbQueue = self.dbQueue else {
                s(.failure(ContentError(.notContent)))
                return Disposables.create()
            }
            
            do {
                let result: SingleEliminationGameResult = try dbQueue.write { db in
                    if let exists: SingleEliminationGameResult = try SingleEliminationGameResult
                        .filter(Column("gameId") == gameId).fetchOne(db) {
                        return exists
                    }

                    guard var game = try SingleEliminationGame.fetchOne(db, key: gameId) else {
                        throw ContentError(.notContent)
                    }

                    func id(from team: SingleEliminationGame.Team) -> String? {
                        if case let .team(x) = team { return x } else { return nil }
                    }
                    guard let t1 = id(from: game.team1) ?? id(from: game.team2) else {
                        throw ContentError(.notContent)
                    }
                    let bothTeams = (id(from: game.team1), id(from: game.team2))
                    guard bothTeams.0 != nil && bothTeams.1 != nil else {
                        throw ContentError(.notContent)
                    }

                    let loserId: String = {
                        if id(from: game.team1) == winnerTeamId {
                            return id(from: game.team2)!
                        } else { return id(from: game.team1)! }
                    }()

                    let res = SingleEliminationGameResult(
                        id: UUID().uuidString,
                        gameId: game.id,
                        winnerTeamId: winnerTeamId,
                        loserTeamId: loserId
                    )
                    try res.insert(db)
                    TournamentMediator.shared.created(singleEliminationGameResult: res)

                    let parentRound = game.round + 1
                    if let parent = try SingleEliminationGame
                        .filter(Column("singleEliminationId") == game.singleEliminationId &&
                                Column("round") == parentRound &&
                                Column("sort") == game.sort / 2)
                        .fetchOne(db) {

                        let putToTeam1 = (game.sort % 2 == 0)
                        let updated = SingleEliminationGame(
                            id: parent.id,
                            singleEliminationId: parent.singleEliminationId,
                            sort: parent.sort,
                            round: parent.round,
                            team1: putToTeam1 ? .team(winnerTeamId) : parent.team1,
                            team2: putToTeam1 ? parent.team2 : .team(winnerTeamId),
                            createdAt: parent.createdAt
                        )
                        try updated.update(db)
                    } else {
                        let tournamentRes = SingleEliminationResult(
                            id: UUID().uuidString,
                            singleEliminationId: game.singleEliminationId,
                            winner: winnerTeamId
                        )
                        try tournamentRes.insert(db)
                        TournamentMediator.shared.created(singleEliminationResult: tournamentRes)
                    }
                    return res
                }
                s(.success(result))
            } catch {
                s(.failure(error))
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
}
