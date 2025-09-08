//
//  BIPresetsView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 08.09.2025.
//

import UIKit

final class BIPresetsView: UIView {
    lazy var titleLabel = makeTitleLabel()
    lazy var imageView = makeImageView()
    lazy var textLabel = makeTextLabel()
    
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
private extension BIPresetsView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension BIPresetsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.scale),
            imageView.heightAnchor.constraint(equalToConstant: 80.scale)
        ])
        
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24.scale),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension BIPresetsView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.medium(size: 24.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "BracketInfo.Presets.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: "BracketInfo.Presets")
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTextLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.regular(size: 16.scale))
            .lineHeight(21.scale)
            .textAlignment(.left)
        let boldAttrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.bold(size: 16.scale))
            .lineHeight(21.scale)
            .textAlignment(.left)
        
        let result = NSMutableAttributedString()
        result.append("BracketInfo.Presets.Text1".localized.attributed(with: attrs))
        result.append("BracketInfo.Presets.Text2".localized.attributed(with: boldAttrs))
        result.append("BracketInfo.Presets.Text3".localized.attributed(with: attrs))
        result.append("BracketInfo.Presets.Text4".localized.attributed(with: boldAttrs))
        result.append("BracketInfo.Presets.Text5".localized.attributed(with: attrs))
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = result
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
