//
//  BracketInfoView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 08.09.2025.
//

import UIKit

final class BracketInfoView: GradientView {
    lazy var scrollView = makeScrollView()
    lazy var singleEliminationView = makeSingleEliminationView()
    lazy var doubleEliminationView = makeDoubleEliminationView()
    lazy var roundRobinView = makeRoundRobinView()
    lazy var presetsView = makePresetsView()
    
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
private extension BracketInfoView {
    func initialize() {
        gradientLayer.colors = Appearance.mono900.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    }
}

// MARK: Make constraints
private extension BracketInfoView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            singleEliminationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            singleEliminationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            singleEliminationView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            singleEliminationView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            singleEliminationView.topAnchor.constraint(equalTo: scrollView.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            doubleEliminationView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            doubleEliminationView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            doubleEliminationView.topAnchor.constraint(equalTo: singleEliminationView.bottomAnchor, constant: 40.scale)
        ])
        
        NSLayoutConstraint.activate([
            roundRobinView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            roundRobinView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            roundRobinView.topAnchor.constraint(equalTo: doubleEliminationView.bottomAnchor, constant: 40.scale)
        ])
        
        NSLayoutConstraint.activate([
            presetsView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            presetsView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            presetsView.topAnchor.constraint(equalTo: roundRobinView.bottomAnchor, constant: 40.scale),
            presetsView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension BracketInfoView {
    func makeScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.backgroundColor = UIColor.clear
        view.showsVerticalScrollIndicator = false
        view.contentInset = UIEdgeInsets(vertical: 16.scale)
        view.setContentOffset(CGPoint(x: 0, y: -16.scale), animated: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSingleEliminationView() -> BISingleEliminationView {
        let view = BISingleEliminationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeDoubleEliminationView() -> BIDoubleEliminationView {
        let view = BIDoubleEliminationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeRoundRobinView() -> BIRoundRobinView {
        let view = BIRoundRobinView()
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makePresetsView() -> BIPresetsView {
        let view = BIPresetsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
}
