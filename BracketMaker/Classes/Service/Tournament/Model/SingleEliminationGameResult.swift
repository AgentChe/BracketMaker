//
//  SingleEliminationGameResult.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 18.09.2025.
//

import GRDB

struct SingleEliminationGameResult: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let gameId: String
    let winnerTeamId: String
    let loserTeamId: String?
}
