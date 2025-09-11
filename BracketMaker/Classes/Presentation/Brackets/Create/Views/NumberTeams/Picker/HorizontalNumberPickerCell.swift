//
//  HorizontalNumberPickerCell.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 08.09.2025.
//

import UIKit

final class HorizontalNumberPickerCell: UICollectionViewCell {
    lazy var container = makeContainer()
    lazy var label = makeLabel()

    private lazy var attrs = TextAttributes()
        .textColor(Appearance.mono100)
        .font(Fonts.Inter.regular(size: 34.scale))
        .textAlignment(.center)

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            container.transform = isHighlighted ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
        }
    }
}

// MARK: Public
extension HorizontalNumberPickerCell {
    func setup(text: String) {
        label.attributedText = text.attributed(with: attrs)
    }
    
    func setup(alpha: CGFloat) {
        label.alpha = alpha
    }
    
    func setup(isSelected: Bool) {
        if isSelected {
            label.alpha = 1
        }
        
        container.layer.borderWidth = isSelected ? 3.scale : 0
        container.layer.borderColor = isSelected ? Appearance.main100.cgColor : UIColor.clear.cgColor
    }
}

// MARK: Private
private extension HorizontalNumberPickerCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.clear
        selectedBackgroundView = selectedView
    }
}

// MARK: Make constraints
private extension HorizontalNumberPickerCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension HorizontalNumberPickerCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 24.scale
        view.layer.borderWidth = 0
        view.layer.borderColor = UIColor.clear.cgColor
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.adjustsFontSizeToFitWidth = false
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
