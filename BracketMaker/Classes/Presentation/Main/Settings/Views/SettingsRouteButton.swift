//
//  SettingsRouteButton.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 22.08.2025.
//

import UIKit
import RxCocoa

final class SettingsRouteButton: UIButton {
    enum Route {
        case termsOfUse
        case privacyPolicy
        case contactSupport
    }
    
    lazy var iconView = makeIconView()
    lazy var label = makeLabel()
    
    let route: Route
    
    init(route: Route) {
        self.route = route
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SettingsRouteButton {
    var didTap: Signal<Route> {
        rx.tap
            .compactMap { [weak self] in self?.route }
            .asSignal(onErrorSignalWith: .never())
    }
}

// MARK: Private
private extension SettingsRouteButton {
    func initialize() {
        backgroundColor = Appearance.mono200
        layer.cornerRadius = 19.scale
        layer.shadowColor = Appearance.mono100.withAlphaComponent(0.4).cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4.scale
    }
}

// MARK: Make constraints
private extension SettingsRouteButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 24.scale),
            iconView.heightAnchor.constraint(equalToConstant: 24.scale),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12.scale),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SettingsRouteButton {
    func makeIconView() -> UIImageView {
        let iconName: String = {
            switch route {
            case .termsOfUse:
                return "Settings.TermsOfUse"
            case .privacyPolicy:
                return "Settings.PrivacyPolicy"
            case .contactSupport:
                return "Settings.ContactSupport"
            }
        }()
        
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: iconName)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.semiBold(size: 16.scale))
            .lineHeight(24.scale)
            .textAlignment(.left)
        
        let title: String = {
            switch route {
            case .termsOfUse:
                return "Settings.TermsOfUse".localized
            case .privacyPolicy:
                return "Settings.PrivacyPolicy".localized
            case .contactSupport:
                return "Settings.ContactSupport".localized
            }
        }()
        
        let view = UILabel()
        view.attributedText = title.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
