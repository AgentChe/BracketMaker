//
//  TeamsViewController.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 24.08.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class TeamsViewController: UIViewController {
    private lazy var mainView = TeamsView()
    
    private lazy var viewModel = TeamsViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didConfirmDeleteTeamTrigger = PublishRelay<String>()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.tableView.rx.willBeginDragging
            .mapToVoid()
            .bind(to: mainView.rx.hideKeyboardObserver)
            .disposed(by: disposeBag)
        
        let output = viewModel.configure(input: TeamsViewModel.Input(
            didTapPaygate: mainView.paygateButton.rx.tap.asSignal(),
            didDeleteTeam: mainView.tableView.didDelete,
            didConfirmDeleteTeam: didConfirmDeleteTeamTrigger.asSignal(),
            didCreateTeam: mainView.createField.didCreate,
            didAttemptCreateWhenLockPaygate: mainView.createField.didAttemptCreateWhenLockPaygate
        ))
        
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
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.canCreateTeam
            .drive(Binder(mainView.createField) { base, canCreate in
                base.setup(canCreate: canCreate)
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
extension TeamsViewController {
    static func make() -> TeamsViewController {
        let vc = TeamsViewController()
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension TeamsViewController {
    func action(_ action: TeamsViewModel.Action) {
        switch action {
        case .openPaygate:
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        case .confirmDelete(let id):
            let vc = ConfirmDeleteTeamViewController.make { [weak self] yes in
                if yes {
                    self?.didConfirmDeleteTeamTrigger.accept(id)
                }
            }
            present(vc, animated: false)
        }
    }
}
