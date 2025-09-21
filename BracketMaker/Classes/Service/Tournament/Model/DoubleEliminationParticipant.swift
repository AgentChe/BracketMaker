//
//  DoubleEliminationParticipant.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 21.09.2025.
//

import GRDB

struct DoubleEliminationParticipant: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let doubleEliminationId: String
    let teamId: String
    let seed: Int // для расстановки стартовых матчей
    let createdAt: TimeInterval
}
