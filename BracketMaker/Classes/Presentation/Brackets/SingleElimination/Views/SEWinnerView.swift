//
//  SEWinnerView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 19.09.2025.
//

import UIKit

final class SEWinnerView: UIView {
    enum Constants {
        static let width = 303.scale
    }
    
    lazy var teamView = makeTeamView()
    lazy var div = makeDiv()
    lazy var label = makeLabel()
    
    private let team: SETeamView.Team
    
    init(team: SETeamView.Team) {
        self.team = team
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension SEWinnerView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension SEWinnerView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            teamView.widthAnchor.constraint(equalToConstant: 161.scale),
            teamView.heightAnchor.constraint(equalToConstant: 56.scale),
            teamView.centerYAnchor.constraint(equalTo: centerYAnchor),
            teamView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            div.topAnchor.constraint(equalTo: topAnchor),
            div.bottomAnchor.constraint(equalTo: bottomAnchor),
            div.widthAnchor.constraint(equalToConstant: 1.scale),
            div.leadingAnchor.constraint(equalTo: teamView.trailingAnchor, constant: 7.scale)
        ])
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: teamView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: div.trailingAnchor, constant: 7.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension SEWinnerView {
    func makeTeamView() -> SETeamView {
        let view = SETeamView(team: team)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeDiv() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.main100.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.regular(size: 16.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "SingleElimination.Winner".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
