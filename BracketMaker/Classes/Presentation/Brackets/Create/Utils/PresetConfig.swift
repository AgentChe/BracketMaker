//
//  PresetConfig.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 11.09.2025.
//

struct PresetConfig {
    let config: [TournamentPreset: (CBBracketTypeItemButton.BracketType, Int)] = [
        .baseball: (.doubleElimination, 8),
        .basketball: (.singleElimination, 32),
        .football: (.singleElimination, 16),
        .tennis: (.singleElimination, 8),
        .joystick: (.roundRobin, 4),
        .none: (.singleElimination, 3)
    ]
}
