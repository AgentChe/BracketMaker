//
//  CRRGRGoalsForItemView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 17.09.2025.
//

import UIKit
import RxCocoa

final class CRRGRGoalsForItemView: UIView {
    lazy var incrementButton = makeButton(symbol: "+")
    lazy var goalsForLabel = makeLabel()
    lazy var decrementButton = makeButton(symbol: "-")
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.mono100)
        .font(Fonts.Inter.medium(size: 32.scale))
        .lineHeight(48.scale)
        .textAlignment(.center)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension CRRGRGoalsForItemView {
    func setup(goalsFor: Int) {
        goalsForLabel.attributedText = String(goalsFor).attributed(with: attrs)
    }
    
    var didTapIncrement: Signal<Void> {
        incrementButton.rx.tap.asSignal()
    }
    
    var didTapDescrement: Signal<Void> {
        decrementButton.rx.tap.asSignal()
    }
}

// MARK: Private
private extension CRRGRGoalsForItemView {
    func initialize() {
        backgroundColor = Appearance.mono200
        layer.shadowColor = Appearance.mono200.withAlphaComponent(0.4).cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4.scale
        layer.cornerRadius = 19.scale
    }
}

// MARK: Make constraints
private extension CRRGRGoalsForItemView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            incrementButton.widthAnchor.constraint(equalToConstant: 24.scale),
            incrementButton.heightAnchor.constraint(equalToConstant: 24.scale),
            incrementButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            incrementButton.topAnchor.constraint(equalTo: topAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            goalsForLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            goalsForLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            decrementButton.widthAnchor.constraint(equalToConstant: 24.scale),
            decrementButton.heightAnchor.constraint(equalToConstant: 24.scale),
            decrementButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            decrementButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension CRRGRGoalsForItemView {
    func makeButton(symbol: String) -> TapAreaButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.medium(size: 24.scale))
        
        let view = TapAreaButton()
        view.setAttributedTitle(symbol.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
