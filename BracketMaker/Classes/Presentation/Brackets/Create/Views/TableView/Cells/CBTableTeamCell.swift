//
//  CBTableTeamCell.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 09.09.2025.
//

import UIKit

final class CBTableTeamCell: UITableViewCell {
    var didTap: (() -> Void)?
    
    lazy var teamButton = makeTeamButton()
    
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
extension CBTableTeamCell {
    func setup(element: TeamPosition) {
        teamButton.setup(content: element.content)
    }
}

// MARK: Private
private extension CBTableTeamCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    @objc
    func tapped() {
        didTap?()
    }
}

// MARK: Make constraints
private extension CBTableTeamCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            teamButton.heightAnchor.constraint(equalToConstant: 56.scale),
            teamButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            teamButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            teamButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension CBTableTeamCell {
    func makeTeamButton() -> CBTeamButton {
        let view = CBTeamButton()
        view.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
