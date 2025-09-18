//
//  SingleElimination.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 18.09.2025.
//

import GRDB

struct SingleElimination: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let name: String
    let createdAt: TimeInterval
}
