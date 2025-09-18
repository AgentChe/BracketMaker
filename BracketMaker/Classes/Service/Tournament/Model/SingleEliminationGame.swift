//
//  SingleEliminationGame.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 18.09.2025.
//

import GRDB

struct SingleEliminationGame: Codable, Identifiable, FetchableRecord, PersistableRecord {
    enum Team: Codable {
        case bye
        case scheduled
        case team(String)
    }
    
    let id: String
    let singleEliminationId: String
    let sort: Int
    let round: Int
    let team1: Team
    let team2: Team
    let createdAt: TimeInterval
}
