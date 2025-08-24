//
//  SettingsViewController.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 22.08.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class SettingsViewController: UIViewController {
    private lazy var mainView = SettingsView()
    
    private lazy var viewModel = SettingsViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let didTapRoute: Signal<SettingsRouteButton.Route> = Signal
            .merge(
                mainView.termsOfUseButton.didTap,
                mainView.privacyPolicyButton.didTap,
                mainView.contactSupportButton.didTap
            )
        
        let output = viewModel.configure(input: SettingsViewModel.Input(
            didTapRoute: didTapRoute,
            didTapPaygate: mainView.paygateButton.rx.tap.asSignal()
        ))
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
        
        output.activeSubscription
            .drive(mainView.paygateButton.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

// MARK: Public
extension SettingsViewController {
    static func make() -> SettingsViewController {
        SettingsViewController()
    }
}

// MARK: Private
private extension SettingsViewController {
    func action(_ action: SettingsViewModel.Action) {
        switch action {
        case .openUrl(let url):
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        case .openPaygate:
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        }
    }
}
