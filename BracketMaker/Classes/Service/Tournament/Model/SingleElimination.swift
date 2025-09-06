//
//  SingleElimination.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 05.09.2025.
//

import GRDB

struct SingleElimination: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let name: String
    let teamsIds: [String]
    let preset: String?
    let createdAt: TimeInterval
}
