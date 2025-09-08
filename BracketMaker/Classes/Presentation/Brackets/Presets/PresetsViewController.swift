//
//  PresetsViewController.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 07.09.2025.
//

import UIKit
import RxSwift

final class PresetsViewController: UIViewController {
    private lazy var mainView = PresetsView()
    
    private lazy var disposeBag = DisposeBag()
    
    private let initial: TournamentPreset
    private let result: (TournamentPreset) -> Void
    
    private init(selected: TournamentPreset, result: @escaping (TournamentPreset) -> Void) {
        self.initial = selected
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
        
        mainView.closeButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.mainView.animateDismiss {
                    base.dismiss(animated: false)
                }
            })
            .disposed(by: disposeBag)
        
        let selectedPreset = Observable
            .merge(
                mainView.presetsItemsButtons.map { btn in
                    btn.rx.tap.map { [preset = btn.preset] in preset }
                }
            )
            .startWith(initial)
            .asDriver(onErrorDriveWith: .never())
        
        selectedPreset
            .drive(Binder(mainView) { base, preset in
                base.setup(preset: preset)
            })
            .disposed(by: disposeBag)
        
        mainView.selectButton.rx.tap
            .withLatestFrom(selectedPreset)
            .bind(to: Binder(self) { base, preset in
                base.mainView.animateDismiss {
                    base.dismiss(animated: false) {
                        base.result(preset)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mainView.animateShow()
    }
}

// MARK: Public
extension PresetsViewController {
    static func make(selected: TournamentPreset, result: @escaping (TournamentPreset) -> Void) -> PresetsViewController {
        let vc = PresetsViewController(selected: selected, result: result)
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}
