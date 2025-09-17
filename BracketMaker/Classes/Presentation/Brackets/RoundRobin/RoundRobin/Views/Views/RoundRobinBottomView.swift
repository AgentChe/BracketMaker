//
//  RoundRobinBottomView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 16.09.2025.
//

import UIKit

final class RoundRobinBottomView: UIView {
    lazy var shareButton = makeShareButton()
    lazy var deleteButton = makeDeleteButton()
    
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
private extension RoundRobinBottomView {
    func initialize() {
        backgroundColor = Appearance.main600
        layer.cornerRadius = 32.scale
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.shadowColor = Appearance.mono200.withAlphaComponent(0.4).cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4.scale
    }
}

// MARK: Make constraints
private extension RoundRobinBottomView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            shareButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            shareButton.topAnchor.constraint(equalTo: topAnchor, constant: 16.scale),
            shareButton.heightAnchor.constraint(equalToConstant: 56.scale)
        ])
        
        NSLayoutConstraint.activate([
            deleteButton.widthAnchor.constraint(equalToConstant: 56.scale),
            deleteButton.heightAnchor.constraint(equalToConstant: 56.scale),
            deleteButton.leadingAnchor.constraint(lessThanOrEqualTo: shareButton.trailingAnchor, constant: 12.scale),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            deleteButton.topAnchor.constraint(equalTo: topAnchor, constant: 16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension RoundRobinBottomView {
    func makeShareButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.semiBold(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("RoundRobin.Share".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.main100
        view.layer.cornerRadius = 19.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeDeleteButton() -> UIButton {
        let view = UIButton()
        view.layer.cornerRadius = 19.scale
        view.backgroundColor = Appearance.main700
        view.setImage(UIImage(named: "RoundRobin.Delete"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
