//
//  TeamManager.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 24.08.2025.
//

import RxSwift
import GRDB

protocol TeamManagerProtocol {
    func createTeam(name: String) -> Single<Team>
    func delete(teamId: String) -> Single<String>
    func fetchTeams() -> Single<[Team]>
}

final class TeamManager {
    private let dbQueue: DatabaseQueue
    
    init() {
        let fileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("bracketmaker.sqlite")
        do {
            dbQueue = try DatabaseQueue(path: fileURL.path)
            try migrator.migrate(dbQueue)
        } catch {
            fatalError("Error initializing database: \(error)")
        }
    }
}

// MARK: TeamManagerProtocol
extension TeamManager: TeamManagerProtocol {
    func createTeam(name: String) -> Single<Team> {
        Single.create { single in
            let team = Team(
                id: UUID().uuidString,
                name: name,
                createdAt: Date().timeIntervalSince1970
            )
            do {
                try self.dbQueue.write { db in
                    try team.insert(db)
                }
                single(.success(team))
                
                TeamMediator.shared.created(team: team)
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    func delete(teamId: String) -> Single<String> {
        Single.create { single in
            do {
                _ = try self.dbQueue.write { db in
                    try Team.deleteOne(db, key: teamId)
                }
                single(.success(teamId))
                
                TeamMediator.shared.deleted(teamId: teamId)
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    func fetchTeams() -> Single<[Team]> {
        Single.create { single in
            do {
                let teams = try self.dbQueue.read { db in
                    try Team.fetchAll(db)
                }
                single(.success(teams))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
}

// MARK: Private
private extension TeamManager {
    var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        migrator.registerMigration("createTables") { db in
            try db.create(table: "Team") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("createdAt", .double).notNull()
            }
        }
        return migrator
    }
}
