//
//  HomeTableAddFirstBracketCell.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 06.09.2025.
//

import UIKit

final class HomeTableAddFirstBracketCell: UITableViewCell {
    var didTapCreate: (() -> Void)?
    
    lazy var backgroundImageView = makeBackgroundImageView()
    lazy var label = makeLabel()
    lazy var createButton = makeCreateButton()
    
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
private extension HomeTableAddFirstBracketCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    @objc
    func createTapped() {
        didTapCreate?()
    }
}

// MARK: Make constraints
private extension HomeTableAddFirstBracketCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            backgroundImageView.heightAnchor.constraint(equalToConstant: 164.scale)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: backgroundImageView.leadingAnchor, constant: 20.scale),
            label.topAnchor.constraint(equalTo: backgroundImageView.topAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            createButton.widthAnchor.constraint(equalToConstant: 164.scale),
            createButton.heightAnchor.constraint(equalToConstant: 56.scale),
            createButton.leadingAnchor.constraint(equalTo: backgroundImageView.leadingAnchor, constant: 20.scale),
            createButton.bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -24.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension HomeTableAddFirstBracketCell {
    func makeBackgroundImageView() -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: "Home.AddFirstBracket")
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 24.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.semiBold(size: 20.scale))
            .lineHeight(22.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Home.AddFirstBracket.Title".localized.attributed(with: attrs)
        view.numberOfLines = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeCreateButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.medium(size: 18.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Home.AddFirstBracket.Create".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.main200
        view.layer.cornerRadius = 24.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        contentView.addSubview(view)
        return view
    }
}
