//
//  RoundRobinResult.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 14.09.2025.
//

import GRDB

struct RoundRobinResult: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let roundRobinId: String
    let winner: String
    let createdAt: TimeInterval
}
