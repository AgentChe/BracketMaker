//
//  MainViewController.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 22.08.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class MainViewController: UIViewController {
    private lazy var mainView = MainView()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var coordinator = MainViewCoordinator(
        parentVC: self,
        container: mainView.container
    )
    
    private let requestReview: Bool
    
    private init(requestReview: Bool) {
        self.requestReview = requestReview
        
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
        
        Signal
            .merge([
                mainView.tabView.homeItemButton
                    .rx.tap.map { MainTabItemButton.Tab.home }
                    .asSignal(onErrorSignalWith: .never()),
                
                mainView.tabView.teamsItemButton
                    .rx.tap.map { MainTabItemButton.Tab.teams }
                    .asSignal(onErrorSignalWith: .never()),
                
                mainView.tabView.settingsItemButton
                    .rx.tap.map { MainTabItemButton.Tab.settings }
                    .asSignal(onErrorSignalWith: .never())
            ])
            .emit(to: Binder(self) { base, tab in
                base.update(selectedTab: tab)
            })
            .disposed(by: disposeBag)
        
        mainView.tabView.createBracketButton.rx.tap
            .bind(to: Binder(self) { base, void in
                print("create bracket") // TODO
            })
            .disposed(by: disposeBag)
        
        rx.methodInvoked(#selector(UIViewController.viewDidLayoutSubviews))
            .take(1)
            .bind(to: Binder(self) { base, void in
                base.update(selectedTab: .home)
            })
            .disposed(by: disposeBag)
        
        if requestReview {
            RequestReview.request()
        }
    }
}

// MARK: Make
extension MainViewController {
    static func make(requestReview: Bool) -> NavigationController {
        let vc = MainViewController(requestReview: requestReview)
        vc.navigationItem.backButtonTitle = " "
        
        return NavigationController(rootViewController: vc)
    }
}
 
// MARK: Private
private extension MainViewController {
    func update(selectedTab: MainTabItemButton.Tab) {
        mainView.tabView.selectedTab = selectedTab
        
        coordinator.change(tab: selectedTab)
    }
}
