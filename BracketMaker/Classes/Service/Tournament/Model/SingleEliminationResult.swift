//
//  SingleEliminationResult.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 05.09.2025.
//

import GRDB

struct SingleEliminationResult: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let singleEliminationId: String
    let winner: String
    let createdAt: TimeInterval
}
