//
//  GameResult.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 05.09.2025.
//

import GRDB

struct GameResult: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let gameId: String
    let winnerTeamId: String
    let loserTeamId: String?
    let createdAt: TimeInterval
}
