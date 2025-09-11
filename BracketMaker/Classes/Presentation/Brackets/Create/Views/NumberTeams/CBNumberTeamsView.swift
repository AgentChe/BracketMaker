//
//  CBNumberTeamsView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 08.09.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class CBNumberTeamsView: UIView {
    lazy var titleLabel = makeTitleLabel()
    lazy var numberPicker = makeNumberPicker()
    
    private lazy var didChangeTrigger = PublishRelay<Int>()
    
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
extension CBNumberTeamsView {
    var didChange: Signal<Int> {
        didChangeTrigger.asSignal()
            .startWith(numberPicker.selectedValue)
    }
}

// MARK: Private
private extension CBNumberTeamsView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension CBNumberTeamsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            numberPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            numberPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            numberPicker.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.scale),
            numberPicker.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension CBNumberTeamsView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.medium(size: 24.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "CreateBracket.NumberTeams.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeNumberPicker() -> HorizontalNumberPicker {
        let view = HorizontalNumberPicker()
        view.onValueChanged = { [weak self] value in
            self?.didChangeTrigger.accept(value)
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
