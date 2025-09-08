//
//  CreateBracketViewModel.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 06.09.2025.
//

import RxSwift
import RxCocoa

final class CreateBracketViewModel {
    enum Action {
        case selectPreset(TournamentPreset)
        case openInfo
    }
    
    private let initialPreset: Driver<TournamentPreset?>
    
    init(preset: TournamentPreset?) {
        self.initialPreset = BehaviorRelay(value: preset).asDriver()
    }
}

// MARK: Public
extension CreateBracketViewModel {
    struct Input {
        let didTapSelectPreset: Signal<Void>
        let didSelectPreset: Signal<TournamentPreset>
        let didTapInfo: Signal<Void>
    }
    
    struct Output {
        let preset: Driver<TournamentPreset>
        let action: Driver<Action>
    }
    
    func configure(input: Input) -> Output {
        let currentPreset = makeCurrentPreset(
            initialPreset: initialPreset,
            didSelectPreset: input.didSelectPreset
        )
        
        return Output(
            preset: currentPreset,
            action: makeAction(
                didTapSelectPreset: input.didTapSelectPreset,
                currentPreset: currentPreset,
                didTapInfo: input.didTapInfo
            )
        )
    }
}

// MARK: Private
private extension CreateBracketViewModel {
    func makeCurrentPreset(
        initialPreset: Driver<TournamentPreset?>,
        didSelectPreset: Signal<TournamentPreset>
    ) -> Driver<TournamentPreset> {
        Driver
            .merge(
                initialPreset.map { $0 ?? .none },
                didSelectPreset.asDriver(onErrorDriveWith: .never())
            )
    }
    
    func makeAction(
        didTapSelectPreset: Signal<Void>,
        currentPreset: Driver<TournamentPreset>,
        didTapInfo: Signal<Void>
    ) -> Driver<Action> {
        let selectPreset = didTapSelectPreset
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(currentPreset)
            .map { Action.selectPreset($0) }
        
        let openInfo = didTapInfo
            .map { Action.openInfo }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(selectPreset, openInfo)
    }
}
