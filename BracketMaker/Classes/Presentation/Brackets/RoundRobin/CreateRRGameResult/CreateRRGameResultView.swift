//
//  CreateRRGameResultView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 16.09.2025.
//

import UIKit
import RxSwift

final class CreateRRGameResultView: UIView {
    lazy var dimmedView = makeDimmedView()
    lazy var container = makeContainer()
    lazy var titleLabel = makeTitleLabel()
    lazy var closeButton = makeCloseButton()
    lazy var teamsView = makeTeamsView()
    lazy var goalsForView = makeGoalsForView()
    lazy var createButtonContainer = makeCreateButtonContainer()
    lazy var createButton = makeCreateButton()
    
    private lazy var containerYConstraint = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension CreateRRGameResultView {
    func animateShow() {
        containerYConstraint.isActive = false
        containerYConstraint = container.bottomAnchor.constraint(equalTo: bottomAnchor)
        containerYConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.dimmedView.alpha = 0.3
            self?.layoutIfNeeded()
        })
    }
    
    func animateDismiss(completion: @escaping (() -> Void)) {
        containerYConstraint.isActive = false
        containerYConstraint = container.topAnchor.constraint(equalTo: bottomAnchor)
        containerYConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.dimmedView.alpha = 0
            self?.layoutIfNeeded()
        }, completion: { result in
            completion()
        })
    }
}

// MARK: Make constraints
private extension CreateRRGameResultView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            dimmedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dimmedView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        containerYConstraint = container.topAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([
            containerYConstraint,
            container.heightAnchor.constraint(equalToConstant: 472.scale),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 24.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 24.scale),
            closeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            teamsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            teamsView.trailingAnchor.constraint(equalTo: trailingAnchor),
            teamsView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24.scale),
            teamsView.heightAnchor.constraint(equalToConstant: 56.scale)
        ])
        
        NSLayoutConstraint.activate([
            goalsForView.leadingAnchor.constraint(equalTo: leadingAnchor),
            goalsForView.trailingAnchor.constraint(equalTo: trailingAnchor),
            goalsForView.topAnchor.constraint(equalTo: teamsView.bottomAnchor, constant: 16.scale),
            goalsForView.heightAnchor.constraint(equalToConstant: 168.scale)
        ])
        
        NSLayoutConstraint.activate([
            createButtonContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            createButtonContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            createButtonContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            createButtonContainer.heightAnchor.constraint(equalToConstant: 112.scale)
        ])
        
        NSLayoutConstraint.activate([
            createButton.leadingAnchor.constraint(equalTo: createButtonContainer.leadingAnchor, constant: 16.scale),
            createButton.trailingAnchor.constraint(equalTo: createButtonContainer.trailingAnchor, constant: -16.scale),
            createButton.topAnchor.constraint(equalTo: createButtonContainer.topAnchor, constant: 16.scale),
            createButton.heightAnchor.constraint(equalToConstant: 56.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension CreateRRGameResultView {
    func makeDimmedView() -> UIView {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = Appearance.mono100
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeContainer() -> GradientView {
        let view = GradientView()
        view.layer.shadowColor = Appearance.mono200.withAlphaComponent(0.4).cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 4.scale
        view.gradientLayer.colors = Appearance.mono900.map { $0.cgColor }
        view.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        view.gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.cornerRadius = 32.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.semiBold(size: 24.scale))
            .lineHeight(40.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "CreateRRGameResult.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeCloseButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Close.Black"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeTeamsView() -> CRRGRTeamsView {
        let view = CRRGRTeamsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeGoalsForView() -> CRRGRGoalsForView {
        let view = CRRGRGoalsForView()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeCreateButtonContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.main600
        view.layer.cornerRadius = 32.scale
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = Appearance.mono200.withAlphaComponent(0.4).cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 4.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeCreateButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.semiBold(size: 16.scale))
        
        let view = UIButton()
        view.backgroundColor = Appearance.main100
        view.setAttributedTitle("Save".localized.attributed(with: attrs), for: .normal)
        view.layer.cornerRadius = 19.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        createButtonContainer.addSubview(view)
        return view
    }
}
