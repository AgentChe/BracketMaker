//
//  HomeTableInProgressBracketCell.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 06.09.2025.
//

import UIKit

final class HomeTableInProgressBracketCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var tournamentLabel = makeLabel()
    lazy var nameLabel = makeLabel()
    lazy var markLabel = makeMarkLabel()
    
    private lazy var tournamentAttrs = TextAttributes()
        .textColor(Appearance.mono100)
        .font(Fonts.Inter.regular(size: 16.scale))
        .textAlignment(.left)
        .lineBreakMode(.byTruncatingTail)
    private lazy var nameAttrs = TextAttributes()
        .textColor(Appearance.mono100)
        .font(Fonts.Inter.semiBold(size: 20.scale))
        .textAlignment(.left)
        .lineBreakMode(.byTruncatingTail)
    
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
extension HomeTableInProgressBracketCell {
    func setup(element: HomeTableBracketElement.Bracket) {
        switch element {
        case .singleElimination(let singleElimination):
            tournamentLabel.attributedText = "Home.SingleElimination".localized.attributed(with: tournamentAttrs)
            nameLabel.attributedText = singleElimination.name.attributed(with: nameAttrs)
        case .doubleElimination(let doubleElimination):
            tournamentLabel.attributedText = "Home.DoubleElimination".localized.attributed(with: tournamentAttrs)
            nameLabel.attributedText = doubleElimination.name.attributed(with: nameAttrs)
        case .roundRobin(let roundRobin):
            tournamentLabel.attributedText = "Home.RoundRobin".localized.attributed(with: tournamentAttrs)
            nameLabel.attributedText = roundRobin.name.attributed(with: nameAttrs)
        }
    }
}

// MARK: Private
private extension HomeTableInProgressBracketCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension HomeTableInProgressBracketCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.heightAnchor.constraint(equalToConstant: 87.scale)
        ])
        
        NSLayoutConstraint.activate([
            tournamentLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.scale),
            tournamentLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -122.scale),
            tournamentLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.scale),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20.scale),
            nameLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            markLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32.scale),
            markLabel.centerYAnchor.constraint(equalTo: tournamentLabel.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension HomeTableInProgressBracketCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.mono200
        view.layer.cornerRadius = 24.scale
        view.layer.shadowColor = Appearance.mono200.withAlphaComponent(0.4).cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 4.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeMarkLabel() -> PaddingLabel {
        let attrs = TextAttributes()
            .textColor(Appearance.main100)
            .font(Fonts.Inter.medium(size: 12.scale))
            .textAlignment(.center)
        
        let view = PaddingLabel()
        view.attributedText = "Home.Bracket.InProgress".localized.attributed(with: attrs)
        view.backgroundColor = Appearance.main700
        view.layer.cornerRadius = 12.scale
        view.layer.masksToBounds = true
        view.insets = UIEdgeInsets(vertical: 8.scale, horizontal: 10.scale)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
