//
//  ConfirmDeleteTeamViewController.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 24.08.2025.
//

import UIKit
import RxSwift

final class ConfirmDeleteTeamViewController: UIViewController {
    private lazy var mainView = ConfirmDeleteTeamView()
    
    private lazy var disposeBag = DisposeBag()
    
    private let result: (Bool) -> Void
    
    private init(result: @escaping (Bool) -> Void) {
        self.result = result
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Observable
            .merge(
                mainView.noButton.rx.tap.map { false },
                mainView.yesButton.rx.tap.map { true }
            )
            .bind(to: Binder(self) { base, yes in
                base.dismiss(yes: yes)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mainView.animateShow()
    }
}

// MARK: Public
extension ConfirmDeleteTeamViewController {
    static func make(result: @escaping (Bool) -> Void) -> ConfirmDeleteTeamViewController {
        let vc = ConfirmDeleteTeamViewController(result: result)
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension ConfirmDeleteTeamViewController {
    func dismiss(yes: Bool) {
        mainView.animateDismiss { [weak self] in
            self?.dismiss(animated: false) { [weak self] in
                self?.result(yes)
            }
        }
    }
}
