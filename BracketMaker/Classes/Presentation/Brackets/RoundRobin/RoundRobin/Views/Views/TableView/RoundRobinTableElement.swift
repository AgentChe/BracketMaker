//
//  RoundRobinTableElement.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 16.09.2025.
//

enum RoundRobinTableElement {
    case game(RoundRobinTableGameElement)
}

struct RoundRobinTableGameElement {
    let gameId: String
    let team1: RoundRobinTeamView.Team
    let team2: RoundRobinTeamView.Team
}
