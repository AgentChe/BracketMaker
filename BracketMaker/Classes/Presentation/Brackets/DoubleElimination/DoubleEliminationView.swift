//
//  DoubleEliminationView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 21.09.2025.
//

import UIKit

final class DoubleEliminationView: GradientView {
    lazy var tournamentView = makeTournamentView()
    lazy var selectWinnerPlaceholder = makeSelectWinnerPlaceholder()
    lazy var bottomView = makeBottomView()
    
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
private extension DoubleEliminationView {
    func initialize() {
        gradientLayer.colors = Appearance.mono900.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    }
}

// MARK: Constraints
private extension DoubleEliminationView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            tournamentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tournamentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tournamentView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tournamentView.bottomAnchor.constraint(equalTo: bottomView.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            selectWinnerPlaceholder.centerXAnchor.constraint(equalTo: centerXAnchor),
            selectWinnerPlaceholder.bottomAnchor.constraint(equalTo: bottomView.topAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 112.scale)
        ])
    }
}

// MARK: Lazy
private extension DoubleEliminationView {
    func makeTournamentView() -> DETournamentView {
        let view = DETournamentView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSelectWinnerPlaceholder() -> SESelectWinnerPlaceholderView {
        let view = SESelectWinnerPlaceholderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeBottomView() -> RoundRobinBottomView {
        let view = RoundRobinBottomView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
