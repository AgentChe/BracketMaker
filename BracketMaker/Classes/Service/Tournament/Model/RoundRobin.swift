//
//  RoundRobin.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 14.09.2025.
//

import GRDB

struct RoundRobin: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let name: String
    let teamsIds: [String]
    let createdAt: TimeInterval
}
