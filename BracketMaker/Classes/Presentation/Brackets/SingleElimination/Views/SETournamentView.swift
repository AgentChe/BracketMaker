//
//  SETournamentView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 19.09.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class SETournamentView: UIView {
    struct Tournament {
        let rounds: [SERoundGamesView.Round]
        let winner: SETeamView.Team?
    }
    
    lazy var scrollView = makeScrollView()
    lazy var container = makeContainer()
    
    private lazy var containerHeightConstraint = NSLayoutConstraint()
    private lazy var containerWidthConstraint = NSLayoutConstraint()
    
    private lazy var didSelectWinnerTrigger = PublishRelay<(gameId: String, teamId: String)>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SETournamentView {
    func setup(tournament: Tournament) {
        container.subviews.forEach { $0.removeFromSuperview() }
        
        var leading = CGFloat(0)
        
        tournament.rounds.enumerated().forEach { index, round in
            let roundView = SERoundGamesView(round: round) { [weak self] args in
                self?.didSelectWinnerTrigger.accept(args)
            }
            roundView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(roundView)
            
            NSLayoutConstraint.activate([
                roundView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: leading),
                roundView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
            
            let divView = UIView()
            divView.backgroundColor = Appearance.main100.withAlphaComponent(0.5)
            divView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(divView)
            
            NSLayoutConstraint.activate([
                divView.topAnchor.constraint(equalTo: roundView.topAnchor),
                divView.bottomAnchor.constraint(equalTo: roundView.bottomAnchor),
                divView.widthAnchor.constraint(equalToConstant: 1.scale),
                divView.leadingAnchor.constraint(equalTo: roundView.trailingAnchor, constant: 24.scale)
            ])
            
            leading += SERoundGamesView.Constants.gameWidth + 24.scale + 1.scale
            
            if (tournament.rounds.count - 1) != index {
                leading += 24.scale
            }
        }
        
        if let winner = tournament.winner {
            leading += 24.scale
            
            let view = SEWinnerView(team: winner)
            view.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(view)
            
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: leading),
                view.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                view.widthAnchor.constraint(equalToConstant: SEWinnerView.Constants.width),
                view.heightAnchor.constraint(equalToConstant: 56.scale)
            ])
            
            leading += SEWinnerView.Constants.width
        }
        
        containerWidthConstraint.constant = leading
        containerHeightConstraint.constant = tournament.rounds.map { SERoundGamesView.calculateHeight(round: $0) }.max() ?? 0
        
        layoutIfNeeded()
    }
    
    var didSelectWinner: Signal<(gameId: String, teamId: String)> {
        didSelectWinnerTrigger.asSignal()
    }
}

// MARK: Private
private extension SETournamentView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension SETournamentView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        containerHeightConstraint = container.heightAnchor.constraint(equalToConstant: 0)
        containerWidthConstraint = container.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            container.topAnchor.constraint(equalTo: scrollView.topAnchor),
            container.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerHeightConstraint,
            containerWidthConstraint
        ])
    }
}

// MARK: Lazy initialization
private extension SETournamentView {
    func makeScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.backgroundColor = UIColor.clear
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.contentInset = UIEdgeInsets(vertical: 32.scale, horizontal: 16.scale)
        view.setContentOffset(CGPoint(x: -16.scale, y: -32.scale), animated: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
}
