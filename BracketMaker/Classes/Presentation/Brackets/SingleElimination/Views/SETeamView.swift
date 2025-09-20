//
//  SETeamView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 19.09.2025.
//

import UIKit

final class SETeamView: UIButton {
    struct Team {
        let teamId: String
        let teamName: String
        let isWinner: Bool?
    }
    
    lazy var teamNameLabel = makeLabel()
    lazy var scoreView = makeScoreView()
    
    let team: Team?
    
    init(team: Team?) {
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
private extension SETeamView {
    func initialize() {
        backgroundColor = Appearance.mono200
        layer.shadowColor = Appearance.mono200.withAlphaComponent(0.4).cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4.scale
        layer.cornerRadius = 19.scale
        alpha = {
            guard let isWinner = team?.isWinner else {
                return 1
            }
            
            return isWinner ? 1 : 0.5
        }()
    }
}

// MARK: Make constraints
private extension SETeamView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            teamNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            teamNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -41.scale),
            teamNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            scoreView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scoreView.topAnchor.constraint(equalTo: topAnchor),
            scoreView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scoreView.widthAnchor.constraint(equalToConstant: 28.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension SETeamView {
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.regular(size: 16.scale))
            .lineHeight(24.scale)
            .textAlignment(.center)
            .lineBreakMode(.byTruncatingTail)
        
        let view = UILabel()
        view.attributedText = team?.teamName.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeScoreView() -> UIView {
        let view = UIView()
        view.backgroundColor = (team?.isWinner ?? false) ? Appearance.main200 : Appearance.main600
        view.layer.cornerRadius = 19.scale
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
