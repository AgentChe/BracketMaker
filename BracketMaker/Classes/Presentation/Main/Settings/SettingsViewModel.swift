//
//  SettingsViewModel.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 22.08.2025.
//

import RxSwift
import RxCocoa

final class SettingsViewModel {
    enum Action {
        case openUrl(URL)
        case openPaygate
    }
}

// MARK: Public
extension SettingsViewModel {
    struct Input {
        let didTapRoute: Signal<SettingsRouteButton.Route>
        let didTapPaygate: Signal<Void>
    }
    
    struct Output {
        let action: Driver<Action>
        let activeSubscription: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        Output(
            action: makeAction(
                didTapRoute: input.didTapRoute,
                didTapPaygate: input.didTapPaygate
            ),
            activeSubscription: makeActiveSubscription()
        )
    }
}

// MARK: Private
private extension SettingsViewModel {
    func makeAction(
        didTapRoute: Signal<SettingsRouteButton.Route>,
        didTapPaygate: Signal<Void>
    ) -> Driver<Action> {
        let openUrl = didTapRoute
            .map { route -> Action in
                switch route {
                case .termsOfUse:
                    return Action.openUrl(GlobalDefinitions.termsOfServiceUrl)
                case .privacyPolicy:
                    return Action.openUrl(GlobalDefinitions.privacyPolicyUrl)
                case .contactSupport:
                    return Action.openUrl(GlobalDefinitions.contactUsUrl)
                }
            }
            .asDriver(onErrorDriveWith: .never())
        
        let openPaygate = didTapPaygate
            .map { Action.openPaygate }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(openUrl, openPaygate)
    }
    
    func makeActiveSubscription() -> Driver<Bool> {
        PurchaseValidationObserver.shared
            .didValidatedWithActiveSubscription
            .map { SessionManager().hasActiveSubscriptions() }
            .startWith(SessionManager().hasActiveSubscriptions())
            .asDriver(onErrorJustReturn: false)
    }
}
