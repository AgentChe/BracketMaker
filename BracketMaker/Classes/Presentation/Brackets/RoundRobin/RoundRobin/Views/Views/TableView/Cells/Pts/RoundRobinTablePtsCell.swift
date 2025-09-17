//
//  RoundRobinTablePtsTeamCell.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 17.09.2025.
//

import UIKit

final class RoundRobinTablePtsTeamCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var teamNameLabel = makeLabel()
    lazy var wLabel = makeLabel()
    lazy var wdDivLabel = makeDivLabel()
    lazy var dLabel = makeLabel()
    lazy var dlDivLabel = makeDivLabel()
    lazy var lLabel = makeLabel()
    lazy var fLabel = makeLabel()
    lazy var aLabel = makeLabel()
    lazy var ptsLabel = makeLabel()
    
    private lazy var teamNameAttrs = TextAttributes()
        .textColor(Appearance.mono100)
        .font(Fonts.Inter.regular(size: 16.scale))
        .lineHeight(24.scale)
        .textAlignment(.left)
        .lineBreakMode(.byTruncatingTail)
    private lazy var valuesAttrs = TextAttributes()
        .textColor(Appearance.mono100)
        .font(Fonts.Inter.regular(size: 16.scale))
        .lineHeight(24.scale)
        .textAlignment(.center)
    
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
extension RoundRobinTablePtsTeamCell {
    func setup(element: RoundRobinTablePtsTeamElement) {
        teamNameLabel.attributedText = element.team.name.attributed(with: teamNameAttrs)
        wLabel.attributedText = {
            guard let w = element.w else { return "-" }
            return String(w)
        }().attributed(with: valuesAttrs)
        dLabel.attributedText = {
            guard let d = element.d else { return "-" }
            return String(d)
        }().attributed(with: valuesAttrs)
        lLabel.attributedText = {
            guard let l = element.l else { return "-" }
            return String(l)
        }().attributed(with: valuesAttrs)
        fLabel.attributedText = {
            guard let f = element.f else { return "-" }
            return String(f)
        }().attributed(with: valuesAttrs)
        aLabel.attributedText = {
            guard let a = element.a else { return "-" }
            return String(a)
        }().attributed(with: valuesAttrs)
        ptsLabel.attributedText = {
            guard let pts = element.pts else { return "-" }
            return String(pts)
        }().attributed(with: valuesAttrs)
        
        container.backgroundColor = {
            switch element.style {
            case .white:
                return Appearance.main600
            case .gray:
                return Appearance.main700
            }
        }()
    }
}

// MARK: Private
private extension RoundRobinTablePtsTeamCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension RoundRobinTablePtsTeamCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            teamNameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8.scale),
            teamNameLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            teamNameLabel.widthAnchor.constraint(equalToConstant: 124.scale)
        ])
        
        NSLayoutConstraint.activate([
            wLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            wLabel.centerXAnchor.constraint(equalTo: container.leadingAnchor, constant: 155.scale)
        ])
        
        NSLayoutConstraint.activate([
            wdDivLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            wdDivLabel.centerXAnchor.constraint(equalTo: container.leadingAnchor, constant: 174.scale)
        ])
        
        NSLayoutConstraint.activate([
            dLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            dLabel.centerXAnchor.constraint(equalTo: container.leadingAnchor, constant: 193.scale)
        ])
        
        NSLayoutConstraint.activate([
            dlDivLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            dlDivLabel.centerXAnchor.constraint(equalTo: container.leadingAnchor, constant: 212.scale)
        ])
        
        NSLayoutConstraint.activate([
            lLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            lLabel.centerXAnchor.constraint(equalTo: container.leadingAnchor, constant: 231.scale)
        ])
        
        NSLayoutConstraint.activate([
            fLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            fLabel.centerXAnchor.constraint(equalTo: container.leadingAnchor, constant: 278.scale)
        ])
        
        NSLayoutConstraint.activate([
            aLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            aLabel.centerXAnchor.constraint(equalTo: container.leadingAnchor, constant: 306.scale)
        ])
        
        NSLayoutConstraint.activate([
            ptsLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            ptsLabel.centerXAnchor.constraint(equalTo: container.leadingAnchor, constant: 334.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension RoundRobinTablePtsTeamCell {
    func makeContainer() -> UIView {
        let view = UIView()
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
    
    func makeDivLabel() -> UILabel {
        let view = UILabel()
        view.attributedText = ":".attributed(with: valuesAttrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
