//
//  RoundRobinGames.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 14.09.2025.
//

import GRDB

struct RoundRobinGames: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let roundRobinId: String
    let gamesIds: [String]
    let createdAt: TimeInterval
}
