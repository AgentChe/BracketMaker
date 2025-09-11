//
//  SelectTeamViewController.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 10.09.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class SelectTeamViewController: UIViewController {
    private lazy var mainView = SelectTeamView()
    
    private lazy var viewModel = SelectTeamViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didConfirmDeleteTeamTrigger = PublishRelay<String>()
    
    private let selected: (Team) -> Void
    
    private init(selected: @escaping (Team) -> Void) {
        self.selected = selected
        
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
        
        mainView.tableView.rx.willBeginDragging
            .mapToVoid()
            .bind(to: mainView.rx.hideKeyboardObserver)
            .disposed(by: disposeBag)
        
        let output = viewModel.configure(input: SelectTeamViewModel.Input(
            didCreateTeam: mainView.createField.didCreate,
            didAttemptCreateWhenLockPaygate: mainView.createField.didAttemptCreateWhenLockPaygate,
            didSelectTeam: mainView.tableView.didSelectTeam
        ))
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
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
}

// MARK: Public
extension SelectTeamViewController {
    static func make(selected: @escaping (Team) -> Void) -> SelectTeamViewController {
        SelectTeamViewController(selected: selected)
    }
}

// MARK: Private
private extension SelectTeamViewController {
    func action(_ action: SelectTeamViewModel.Action) {
        switch action {
        case .openPaygate:
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        case .selected(let team):
            dismiss(animated: true) { [weak self] in
                self?.selected(team)
            }
        }
    }
}
