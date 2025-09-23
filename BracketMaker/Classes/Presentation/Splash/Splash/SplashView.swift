//
//  SplashView.swift
//  Soccer
//
//  Created by Андрей Чернышев on 05.07.2022.
//

import UIKit
import RiveRuntime

final class SplashView: GradientView {
    lazy var animationView = makeAnimationView()
    
    private lazy var animationVM = RiveViewModel(fileName: "Splash.Animate")
    
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
private extension SplashView {
    func initialize() {
        gradientLayer.colors = Appearance.mono900.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        animationVM.setView(animationView)
    }
}

// MARK: Make constraints
private extension SplashView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: centerYAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 390.scale),
            animationView.heightAnchor.constraint(equalToConstant: 390.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension SplashView {
    func makeAnimationView() -> RiveView {
        let view = RiveView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
