//
//  HomeDemoView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 06.09.2025.
//

import UIKit

final class HomeDemoView: UIView {
    enum Tournament {
        case roundRobin, singleElimination
    }
    
    lazy var tournamentLabel = makeTournamentLabel()
    lazy var nameLabel = makeNameLabel()
    lazy var markLabel = makeMarkLabel()
    
    private let tournament: Tournament
    
    init(tournament: Tournament) {
        self.tournament = tournament
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension HomeDemoView {
    func initialize() {
        backgroundColor = Appearance.mono200
        layer.cornerRadius = 24.scale
        layer.shadowColor = Appearance.mono200.withAlphaComponent(0.4).cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4.scale
    }
}

// MARK: Make constraints
private extension HomeDemoView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            tournamentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            tournamentLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            markLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            markLabel.centerYAnchor.constraint(equalTo: tournamentLabel.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension HomeDemoView {
    func makeTournamentLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.regular(size: 16.scale))
            .textAlignment(.left)
        
        let string: String = {
            switch tournament {
            case .roundRobin:
                return "Home.Demo.RoundRobin.Title".localized
            case .singleElimination:
                return "Home.Demo.SingleElimination.Title".localized
            }
        }()
        
        let view = UILabel()
        view.attributedText = string.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeNameLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.semiBold(size: 20.scale))
            .textAlignment(.left)
        
        let string: String = {
            switch tournament {
            case .roundRobin:
                return "Home.Demo.RoundRobin.Name".localized
            case .singleElimination:
                return "Home.Demo.SingleElimination.Name".localized
            }
        }()
        
        let view = UILabel()
        view.attributedText = string.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeMarkLabel() -> PaddingLabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.medium(size: 12.scale))
            .textAlignment(.center)
        
        let view = PaddingLabel()
        view.attributedText = "Home.Demo.Label".localized.attributed(with: attrs)
        view.backgroundColor = Appearance.main400
        view.layer.cornerRadius = 12.scale
        view.layer.masksToBounds = true
        view.insets = UIEdgeInsets(vertical: 8.scale, horizontal: 10.scale)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
