//
//  DoubleEliminationGame.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 21.09.2025.
//

import GRDB

struct DoubleEliminationGame: Codable, Identifiable, FetchableRecord, PersistableRecord {
    enum DoubleEliminationSlot: Codable {
        case team(String) // исходная команда
        case winnerOf(String) // id игры, победитель идёт сюда
        case loserOf(String) // id игры, проигравший идёт сюда
        case bye
    }
    
    enum Bracket: String, Codable, DatabaseValueConvertible {
        case winner, loser
    }
    
    let id: String
    let doubleEliminationId: String
    let sort: Int
    let round: Int
    let bracket: Bracket
    let slot1: DoubleEliminationSlot
    let slot2: DoubleEliminationSlot
    let createdAt: TimeInterval
}
