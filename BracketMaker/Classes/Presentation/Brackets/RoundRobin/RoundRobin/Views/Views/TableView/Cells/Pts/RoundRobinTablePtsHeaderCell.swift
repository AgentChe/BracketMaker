//
//  RoundRobinTablePtsHeaderCell.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 17.09.2025.
//

import UIKit

final class RoundRobinTablePtsHeaderCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var titleLabel = makeLabel(text: "RoundRobin.Pts.Title".localized, textAlignment: .left)
    lazy var wLabel = makeLabel(text: "W", textAlignment: .center)
    lazy var wdDivLabel = makeLabel(text: ":", textAlignment: .center)
    lazy var dLabel = makeLabel(text: "D", textAlignment: .center)
    lazy var dlDivLabel = makeLabel(text: ":", textAlignment: .center)
    lazy var lLabel = makeLabel(text: "L", textAlignment: .center)
    lazy var fLabel = makeLabel(text: "F", textAlignment: .center)
    lazy var aLabel = makeLabel(text: "A", textAlignment: .center)
    lazy var ptsLabel = makeLabel(text: "Pts", textAlignment: .center)
    
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
private extension RoundRobinTablePtsHeaderCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension RoundRobinTablePtsHeaderCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8.scale),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 124.scale)
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
private extension RoundRobinTablePtsHeaderCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.main100
        view.layer.cornerRadius = 8.scale
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeLabel(text: String, textAlignment: NSTextAlignment) -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.regular(size: 16.scale))
            .lineHeight(24.scale)
            .textAlignment(textAlignment)
        
        let view = UILabel()
        view.attributedText = text.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}

