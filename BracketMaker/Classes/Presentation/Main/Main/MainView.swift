//
//  MainView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 22.08.2025.
//

import UIKit

final class MainView: GradientView {
    lazy var container = makeContainer()
    lazy var tabView = makeTabView()
    
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
private extension MainView {
    func initialize() {
        gradientLayer.colors = Appearance.mono900.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    }
}

// MARK: Make constraints
private extension MainView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: tabView.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            tabView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tabView.heightAnchor.constraint(equalToConstant: 112.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension MainView {
    func makeContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTabView() -> MainTabView {
        let view = MainTabView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
