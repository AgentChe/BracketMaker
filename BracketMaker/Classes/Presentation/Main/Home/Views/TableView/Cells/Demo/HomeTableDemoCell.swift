//
//  HomeTableDemoCell.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 06.09.2025.
//

import UIKit

final class HomeTableDemoCell: UITableViewCell {
    lazy var roundRobinView = makeDemoView(tournament: .roundRobin)
    lazy var singleEliminationView = makeDemoView(tournament: .singleElimination)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension HomeTableDemoCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make Constraints
private extension HomeTableDemoCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            roundRobinView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            roundRobinView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            roundRobinView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.scale),
            roundRobinView.heightAnchor.constraint(equalToConstant: 82.scale)
        ])
        
        NSLayoutConstraint.activate([
            singleEliminationView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            singleEliminationView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            singleEliminationView.topAnchor.constraint(equalTo: roundRobinView.bottomAnchor, constant: 8.scale),
            singleEliminationView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            singleEliminationView.heightAnchor.constraint(equalToConstant: 82.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension HomeTableDemoCell {
    func makeDemoView(tournament: HomeDemoView.Tournament) -> HomeDemoView {
        let view = HomeDemoView(tournament: tournament)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
