//
//  TeamsView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 24.08.2025.
//

import UIKit

final class TeamsView: GradientView {
    lazy var titleLabel = makeTitleLabel()
    lazy var createField = makeCreateField()
    lazy var tableView = makeTableView()
    lazy var paygateButton = makePaygateButton()
    
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
private extension TeamsView {
    func initialize() {
        gradientLayer.colors = Appearance.mono900.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    }
}

// MARK: Make constraints
private extension TeamsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            createField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            createField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            createField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: createField.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            paygateButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            paygateButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            paygateButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.scale),
            paygateButton.heightAnchor.constraint(equalToConstant: 64.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension TeamsView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.semiBold(size: 28.scale))
            .lineHeight(34.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Teams.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCreateField() -> TeamsCreateField {
        let view = TeamsCreateField()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTableView() -> TeamsTableView {
        let view = TeamsTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePaygateButton() -> TeamsPaygateButton {
        let view = TeamsPaygateButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
