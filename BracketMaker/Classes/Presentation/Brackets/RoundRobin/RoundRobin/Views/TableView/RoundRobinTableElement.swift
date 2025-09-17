//
//  RoundRobinTableElement.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 16.09.2025.
//

enum RoundRobinTableElement {
    case ptsHeader
    case ptsTeam(RoundRobinTablePtsTeamElement)
    case game(RoundRobinTableGameElement)
}

struct RoundRobinTableGameElement {
    let gameId: String
    let team1: RoundRobinTeamView.Team
    let team2: RoundRobinTeamView.Team
}

struct RoundRobinTablePtsTeamElement {
    enum Style {
        case white, gray
    }
    
    let team: Team
    let w: Int?
    let d: Int?
    let l: Int?
    let f: Int?
    let a: Int?
    let pts: Int?
    let style: Style
}
