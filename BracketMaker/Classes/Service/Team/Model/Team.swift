//
//  Team.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 24.08.2025.
//

import GRDB

struct Team: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let name: String
    let createdAt: TimeInterval
}
