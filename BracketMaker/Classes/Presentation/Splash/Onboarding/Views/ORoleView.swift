//
//  ORoleView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 22.08.2025.
//

import UIKit

final class ORoleView: OSlideView {
    lazy var imageView = makeImageView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var trainerButton = makeTrainerButton()
    lazy var playerButton = makePlayerButton()
    
    private let onContinue: () -> Void
    
    init(onContinue: @escaping () -> Void) {
        self.onContinue = onContinue
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension ORoleView {
    func initialize() {
        gradientLayer.colors = Appearance.mono900.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    }
    
    @objc
    func continueTapped() {
        onContinue()
    }
}

// MARK: Make constraints
private extension ORoleView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: ScreenSize.isIphoneXFamily ? 80.scale : 30.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 58.scale),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 390.scale),
            imageView.heightAnchor.constraint(equalToConstant: 390.scale)
        ])
        
        NSLayoutConstraint.activate([
            trainerButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            trainerButton.widthAnchor.constraint(equalToConstant: 173.scale),
            trainerButton.heightAnchor.constraint(equalToConstant: 56.scale),
            trainerButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -28.scale)
        ])
        
        NSLayoutConstraint.activate([
            playerButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            playerButton.widthAnchor.constraint(equalToConstant: 173.scale),
            playerButton.heightAnchor.constraint(equalToConstant: 56.scale),
            playerButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -28.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ORoleView {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: "Onboarding.Role")
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.semiBold(size: 28.scale))
            .lineHeight(34.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Onboarding.Role.Title".localized.attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.regular(size: 16.scale))
            .lineHeight(21.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Onboarding.Role.SubTitle".localized.attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTrainerButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.semiBold(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Onboarding.Role.Trainer".localized.attributed(with: attrs), for: .normal)
        view.layer.cornerRadius = 19.scale
        view.backgroundColor = Appearance.main100
        view.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePlayerButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.semiBold(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Onboarding.Role.Player".localized.attributed(with: attrs), for: .normal)
        view.layer.cornerRadius = 19.scale
        view.backgroundColor = Appearance.main600
        view.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
