//
//  RoundRobinViewController.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 16.09.2025.
//

import UIKit
import RxSwift
import RxCocoa

// TODO:
// 1. Share
// 4. Create RR Result
final class RoundRobinViewController: UIViewController {
    private lazy var mainView = RoundRobinView()
    
    private let viewModel: RoundRobinViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didConfirmDeleteTrigger = PublishRelay<Void>()
    
    private init(roundRobin: RoundRobin) {
        viewModel = RoundRobinViewModel(roundRobin: roundRobin)
        
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
        
        let output = viewModel.configure(input: RoundRobinViewModel.Input(
            didSelectGameElement: mainView.tableView.didSelectGameElement,
            didTapDelete: mainView.bottomView.deleteButton.rx.tap.asSignal(),
            didConfirmDelete: didConfirmDeleteTrigger.asSignal()
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
    }
}

// MARK: Public
extension RoundRobinViewController {
    static func make(roundRobin: RoundRobin) -> RoundRobinViewController {
        let vc = RoundRobinViewController(roundRobin: roundRobin)
        vc.navigationItem.title = roundRobin.name
        return vc
    }
}

// MARK: Private
private extension RoundRobinViewController {
    func action(_ action: RoundRobinViewModel.Action) {
        switch action {
        case .createGameResult(let gameId):
            let vc = CreateRRGameResultViewController.make(gameId: gameId)
            present(vc, animated: false)
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
