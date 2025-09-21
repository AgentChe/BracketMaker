//
//  DETournamentView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 21.09.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class DETournamentView: UIView {
    struct Tournament {
        let winnersRounds: [SERoundGamesView.Round]
        let losersRounds: [SERoundGamesView.Round]
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
extension DETournamentView {
    func setup(tournament: Tournament) {
        container.subviews.forEach { $0.removeFromSuperview() }
        
        var usedWidthW = CGFloat(0)
        var usedWidthL = CGFloat(0)
        
        let wTitle = titleLabel("DoubleElimination.WinnersBracket".localized)
        container.addSubview(wTitle)
        
        NSLayoutConstraint.activate([
            wTitle.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            wTitle.topAnchor.constraint(equalTo: container.topAnchor)
        ])
        
        let winnersHeight = tournament.winnersRounds.map { SERoundGamesView.calculateHeight(round: $0) }.max() ?? 0
        var leading: CGFloat = 0
        var prevW: SERoundGamesView? = nil
        tournament.winnersRounds.enumerated().forEach { idx, round in
            let roundView = SERoundGamesView(round: round) { [weak self] args in
                self?.didSelectWinnerTrigger.accept(args)
            }
            roundView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(roundView)

            var cs: [NSLayoutConstraint] = [
                roundView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: leading),
                roundView.widthAnchor.constraint(equalToConstant: SERoundGamesView.Constants.gameWidth),
                roundView.heightAnchor.constraint(equalToConstant: SERoundGamesView.calculateHeight(round: round))
            ]
            if let prev = prevW {
                cs.append(roundView.centerYAnchor.constraint(equalTo: prev.centerYAnchor))
            } else {
                cs.append(roundView.topAnchor.constraint(equalTo: wTitle.bottomAnchor, constant: 12.scale))
            }
            NSLayoutConstraint.activate(cs)

            let div = divider()
            container.addSubview(div)
            NSLayoutConstraint.activate([
                div.topAnchor.constraint(equalTo: roundView.topAnchor),
                div.bottomAnchor.constraint(equalTo: roundView.bottomAnchor),
                div.widthAnchor.constraint(equalToConstant: 1.scale),
                div.leadingAnchor.constraint(equalTo: roundView.trailingAnchor, constant: 24.scale)
            ])

            prevW = roundView
            leading += SERoundGamesView.Constants.gameWidth + 24.scale + 1.scale
            if (tournament.winnersRounds.count - 1) != idx { leading += 24.scale }
        }
        usedWidthW = leading
        
        let lTitle = titleLabel("DoubleElimination.LosersBracket".localized)
        container.addSubview(lTitle)
        NSLayoutConstraint.activate([
            lTitle.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            lTitle.topAnchor.constraint(equalTo: wTitle.bottomAnchor, constant: winnersHeight + 12.scale + 40.scale)
        ])
        
        let losersHeight = tournament.losersRounds.map { SERoundGamesView.calculateHeight(round: $0) }.max() ?? 0
        leading = 0
        var prevL: SERoundGamesView? = nil
        tournament.losersRounds.enumerated().forEach { idx, round in
            let roundView = SERoundGamesView(round: round) { [weak self] args in
                self?.didSelectWinnerTrigger.accept(args)
            }
            roundView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(roundView)

            var cs: [NSLayoutConstraint] = [
                roundView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: leading),
                roundView.widthAnchor.constraint(equalToConstant: SERoundGamesView.Constants.gameWidth),
                roundView.heightAnchor.constraint(equalToConstant: SERoundGamesView.calculateHeight(round: round))
            ]
            if let prev = prevL {
                cs.append(roundView.centerYAnchor.constraint(equalTo: prev.centerYAnchor))
            } else {
                cs.append(roundView.topAnchor.constraint(equalTo: lTitle.bottomAnchor, constant: 12.scale))
            }
            NSLayoutConstraint.activate(cs)

            let div = divider()
            container.addSubview(div)
            NSLayoutConstraint.activate([
                div.topAnchor.constraint(equalTo: roundView.topAnchor),
                div.bottomAnchor.constraint(equalTo: roundView.bottomAnchor),
                div.widthAnchor.constraint(equalToConstant: 1.scale),
                div.leadingAnchor.constraint(equalTo: roundView.trailingAnchor, constant: 24.scale)
            ])

            prevL = roundView
            leading += SERoundGamesView.Constants.gameWidth + 24.scale + 1.scale
            if (tournament.losersRounds.count - 1) != idx { leading += 24.scale }
        }
        usedWidthL = leading
        
        var totalWidth = max(usedWidthW, usedWidthL)
        
        if let winner = tournament.winner {
            totalWidth += 24.scale
            let winView = SEWinnerView(team: winner)
            winView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(winView)
            NSLayoutConstraint.activate([
                winView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: totalWidth),
                winView.centerYAnchor.constraint(equalTo: wTitle.bottomAnchor, constant: (12.scale + winnersHeight / 2)),
                winView.widthAnchor.constraint(equalToConstant: SEWinnerView.Constants.width),
                winView.heightAnchor.constraint(equalToConstant: 56.scale)
            ])
            totalWidth += SEWinnerView.Constants.width
        }
        
        containerWidthConstraint.constant = totalWidth
        containerHeightConstraint.constant = 12.scale + winnersHeight + 40.scale + 12.scale + losersHeight + 24.scale
        
        layoutIfNeeded()
    }
    
    var didSelectWinner: Signal<(gameId: String, teamId: String)> {
        didSelectWinnerTrigger.asSignal()
    }
}

// MARK: Private
private extension DETournamentView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Constraints
private extension DETournamentView {
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

// MARK: Lazy
private extension DETournamentView {
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
    
    func titleLabel(_ text: String) -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.medium(size: 18.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = text.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func divider() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.main100.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
