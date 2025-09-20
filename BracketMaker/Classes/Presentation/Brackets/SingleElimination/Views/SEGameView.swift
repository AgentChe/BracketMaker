//
//  SEGameView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 19.09.2025.
//

import UIKit

final class SEGameView: UIView {
    struct Game {
        let gameId: String
        let team1: SETeamView.Team?
        let team2: SETeamView.Team?
    }
    
    lazy var team1View = makeTeamView(team: game.team1)
    lazy var team2View = makeTeamView(team: game.team2)
    
    let game: Game
    
    private let didSelectWinner: ((gameId: String, teamId: String)) -> Void
    
    init(game: Game, didSelectWinner: @escaping ((gameId: String, teamId: String)) -> Void) {
        self.game = game
        self.didSelectWinner = didSelectWinner
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension SEGameView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
    
    @objc
    func tapped(sender: UIButton) {
        guard game.canSelect, let teamButton = sender as? SETeamView, let team = teamButton.team else { return }
        
        didSelectWinner((gameId: game.gameId, teamId: team.teamId))
    }
}

// MARK: Make constraints
private extension SEGameView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            team1View.leadingAnchor.constraint(equalTo: leadingAnchor),
            team1View.trailingAnchor.constraint(equalTo: trailingAnchor),
            team1View.topAnchor.constraint(equalTo: topAnchor),
            team1View.heightAnchor.constraint(equalToConstant: 56.scale)
        ])
        
        NSLayoutConstraint.activate([
            team2View.leadingAnchor.constraint(equalTo: leadingAnchor),
            team2View.trailingAnchor.constraint(equalTo: trailingAnchor),
            team2View.bottomAnchor.constraint(equalTo: bottomAnchor),
            team2View.heightAnchor.constraint(equalToConstant: 56.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension SEGameView {
    func makeTeamView(team: SETeamView.Team?) -> SETeamView {
        let view = SETeamView(team: team)
        view.addTarget(self, action: #selector(tapped(sender:)), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}

// MARK: Additional
private extension SEGameView.Game {
    var canSelect: Bool {
        guard let team1, let team2 else { return false }
        
        return (team1.isWinner == nil) && (team2.isWinner == nil)
    }
}
