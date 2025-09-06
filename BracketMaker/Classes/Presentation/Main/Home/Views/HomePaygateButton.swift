//
//  HomePaygateButton.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 05.09.2025.
//

import UIKit

final class HomePaygateButton: UIButton {
    lazy var backgroundView = makeImageView()
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
private extension HomePaygateButton {
    func initialize() {
        backgroundColor = UIColor.clear
        layer.cornerRadius = 24.scale
        layer.masksToBounds = true
    }
}

// MARK: Make constraints
private extension HomePaygateButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16.scale),
            label.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension HomePaygateButton {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "Home.Paygate")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> PaddingLabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.medium(size: 16.scale))
            .lineHeight(21.scale)
            .textAlignment(.center)
        
        let view = PaddingLabel()
        view.layer.cornerRadius = 16.scale
        view.layer.masksToBounds = true
        view.backgroundColor = Appearance.main200
        view.insets = UIEdgeInsets(vertical: 10.scale, horizontal: 12.scale)
        view.attributedText = "Home.UnlimitedBrackets".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
