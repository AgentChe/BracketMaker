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
    
    private lazy var didCreatedSingleEliminationTrigger = PublishRelay<SingleElimination>()
    private lazy var didDeletedSingleEliminationTrigger = PublishRelay<String>()
    private lazy var didCreatedSingleEliminationGameResultTrigger = PublishRelay<SingleEliminationGameResult>()
    private lazy var didCreatedSingleEliminationResultTrigger = PublishRelay<SingleEliminationResult>()
    
    private lazy var didCreatedDoubleEliminationTrigger = PublishRelay<DoubleElimination>()
    private lazy var didDeletedDoubleEliminationTrigger = PublishRelay<String>()
    private lazy var didCreatedDoubleEliminationGameResultTrigger = PublishRelay<DoubleEliminationGameResult>()
    private lazy var didCreatedDoubleEliminationResultTrigger = PublishRelay<DoubleEliminationResult>()
    
    private lazy var didCreatedRoundRobinGameResultTrigger = PublishRelay<RoundRobinGameResult>()
    private lazy var didCreatedRoundRobinTrigger = PublishRelay<RoundRobin>()
    private lazy var didDeletedRoundRobinTrigger = PublishRelay<String>()
    private lazy var didCreatedRoundRobinResultTrigger = PublishRelay<RoundRobinResult>()
    
    private init() {}
}

// MARK: Public
extension TournamentMediator {
    func created(singleEliminationGameResult: SingleEliminationGameResult) {
        didCreatedSingleEliminationGameResultTrigger.accept(singleEliminationGameResult)
    }
    
    func created(singleElimination: SingleElimination) {
        didCreatedSingleEliminationTrigger.accept(singleElimination)
    }
    
    func deleted(singleEliminationId: String) {
        didDeletedSingleEliminationTrigger.accept(singleEliminationId)
    }
    
    func created(singleEliminationResult: SingleEliminationResult) {
        didCreatedSingleEliminationResultTrigger.accept(singleEliminationResult)
    }
    
    func created(doubleElimination: DoubleElimination) {
        didCreatedDoubleEliminationTrigger.accept(doubleElimination)
    }
    
    func deleted(doubleEliminationId: String) {
        didDeletedDoubleEliminationTrigger.accept(doubleEliminationId)
    }
    
    func created(doubleEliminationGameResult: DoubleEliminationGameResult) {
        didCreatedDoubleEliminationGameResultTrigger.accept(doubleEliminationGameResult)
    }
    
    func created(doubleEliminationResult: DoubleEliminationResult) {
        didCreatedDoubleEliminationResultTrigger.accept(doubleEliminationResult)
    }
    
    func created(roundRobinGameResult: RoundRobinGameResult) {
        didCreatedRoundRobinGameResultTrigger.accept(roundRobinGameResult)
    }
    
    func created(roundRobin: RoundRobin) {
        didCreatedRoundRobinTrigger.accept(roundRobin)
    }
    
    func deleted(roundRobinId: String) {
        didDeletedRoundRobinTrigger.accept(roundRobinId)
    }
    
    func created(roundRobinResult: RoundRobinResult) {
        didCreatedRoundRobinResultTrigger.accept(roundRobinResult)
    }
    
    var didCreatedSingleEliminationGameResult: Signal<SingleEliminationGameResult> {
        didCreatedSingleEliminationGameResultTrigger.asSignal()
    }
    
    var didCreatedSingleElimination: Signal<SingleElimination> {
        didCreatedSingleEliminationTrigger.asSignal()
    }
    
    var didDeletedSingleElimination: Signal<String> {
        didDeletedSingleEliminationTrigger.asSignal()
    }
    
    var didCreatedSingleEliminationResult: Signal<SingleEliminationResult> {
        didCreatedSingleEliminationResultTrigger.asSignal()
    }
    
    var didCreatedDoubleElimination: Signal<DoubleElimination> {
        didCreatedDoubleEliminationTrigger.asSignal()
    }
    
    var didDeletedDoubleElimination: Signal<String> {
        didDeletedDoubleEliminationTrigger.asSignal()
    }
    
    var didCreatedDoubleEliminationGameResult: Signal<DoubleEliminationGameResult> {
        didCreatedDoubleEliminationGameResultTrigger.asSignal()
    }
    
    var didCreatedDoubleEliminationResult: Signal<DoubleEliminationResult> {
        didCreatedDoubleEliminationResultTrigger.asSignal()
    }
    
    var didCreatedRoundRobinGameResult: Signal<RoundRobinGameResult> {
        didCreatedRoundRobinGameResultTrigger.asSignal()
    }
    
    var didCreatedRoundRobin: Signal<RoundRobin> {
        didCreatedRoundRobinTrigger.asSignal()
    }
    
    var didDeletedRoundRobin: Signal<String> {
        didDeletedRoundRobinTrigger.asSignal()
    }
    
    var didCreatedRoundRobinResult: Signal<RoundRobinResult> {
        didCreatedRoundRobinResultTrigger.asSignal()
    }
}
