//
//  DoubleEliminationGameResult.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 21.09.2025.
//

import GRDB

struct DoubleEliminationGameResult: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let gameId: String
    let winnerTeamId: String
    let loserTeamId: String?
}
