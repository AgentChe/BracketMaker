//
//  SettingsView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 22.08.2025.
//

import UIKit

final class SettingsView: GradientView {
    lazy var titleLabel = makeTitleLabel()
    lazy var termsOfUseButton = makeRouteButton(route: .termsOfUse)
    lazy var privacyPolicyButton = makeRouteButton(route: .privacyPolicy)
    lazy var contactSupportButton = makeRouteButton(route: .contactSupport)
    lazy var paygateButton = makePaygateButton()
    
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
private extension SettingsView {
    func initialize() {
        gradientLayer.colors = Appearance.mono900.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    }
}

// MARK: Make constraints
private extension SettingsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            termsOfUseButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            termsOfUseButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            termsOfUseButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.scale),
            termsOfUseButton.heightAnchor.constraint(equalToConstant: 56.scale)
        ])
        
        NSLayoutConstraint.activate([
            privacyPolicyButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            privacyPolicyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            privacyPolicyButton.topAnchor.constraint(equalTo: termsOfUseButton.bottomAnchor, constant: 16.scale),
            privacyPolicyButton.heightAnchor.constraint(equalToConstant: 56.scale)
        ])
        
        NSLayoutConstraint.activate([
            contactSupportButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            contactSupportButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            contactSupportButton.topAnchor.constraint(equalTo: privacyPolicyButton.bottomAnchor, constant: 16.scale),
            contactSupportButton.heightAnchor.constraint(equalToConstant: 56.scale)
        ])
        
        NSLayoutConstraint.activate([
            paygateButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            paygateButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            paygateButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.scale),
            paygateButton.heightAnchor.constraint(equalToConstant: 64.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension SettingsView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.semiBold(size: 28.scale))
            .lineHeight(34.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Settings.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeRouteButton(route: SettingsRouteButton.Route) -> SettingsRouteButton {
        let view = SettingsRouteButton(route: route)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePaygateButton() -> SettingsPaygateButton {
        let view = SettingsPaygateButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
