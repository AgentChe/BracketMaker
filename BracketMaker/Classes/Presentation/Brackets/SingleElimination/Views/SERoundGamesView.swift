//
//  SERoundGamesView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 19.09.2025.
//

import UIKit

final class SERoundGamesView: UIView {
    enum Constants {
        static let gameWidth = 161.scale
        static let gameHeight = 120.scale
        static let inset = 40.scale
    }
    
    struct Round {
        let games: [SEGameView.Game]
        let round: Int
    }
    
    private let round: Round
    
    private let didSelectWinner: ((gameId: String, teamId: String)) -> Void
    
    init(round: Round, didSelectWinner: @escaping ((gameId: String, teamId: String)) -> Void) {
        self.round = round
        self.didSelectWinner = didSelectWinner
        
        super.init(frame: .zero)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SERoundGamesView {
    static func calculateHeight(round: Round) -> CGFloat {
        guard !round.games.isEmpty else { return 0 }
        
        return CGFloat(round.games.count) * Constants.gameHeight + CGFloat(round.games.count - 1) * Constants.inset
    }
}

// MARK: Private
private extension SERoundGamesView {
    func initialize() {
        backgroundColor = UIColor.clear
        
        let count = round.games.count
        
        var previousView: UIView?
        
        round.games.enumerated().forEach { index, game in
            let gameView = SEGameView(game: game, didSelectWinner: didSelectWinner)
            gameView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(gameView)
            
            NSLayoutConstraint.activate([
                gameView.widthAnchor.constraint(equalToConstant: Constants.gameWidth),
                gameView.heightAnchor.constraint(equalToConstant: Constants.gameHeight),
                gameView.leadingAnchor.constraint(equalTo: leadingAnchor),
                gameView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
            
            if let previousView {
                gameView.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: Constants.inset).isActive = true
            } else {
                gameView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            }
            
            if (count - 1) == index {
                gameView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            }
            
            previousView = gameView
        }
    }
}
