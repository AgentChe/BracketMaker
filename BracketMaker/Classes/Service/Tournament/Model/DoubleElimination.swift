//
//  DoubleElimination.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 21.09.2025.
//

import GRDB

struct DoubleElimination: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let name: String
    let createdAt: TimeInterval
}
