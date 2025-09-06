//
//  HomeViewController.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 05.09.2025.
//

import UIKit
import RxSwift

final class HomeViewController: UIViewController {
    private lazy var mainView = HomeView()
    
    private lazy var viewModel = HomeViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: HomeViewModel.Input(
            didTapPaygate: mainView.paygateButton.rx.tap.asSignal(),
            didTapPreset: mainView.tableView.didTapPreset,
            didTapAddFirstBracket: mainView.tableView.didTapAddFirstBracket,
            didChangeFilter: mainView.tableView.didChangeFilter
        ))
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
        
        output.activeSubscription
            .drive(mainView.paygateButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.activeSubscription
            .map { $0 ? 16.scale : 88.scale }
            .drive(Binder(mainView.tableView) { base, inset in
                base.contentInset.bottom = inset
            })
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
extension HomeViewController {
    static func make() -> HomeViewController {
        HomeViewController()
    }
}

// MARK: Private
private extension HomeViewController {
    func action(_ action: HomeViewModel.Action) {
        switch action {
        case .openPaygate:
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        }
    }
}
