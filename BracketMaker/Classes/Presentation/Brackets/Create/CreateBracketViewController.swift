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
    private lazy var didSelectTeamTrigger = PublishRelay<(Team, TeamPosition)>()
    
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
            didTapInfo: infoButton.rx.tap.asSignal(),
            didSelectBracketType: mainView.bracketTypesView.didSelect,
            didChangeNumberTeams: mainView.numberTeamsView.didChange,
            didChangeName: mainView.nameField.rx.text
                .compactMap { $0 }
                .asSignal(onErrorSignalWith: .never()),
            didTapShuffle: mainView.teamsHeaderView.shuffleButton.rx.tap.asSignal(),
            didTapTeamPosition: mainView.tableView.didSelect,
            didSelectTeam: didSelectTeamTrigger.asSignal(),
            didTapCreate: mainView.createButton.rx.tap.asSignal()
        ))
        
        output.preset
            .drive(Binder(mainView) { base, preset in
                base.presetButton.setup(preset: preset)
                
                if let numberItems = PresetConfig().config[preset]?.1 {
                    base.numberTeamsView.numberPicker.selectValue(numberItems, animated: false)
                }
            })
            .disposed(by: disposeBag)
        
        output.currentBracketType
            .drive(Binder(mainView.bracketTypesView) { base, bracketType in
                base.setup(bracketType: bracketType)
            })
            .disposed(by: disposeBag)
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
        
        output.canCreate
            .drive(Binder(mainView) { base, canCreate in
                base.setup(canCreate: canCreate)
            })
            .disposed(by: disposeBag)
        
        output.canShuffle
            .drive(Binder(mainView.teamsHeaderView) { base, canShuffle in
                base.shuffleButton.isHidden = !canShuffle
            })
            .disposed(by: disposeBag)
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
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
        case .selectTeam(let args):
            let (teamPosition, teamsIds) = args
            
            let vc = SelectTeamViewController.make(disableTeams: teamsIds) { [weak self] team in
                self?.didSelectTeamTrigger.accept((team, teamPosition))
            }
            present(vc, animated: true)
        case .openPaygate:
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        case .close:
            navigationController?.popViewController(animated: true)
        }
    }
}
