//
//  DoubleEliminationViewController.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 21.09.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class DoubleEliminationViewController: UIViewController {
    private lazy var mainView = DoubleEliminationView()
    
    private let viewModel: DoubleEliminationViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didConfirmDeleteTrigger = PublishRelay<Void>()
    
    private init(doubleElimination: DoubleElimination) {
        viewModel = DoubleEliminationViewModel(doubleElimination: doubleElimination)
        
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
        
        let output = viewModel.configure(input: DoubleEliminationViewModel.Input(
            didTapDelete: mainView.bottomView.deleteButton.rx.tap.asSignal(),
            didConfirmDelete: didConfirmDeleteTrigger.asSignal(),
            didSelectWinner: mainView.tournamentView.didSelectWinner,
            didTapShare: mainView.bottomView.shareButton.rx.tap.asSignal()
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
extension DoubleEliminationViewController {
    static func make(doubleElimination: DoubleElimination) -> DoubleEliminationViewController {
        let vc = DoubleEliminationViewController(doubleElimination: doubleElimination)
        vc.navigationItem.title = doubleElimination.name
        return vc
    }
}

// MARK: Private
private extension DoubleEliminationViewController {
    func action(_ action: DoubleEliminationViewModel.Action) {
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
        case .share(let url):
            let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            present(vc, animated: true)
        }
    }
}
