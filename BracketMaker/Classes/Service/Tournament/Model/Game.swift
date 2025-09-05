//
//  Game.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 05.09.2025.
//

import GRDB

struct Game: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let team1Id: String
    let team2Id: String?
    let sort: Int 
    let createdAt: TimeInterval
}
