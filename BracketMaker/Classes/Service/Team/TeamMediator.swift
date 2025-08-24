//
//  TeamMediator.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 24.08.2025.
//

import RxSwift
import RxCocoa

final class TeamMediator {
    static let shared = TeamMediator()
    
    private lazy var didCreatedTeamTrigger = PublishRelay<Team>()
    private lazy var didDeletedTeamIdTrigger = PublishRelay<String>()
    
    private init() {}
}

// MARK: Public
extension TeamMediator {
    func created(team: Team) {
        didCreatedTeamTrigger.accept(team)
    }
    
    func deleted(teamId: String) {
        didDeletedTeamIdTrigger.accept(teamId)
    }
    
    var didCreatedTeam: Signal<Team> {
        didCreatedTeamTrigger.asSignal()
    }
    
    var didDeletedTeamId: Signal<String> {
        didDeletedTeamIdTrigger.asSignal()
    }
}
