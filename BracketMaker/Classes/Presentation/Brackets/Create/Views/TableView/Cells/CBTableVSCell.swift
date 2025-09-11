//
//  CBTableVSCell.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 09.09.2025.
//

import UIKit

final class CBTableVSCell: UITableViewCell {
    var didTapTeam1: (() -> Void)?
    var didTapTeam2: (() -> Void)?
    
    lazy var team1Button = makeTeamButton()
    lazy var vsLabel = makeVSLabel()
    lazy var team2Button = makeTeamButton()
    
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
extension CBTableVSCell {
    func setup(team1: TeamPosition, team2: TeamPosition) {
        team1Button.setup(content: team1.content)
        team2Button.setup(content: team2.content)
    }
}

// MARK: Private
private extension CBTableVSCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
        
        team1Button.addTarget(self, action: #selector(tappedTeam1), for: .touchUpInside)
        team2Button.addTarget(self, action: #selector(tappedTeam2), for: .touchUpInside)
    }
    
    @objc
    func tappedTeam1() {
        didTapTeam1?()
    }
    
    @objc
    func tappedTeam2() {
        didTapTeam2?()
    }
}

// MARK: Make constraints
private extension CBTableVSCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            team1Button.widthAnchor.constraint(equalToConstant: 161.scale),
            team1Button.heightAnchor.constraint(equalToConstant: 56.scale),
            team1Button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            team1Button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            vsLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            vsLabel.centerYAnchor.constraint(equalTo: team1Button.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            team2Button.widthAnchor.constraint(equalToConstant: 161.scale),
            team2Button.heightAnchor.constraint(equalToConstant: 56.scale),
            team2Button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            team2Button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension CBTableVSCell {
    func makeTeamButton() -> CBTeamButton {
        let view = CBTeamButton()
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
        view.attributedText = "CreateBracket.VS".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
