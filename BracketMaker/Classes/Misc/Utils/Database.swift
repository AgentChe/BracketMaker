//
//  Database.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 05.09.2025.
//

import GRDB

final class Database {
    static let shared = Database()
    
    private init() {}
    
    func dbQueue() -> DatabaseQueue? {
        let fileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("bracketmaker.sqlite")
        
        do {
            let dbQueue = try DatabaseQueue(path: fileURL.path())
            try migrator.migrate(dbQueue)
            return dbQueue
        } catch {
            return nil
        }
    }
}

// MARK: Private
private extension Database {
    var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        migrator.registerMigration("createTables") { db in
            try db.create(table: "Team") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("createdAt", .double).notNull()
            }
            
            try db.create(table: "Game") { t in
                t.column("id", .text).primaryKey()
                t.column("team1Id", .text).notNull()
                t.column("team2Id", .text)
                t.column("sort", .integer).notNull()
                t.column("createdAt", .double).notNull()
            }
            try db.create(index: "idx_Game_sort_createdAt",
                          on: "Game",
                          columns: ["sort", "createdAt"])
            
            try db.create(table: "GameResult") { t in
                t.column("id", .text).primaryKey()
                t.column("gameId", .text).notNull()
                t.column("winnerTeamId", .text).notNull()
                t.column("loserTeamId", .text)
                t.column("createdAt", .double).notNull()
            }
            try db.create(index: "uq_GameResult_gameId",
                          on: "GameResult",
                          columns: ["gameId"],
                          unique: true)
            
            try db.create(table: "SingleElimination") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("teamsIds", .blob).notNull()
                t.column("preset", .text)
                t.column("createdAt", .double).notNull()
            }
            
            try db.create(table: "SingleEliminationResult") { t in
                t.column("id", .text).primaryKey()
                t.column("singleEliminationId", .text).notNull()
                t.column("winner", .text).notNull()
                t.column("createdAt", .double).notNull()
            }
            try db.create(index: "uq_SingleEliminationResult_singleEliminationId",
                          on: "SingleEliminationResult",
                          columns: ["singleEliminationId"],
                          unique: true)
            
            try db.create(table: "SingleEliminationTournamentRound") { t in
                t.column("id", .text).primaryKey()
                t.column("singleEliminationId", .text).notNull()
                t.column("gamesIds", .blob).notNull() 
                t.column("round", .integer).notNull()
                t.column("createdAt", .double).notNull()
            }
            try db.create(index: "uq_SingleEliminationTournamentRound_singleEliminationId_round",
                          on: "SingleEliminationTournamentRound",
                          columns: ["singleEliminationId", "round"],
                          unique: true)
            try db.create(index: "idx_SingleEliminationTournamentRound_singleEliminationId",
                          on: "SingleEliminationTournamentRound",
                          columns: ["singleEliminationId"])
        }
        return migrator
    }
}
