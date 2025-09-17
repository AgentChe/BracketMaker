//
//  RoundRobinTableGameCell.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 16.09.2025.
//

import UIKit

final class RoundRobinTableGameCell: UITableViewCell {
    lazy var team1View = makeTeamView(alignment: .left)
    lazy var vsLabel = makeVSLabel()
    lazy var team2View = makeTeamView(alignment: .right)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension RoundRobinTableGameCell {
    func setup(element: RoundRobinTableGameElement) {
        team1View.setup(team: element.team1)
        team2View.setup(team: element.team2)
    }
}

// MARK: Private
private extension RoundRobinTableGameCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension RoundRobinTableGameCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            team1View.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            team1View.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.scale),
            team1View.widthAnchor.constraint(equalToConstant: 161.scale),
            team1View.heightAnchor.constraint(equalToConstant: 56.scale)
        ])
        
        NSLayoutConstraint.activate([
            vsLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            vsLabel.centerYAnchor.constraint(equalTo: team1View.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            team2View.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            team2View.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.scale),
            team2View.widthAnchor.constraint(equalToConstant: 161.scale),
            team2View.heightAnchor.constraint(equalToConstant: 56.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension RoundRobinTableGameCell {
    func makeTeamView(alignment: RoundRobinTeamView.Alignment) -> RoundRobinTeamView {
        let view = RoundRobinTeamView(alignment: alignment)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeVSLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100.withAlphaComponent(0.5))
            .font(Fonts.Inter.semiBold(size: 14.scale))
            .lineHeight(21.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "RoundRobin.VS".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
