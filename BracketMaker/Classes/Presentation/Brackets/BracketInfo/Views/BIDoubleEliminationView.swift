//
//  BIDoubleEliminationView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 08.09.2025.
//

import UIKit

final class BIDoubleEliminationView: UIView {
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
private extension BIDoubleEliminationView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension BIDoubleEliminationView {
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
            imageView.heightAnchor.constraint(equalToConstant: 288.scale)
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
private extension BIDoubleEliminationView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.medium(size: 24.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "BracketInfo.DoubleElimination.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: "BracketInfo.DoubleElimination")
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
        
        let text2: NSAttributedString = {
            let result = NSMutableAttributedString()
            result.append("BracketInfo.DoubleElimination.Text2.1".localized.attributed(with: attrs))
            result.append("BracketInfo.DoubleElimination.Text2.2".localized.attributed(with: boldAttrs))
            result.append("BracketInfo.DoubleElimination.Text2.3".localized.attributed(with: attrs))
            result.append("BracketInfo.DoubleElimination.Text2.4".localized.attributed(with: boldAttrs))
            result.append("BracketInfo.DoubleElimination.Text2.5".localized.attributed(with: attrs))
            return result
        }()

        let result = NSMutableAttributedString()
        result.append("BracketInfo.DoubleElimination.Text1".localized.attributed(with: attrs))
        result.append(text2)
        result.append("BracketInfo.DoubleElimination.Text3".localized.attributed(with: attrs))
        result.append("BracketInfo.DoubleElimination.Text4".localized.attributed(with: attrs))
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = result
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
