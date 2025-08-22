//
//  MainTabItemButton.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 22.08.2025.
//

import UIKit

final class MainTabView: UIView {
    lazy var homeItemButton = makeItemButton(tab: .home)
    lazy var teamsItemButton = makeItemButton(tab: .teams)
    lazy var settingsItemButton = makeItemButton(tab: .settings)
    lazy var createBracketButton = makeCreateBracketButton()
    
    var selectedTab = MainTabItemButton.Tab.home {
        didSet {
            update()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension MainTabView {
    func initialize() {
        backgroundColor = Appearance.main600
        layer.cornerRadius = 32.scale
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.shadowColor = Appearance.mono200.withAlphaComponent(0.4).cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4.scale
    }
    
    func update() {
        homeItemButton.mode = selectedTab == .home ? .selected : .deselected
        teamsItemButton.mode = selectedTab == .teams ? .selected : .deselected
        settingsItemButton.mode = selectedTab == .settings ? .selected : .deselected
    }
}

// MARK: Make constraints
private extension MainTabView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            homeItemButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24.scale),
            homeItemButton.topAnchor.constraint(equalTo: topAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            teamsItemButton.leadingAnchor.constraint(equalTo: homeItemButton.trailingAnchor, constant: 16.scale),
            teamsItemButton.topAnchor.constraint(equalTo: topAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            settingsItemButton.leadingAnchor.constraint(equalTo: teamsItemButton.trailingAnchor, constant: 16.scale),
            settingsItemButton.topAnchor.constraint(equalTo: topAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            createBracketButton.widthAnchor.constraint(equalToConstant: 121.scale),
            createBracketButton.heightAnchor.constraint(equalToConstant: 56.scale),
            createBracketButton.leadingAnchor.constraint(equalTo: settingsItemButton.trailingAnchor, constant: 24.scale),
            createBracketButton.centerYAnchor.constraint(equalTo: settingsItemButton.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension MainTabView {
    func makeItemButton(tab: MainTabItemButton.Tab) -> MainTabItemButton {
        let view = MainTabItemButton(tab: tab)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCreateBracketButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.semiBold(size: 24.scale))
        
        let view = UIButton()
        view.setAttributedTitle("+".attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.main100
        view.layer.cornerRadius = 28.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
