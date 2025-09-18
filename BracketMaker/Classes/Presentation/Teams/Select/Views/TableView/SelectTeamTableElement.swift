//
//  SelectTeamTableElement.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 18.09.2025.
//

enum SelectTeamTableElement {
    case title
    case team(SelectTeamTableTeamElement)
}

struct SelectTeamTableTeamElement {
    let team: Team
    let canSelect: Bool
}
