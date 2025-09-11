//
//  CBBracketTypesView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 08.09.2025.
//

import UIKit
import RxCocoa

final class CBBracketTypesView: UIView {
    lazy var singleEliminationButton = makeItemButton(bracketType: .singleElimination)
    lazy var doubleEliminationButton = makeItemButton(bracketType: .doubleElimination)
    lazy var roundRobinButton = makeItemButton(bracketType: .roundRobin)
    
    private lazy var buttos = [
        singleEliminationButton,
        doubleEliminationButton,
        roundRobinButton
    ]
    
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
extension CBBracketTypesView {
    func setup(bracketType: CBBracketTypeItemButton.BracketType) {
        singleEliminationButton.marked = singleEliminationButton.bracketType == bracketType
        doubleEliminationButton.marked = doubleEliminationButton.bracketType == bracketType
        roundRobinButton.marked = roundRobinButton.bracketType == bracketType
    }
    
    var didSelect: Signal<CBBracketTypeItemButton.BracketType> {
        Signal
            .merge(buttos.map { $0.didTap })
    }
}

// MARK: Private
private extension CBBracketTypesView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension CBBracketTypesView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            singleEliminationButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            singleEliminationButton.topAnchor.constraint(equalTo: topAnchor),
            singleEliminationButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            singleEliminationButton.widthAnchor.constraint(equalToConstant: 114.scale),
            singleEliminationButton.heightAnchor.constraint(equalToConstant: 49.scale)
        ])
        
        NSLayoutConstraint.activate([
            doubleEliminationButton.leadingAnchor.constraint(equalTo: singleEliminationButton.trailingAnchor, constant: 8.scale),
            doubleEliminationButton.topAnchor.constraint(equalTo: topAnchor),
            doubleEliminationButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            doubleEliminationButton.widthAnchor.constraint(equalToConstant: 114.scale),
            doubleEliminationButton.heightAnchor.constraint(equalToConstant: 49.scale)
        ])
        
        NSLayoutConstraint.activate([
            roundRobinButton.leadingAnchor.constraint(equalTo: doubleEliminationButton.trailingAnchor, constant: 8.scale),
            roundRobinButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            roundRobinButton.topAnchor.constraint(equalTo: topAnchor),
            roundRobinButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            roundRobinButton.widthAnchor.constraint(equalToConstant: 114.scale),
            roundRobinButton.heightAnchor.constraint(equalToConstant: 49.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension CBBracketTypesView {
    func makeItemButton(bracketType: CBBracketTypeItemButton.BracketType) -> CBBracketTypeItemButton {
        let view = CBBracketTypeItemButton(bracketType: bracketType)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
