//
//  TournamentMediator.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 05.09.2025.
//

import RxSwift
import RxCocoa

final class TournamentMediator {
    static let shared = TournamentMediator()
    
    private lazy var didCreatedGameResultTrigger = PublishRelay<GameResult>()
    private lazy var didCreatedSingleEliminationTrigger = PublishRelay<SingleElimination>()
    private lazy var didCreatedSingleEliminationResultTrigger = PublishRelay<SingleEliminationResult>()
    private lazy var didCreatedSingleEliminationTournamentRoundTrigger = PublishRelay<SingleEliminationTournamentRound>()
    
    private init() {}
}

// MARK: Public
extension TournamentMediator {
    func created(gameResult: GameResult) {
        didCreatedGameResultTrigger.accept(gameResult)
    }
    
    func created(singleElimination: SingleElimination) {
        didCreatedSingleEliminationTrigger.accept(singleElimination)
    }
    
    func created(singleEliminationResult: SingleEliminationResult) {
        didCreatedSingleEliminationResultTrigger.accept(singleEliminationResult)
    }
    
    func created(singleEliminationTournamentRound: SingleEliminationTournamentRound) {
        didCreatedSingleEliminationTournamentRoundTrigger.accept(singleEliminationTournamentRound)
    }
    
    var didCreatedGameResult: Signal<GameResult> {
        didCreatedGameResultTrigger.asSignal()
    }
    
    var didCreatedSingleElimination: Signal<SingleElimination> {
        didCreatedSingleEliminationTrigger.asSignal()
    }
    
    var didCreatedSingleEliminationResult: Signal<SingleEliminationResult> {
        didCreatedSingleEliminationResultTrigger.asSignal()
    }
    
    var didCreatedSingleEliminationTournamentRound: Signal<SingleEliminationTournamentRound> {
        didCreatedSingleEliminationTournamentRoundTrigger.asSignal()
    }
}
