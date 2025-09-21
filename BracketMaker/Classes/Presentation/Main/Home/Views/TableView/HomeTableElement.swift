//
//  HomeTableElement.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 05.09.2025.
//

import Foundation

enum HomeTableElement {
    case presets
    case addFirstBracket
    case title
    case demo
    case filter(HomeFilterItemButton.Filter)
    case bracket(HomeTableBracketElement)
}

struct HomeTableBracketElement {
    enum State {
        case inProgress
        case completed(Team)
        
        var isInProgress: Bool {
            switch self {
            case .completed:
                return false
            case .inProgress:
                return true
            }
        }
        
        var isCompleted: Bool {
            switch self {
            case .completed:
                return true
            case .inProgress:
                return false
            }
        }
    }
    
    enum Bracket {
        case singleElimination(SingleElimination)
        case doubleElimination(DoubleElimination)
        case roundRobin(RoundRobin)
        
        var createdAt: TimeInterval {
            switch self {
            case .singleElimination(let singleElimination):
                return singleElimination.createdAt
            case .doubleElimination(let doubleElimination):
                return doubleElimination.createdAt
            case .roundRobin(let roundRobin):
                return roundRobin.createdAt
            }
        }
    }
    
    let state: State
    let bracket: Bracket
}
