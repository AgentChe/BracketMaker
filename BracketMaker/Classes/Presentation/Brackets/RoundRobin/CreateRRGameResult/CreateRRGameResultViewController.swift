//
//  CreateRRGameResultViewController.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 16.09.2025.
//

import UIKit
import RxSwift

final class CreateRRGameResultViewController: UIViewController {
    private lazy var mainView = CreateRRGameResultView()
    
    private let viewModel: CreateRRGameResultViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private init(gameId: String) {
        viewModel = CreateRRGameResultViewModel(gameId: gameId)
        
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
        
        mainView.closeButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.mainView.animateDismiss {
                    base.dismiss(animated: false)
                }
            })
            .disposed(by: disposeBag)
        
        let output = viewModel.configure(input: CreateRRGameResultViewModel.Input(
            didIncrementGoalsForTeam1: mainView.goalsForView.team1ItemView.didTapIncrement,
            didDicrementGoalsForTeam1: mainView.goalsForView.team1ItemView.didTapDescrement,
            didIncrementGoalsForTeam2: mainView.goalsForView.team2ItemView.didTapIncrement,
            didDicrementGoalsForTeam2: mainView.goalsForView.team2ItemView.didTapDescrement,
            didTapSave: mainView.createButton.rx.tap.asSignal()
        ))
        
        output.goalsForTeam1
            .drive(Binder(mainView) { base, goalsFor in
                base.teamsView.team1View.setup(goalsFor: goalsFor)
                base.goalsForView.team1ItemView.setup(goalsFor: goalsFor)
            })
            .disposed(by: disposeBag)
        
        output.goalsForTeam2
            .drive(Binder(mainView) { base, goalsFor in
                base.teamsView.team2View.setup(goalsFor: goalsFor)
                base.goalsForView.team2ItemView.setup(goalsFor: goalsFor)
            })
            .disposed(by: disposeBag)
        
        output.teams
            .drive(Binder(mainView.teamsView) { base, teams in
                base.team1View.setup(teamName: teams.team1.name)
                base.team2View.setup(teamName: teams.team2.name)
            })
            .disposed(by: disposeBag)
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mainView.animateShow()
    }
}

// MARK: Public
extension CreateRRGameResultViewController {
    static func make(gameId: String) -> CreateRRGameResultViewController {
        let vc = CreateRRGameResultViewController(gameId: gameId)
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension CreateRRGameResultViewController {
    func action(_ action: CreateRRGameResultViewModel.Action) {
        switch action {
        case .close:
            mainView.animateDismiss { [weak self] in
                self?.dismiss(animated: false)
            }
        }
    }
}
