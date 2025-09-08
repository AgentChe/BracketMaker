//
//  CreateBracketViewController.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 06.09.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class CreateBracketViewController: UIViewController {
    private lazy var mainView = CreateBracketView()
    
    private let viewModel: CreateBracketViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var infoButton = TapAreaButton()
    
    private lazy var didSelectPresetTrigger = PublishRelay<TournamentPreset>()
    
    private init(preset: TournamentPreset?) {
        viewModel = CreateBracketViewModel(preset: preset)
        
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
        
        addInfoButton()
        
        let output = viewModel.configure(input: CreateBracketViewModel.Input(
            didTapSelectPreset: mainView.presetButton.rx.tap.asSignal(),
            didSelectPreset: didSelectPresetTrigger.asSignal(),
            didTapInfo: infoButton.rx.tap.asSignal()
        ))
        
        output.preset
            .drive(Binder(mainView.presetButton) { base, preset in
                base.setup(preset: preset)
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
extension CreateBracketViewController {
    static func make(preset: TournamentPreset? = nil) -> CreateBracketViewController {
        let vc = CreateBracketViewController(preset: preset)
        vc.navigationItem.backButtonTitle = " "
        vc.navigationItem.title = "CreateBracket.Title".localized
        return vc
    }
}

// MARK: Private
private extension CreateBracketViewController {
    func addInfoButton() {
        infoButton.backgroundColor = UIColor.clear
        infoButton.setImage(UIImage(named: "CreateBracket.Info"), for: .normal)
        
        let item = UIBarButtonItem(customView: infoButton)
        item.customView?.translatesAutoresizingMaskIntoConstraints = false
        
        item.customView?.widthAnchor.constraint(equalToConstant: 24.scale).isActive = true
        item.customView?.heightAnchor.constraint(equalToConstant: 24.scale).isActive = true
        
        navigationItem.rightBarButtonItem = item
    }
    
    func action(_ action: CreateBracketViewModel.Action) {
        switch action {
        case .selectPreset(let tournamentPreset):
            let vc = PresetsViewController.make(selected: tournamentPreset) { [weak self] selected in
                self?.didSelectPresetTrigger.accept(selected)
            }
            present(vc, animated: false)
        case .openInfo:
            let vc = BracketInfoViewController.make()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
