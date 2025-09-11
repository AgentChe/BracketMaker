//
//  CBBracketTypeItemButton.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 08.09.2025.
//

import UIKit
import RxCocoa

final class CBBracketTypeItemButton: UIButton {
    enum BracketType {
        case singleElimination
        case doubleElimination
        case roundRobin
    }
    
    lazy var marked = false {
        didSet {
            update()
        }
    }
    
    let bracketType: BracketType
    
    private lazy var selectedAttrs = TextAttributes()
        .textColor(Appearance.mono200)
        .font(Fonts.Inter.semiBold(size: 14.scale))
    private lazy var normalAttrs = TextAttributes()
        .textColor(Appearance.mono100)
        .font(Fonts.Inter.semiBold(size: 14.scale))
    
    init(bracketType: BracketType) {
        self.bracketType = bracketType
        
        super.init(frame: .zero)
        
        initialize()
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension CBBracketTypeItemButton {
    var didTap: Signal<BracketType> {
        rx.tap
            .compactMap { [weak self] in self?.bracketType  }
            .asSignal(onErrorSignalWith: .never())
    }
}

// MARK: Private
private extension CBBracketTypeItemButton {
    func initialize() {
        layer.cornerRadius = 24.5.scale
    }
    
    func update() {
        backgroundColor = marked ? Appearance.main100 : Appearance.main700
        
        let attrs = marked ? selectedAttrs : normalAttrs
        setAttributedTitle(bracketType.title.attributed(with: attrs), for: .normal)
        
    }
}

// MARK: Additional
private extension CBBracketTypeItemButton.BracketType {
    var title: String {
        switch self {
        case .singleElimination:
            return "CreateBracket.BracketType.SingleElimination".localized
        case .doubleElimination:
            return "CreateBracket.BracketType.DoubleElimination".localized
        case .roundRobin:
            return "CreateBracket.BracketType.RoundRobin".localized
        }
    }
}
