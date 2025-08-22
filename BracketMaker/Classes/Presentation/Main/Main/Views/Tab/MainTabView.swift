//
//  MainTabView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 22.08.2025.
//

import UIKit

final class MainTabItemButton: TapAreaButton {
    enum Tab {
        case home, teams, settings
    }
    
    enum Mode {
        case selected, deselected
    }
    
    lazy var iconView = makeImageView()
    
    var mode = Mode.deselected {
        didSet {
            update()
        }
    }
    
    let tab: Tab
    
    init(tab: Tab) {
        self.tab = tab
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension MainTabItemButton {
    func initialize() {
        backgroundColor = UIColor.clear
    }
    
    func update() {
        let domain: String = {
            switch tab {
            case .home:
                return "Main.Home.%@"
            case .teams:
                return "Main.Teams.%@"
            case .settings:
                return "Main.Settings.%@"
            }
        }()
        let code: String =  {
            switch mode {
            case .selected:
                return "S"
            case .deselected:
                return "D"
            }
        }()
        let iconName = String(format: domain, code)
        iconView.image = UIImage(named: iconName)
    }
}

// MARK: Make constraints
private extension MainTabItemButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 56.scale),
            iconView.heightAnchor.constraint(equalToConstant: 40.scale),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconView.trailingAnchor.constraint(equalTo: trailingAnchor),
            iconView.topAnchor.constraint(equalTo: topAnchor),
            iconView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension MainTabItemButton {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
