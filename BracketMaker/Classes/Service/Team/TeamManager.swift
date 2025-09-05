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
    private lazy var dbQueue = Database.shared.dbQueue()
}

// MARK: TeamManagerProtocol
extension TeamManager: TeamManagerProtocol {
    func createTeam(name: String) -> Single<Team> {
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }
            
            let team = Team(
                id: UUID().uuidString,
                name: name,
                createdAt: Date().timeIntervalSince1970
            )
            do {
                try dbQueue.write { db in
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
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }
            
            do {
                _ = try dbQueue.write { db in
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
        Single.create { [weak self] single in
            guard let self, let dbQueue = self.dbQueue else {
                single(.failure(ContentError(.notContent)))
                return Disposables.create()
            }
            
            do {
                let teams = try dbQueue.read { db in
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
