//
//  RoundRobinTeamView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 16.09.2025.
//

import UIKit

final class RoundRobinTeamView: UIView {
    enum Alignment {
        case left, right
    }
    
    struct Team {
        enum State {
            case winner(Int)
            case loser(Int)
            case draw(Int)
            case none
            
            var isNone: Bool {
                switch self {
                case .none:
                    return true
                default:
                    return false 
                }
            }
        }
        
        let name: String
        let state: State
    }
    
    lazy var teamNameLabel = makeLabel()
    lazy var scoreView = makeScoreView()
    lazy var scoreLabel = makeLabel()
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.mono100)
        .font(Fonts.Inter.regular(size: 16.scale))
        .lineHeight(24.scale)
        .textAlignment(.center)
        .lineBreakMode(.byTruncatingTail)
    private lazy var winnerAttrs = TextAttributes()
        .textColor(Appearance.mono200)
        .font(Fonts.Inter.regular(size: 16.scale))
        .lineHeight(24.scale)
        .textAlignment(.center)
    
    private let alignment: Alignment
    
    init(alignment: Alignment) {
        self.alignment = alignment
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension RoundRobinTeamView {
    func setup(team: Team) {
        teamNameLabel.attributedText = team.name.attributed(with: attrs)
        
        switch team.state {
        case .winner(let goals):
            scoreView.backgroundColor = Appearance.main200
            scoreLabel.attributedText = String(goals).attributed(with: winnerAttrs)
        case .loser(let goals):
            scoreView.backgroundColor = Appearance.main600
            scoreLabel.attributedText = String(goals).attributed(with: attrs)
        case .draw(let goals):
            scoreView.backgroundColor = Appearance.main500
            scoreLabel.attributedText = String(goals).attributed(with: attrs)
        case .none:
            scoreView.backgroundColor = Appearance.main600
            scoreLabel.attributedText = "+".attributed(with: attrs)
        }
    }
}

// MARK: Private
private extension RoundRobinTeamView {
    func initialize() {
        backgroundColor = Appearance.mono200
        layer.shadowColor = Appearance.mono200.withAlphaComponent(0.4).cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4.scale
        layer.cornerRadius = 19.scale
    }
}

// MARK: Make constraints
private extension RoundRobinTeamView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            teamNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: {
                switch alignment {
                case .left:
                    return 16.scale
                case .right:
                    return 41.scale
                }
            }()),
            teamNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: {
                switch alignment {
                case .left:
                    return -41.scale
                case .right:
                    return -16.scale
                }
            }()),
            teamNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        switch alignment {
        case .left:
            scoreView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        case .right:
            scoreView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        }
        NSLayoutConstraint.activate([
            scoreView.topAnchor.constraint(equalTo: topAnchor),
            scoreView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scoreView.widthAnchor.constraint(equalToConstant: 28.scale)
        ])
        
        NSLayoutConstraint.activate([
            scoreLabel.centerXAnchor.constraint(equalTo: scoreView.centerXAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: scoreView.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension RoundRobinTeamView {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeScoreView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 19.scale
        view.layer.maskedCorners = {
            switch alignment {
            case .left:
                return [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            case .right:
                return [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            }
        }()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
