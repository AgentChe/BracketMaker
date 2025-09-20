//
//  SingleEliminationViewController.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 18.09.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class SingleEliminationViewController: UIViewController {
    private lazy var mainView = SingleEliminationView()
    
    private let viewModel: SingleEliminationViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didConfirmDeleteTrigger = PublishRelay<Void>()
    
    private init(singleElimination: SingleElimination) {
        viewModel = SingleEliminationViewModel(singleElimination: singleElimination)
        
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
        
        let output = viewModel.configure(input: SingleEliminationViewModel.Input(
            didTapDelete: mainView.bottomView.deleteButton.rx.tap.asSignal(),
            didConfirmDelete: didConfirmDeleteTrigger.asSignal(),
            didSelectWinner: mainView.tournamentView.didSelectWinner
        ))
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
        
        output.tournament
            .drive(Binder(mainView.tournamentView) { base, tournament in
                base.setup(tournament: tournament)
            })
            .disposed(by: disposeBag)
        
        output
            .selectWinnerPlaceholderHidden
            .drive(mainView.selectWinnerPlaceholder.rx.isHidden)
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension SingleEliminationViewController {
    static func make(singleElimination: SingleElimination) -> SingleEliminationViewController {
        let vc = SingleEliminationViewController(singleElimination: singleElimination)
        vc.navigationItem.title = singleElimination.name
        return vc
    }
}

// MARK: Private
private extension SingleEliminationViewController {
    func action(_ action: SingleEliminationViewModel.Action) {
        switch action {
        case .requestConfirmDelete:
            let vc = RRConfirmDeleteViewController.make { [weak self] yes in
                if yes {
                    self?.didConfirmDeleteTrigger.accept(Void())
                }
            }
            present(vc, animated: false)
        case .close:
            navigationController?.popViewController(animated: true)
        }
    }
}
