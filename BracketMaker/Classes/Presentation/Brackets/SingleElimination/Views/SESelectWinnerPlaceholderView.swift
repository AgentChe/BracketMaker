//
//  SESelectWinnerPlaceholderView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 20.09.2025.
//

import UIKit

final class SESelectWinnerPlaceholderView: UIView {
    lazy var label = makeLabel()
    
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
private extension SESelectWinnerPlaceholderView {
    func initialize() {
        backgroundColor = Appearance.main600
        layer.cornerRadius = 10.scale
    }
}

// MARK: Make constraints
private extension SESelectWinnerPlaceholderView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.scale),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8.scale),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension SESelectWinnerPlaceholderView {
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100.withAlphaComponent(0.6))
            .font(Fonts.Inter.regular(size: 14.scale))
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "SingleElimination.SelectWinner".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
