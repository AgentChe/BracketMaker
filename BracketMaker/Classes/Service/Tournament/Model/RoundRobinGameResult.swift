//
//  RoundRobinGameResult.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 14.09.2025.
//

import GRDB

struct RoundRobinGameResult: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let gameId: String
    let team1GoalsFor: Int
    let team1GoalsAgainst: Int
    let team2GoalsFor: Int
    let team2GoalsAgainst: Int
    let createdAt: TimeInterval
}
