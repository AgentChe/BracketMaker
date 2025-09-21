//
//  DoubleEliminationResult.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 21.09.2025.
//

import GRDB

struct DoubleEliminationResult: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let doubleEliminationId: String
    let winner: String
}
