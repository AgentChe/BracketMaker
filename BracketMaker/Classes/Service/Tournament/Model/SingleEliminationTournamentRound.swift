//
//  SingleEliminationTournamentRound.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 05.09.2025.
//

import GRDB

struct SingleEliminationTournamentRound: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let singleEliminationId: String
    let gamesIds: [String]
    let round: Int
    let createdAt: TimeInterval
}
