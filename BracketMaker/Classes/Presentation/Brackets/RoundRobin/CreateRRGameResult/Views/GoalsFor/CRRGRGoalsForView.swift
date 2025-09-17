//
//  CRRGRGoalsForView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 17.09.2025.
//

import UIKit

final class CRRGRGoalsForView: UIView {
    lazy var team1ItemView = makeItemView()
    lazy var divLabel = makeDivLabel()
    lazy var team2ItemView = makeItemView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension CRRGRGoalsForView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension CRRGRGoalsForView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            team1ItemView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            team1ItemView.topAnchor.constraint(equalTo: topAnchor),
            team1ItemView.widthAnchor.constraint(equalToConstant: 161.scale),
            team1ItemView.heightAnchor.constraint(equalToConstant: 168.scale)
        ])
        
        NSLayoutConstraint.activate([
            divLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            divLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            team2ItemView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            team2ItemView.topAnchor.constraint(equalTo: topAnchor),
            team2ItemView.widthAnchor.constraint(equalToConstant: 161.scale),
            team2ItemView.heightAnchor.constraint(equalToConstant: 168.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension CRRGRGoalsForView {
    func makeItemView() -> CRRGRGoalsForItemView {
        let view = CRRGRGoalsForItemView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeDivLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100.withAlphaComponent(0.5))
            .font(Fonts.Inter.semiBold(size: 32.scale))
            .lineHeight(48.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = ":".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
