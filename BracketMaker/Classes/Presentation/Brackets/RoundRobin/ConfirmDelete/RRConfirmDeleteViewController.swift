//
//  RRConfirmDeleteViewController.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 17.09.2025.
//

import UIKit
import RxSwift

final class RRConfirmDeleteViewController: UIViewController {
    private lazy var mainView = RRConfirmDeleteView()
    
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
extension RRConfirmDeleteViewController {
    static func make(result: @escaping (Bool) -> Void) -> RRConfirmDeleteViewController {
        let vc = RRConfirmDeleteViewController(result: result)
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension RRConfirmDeleteViewController {
    func dismiss(yes: Bool) {
        mainView.animateDismiss { [weak self] in
            self?.dismiss(animated: false) { [weak self] in
                self?.result(yes)
            }
        }
    }
}
