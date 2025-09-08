//
//  PresetsView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 07.09.2025.
//

import UIKit

final class PresetsView: UIView {
    lazy var dimmedView = makeDimmedView()
    lazy var container = makeContainer()
    lazy var titleLabel = makeTitleLabel()
    lazy var closeButton = makeCloseButton()
    lazy var baseballItemButton = makeItemButton(preset: .baseball)
    lazy var basketballItemButton = makeItemButton(preset: .basketball)
    lazy var footballItemButton = makeItemButton(preset: .football)
    lazy var tennisItemButton = makeItemButton(preset: .tennis)
    lazy var joystickItemButton = makeItemButton(preset: .joystick)
    lazy var noneItemButton = makeItemButton(preset: .none)
    lazy var selectButtonContainer = makeSelectButtonContainer()
    lazy var selectButton = makeSelectButton()
    
    lazy var presetsItemsButtons = [
        baseballItemButton,
        basketballItemButton,
        footballItemButton,
        tennisItemButton,
        joystickItemButton,
        noneItemButton
    ]
    
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
extension PresetsView {
    func setup(preset: TournamentPreset) {
        presetsItemsButtons.forEach {
            $0.marked = preset == $0.preset
        }
    }
    
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
private extension PresetsView {
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
            container.heightAnchor.constraint(equalToConstant: 426.scale),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 26.scale),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 24.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 24.scale),
            closeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            baseballItemButton.widthAnchor.constraint(equalToConstant: 80.scale),
            baseballItemButton.heightAnchor.constraint(equalToConstant: 80.scale),
            baseballItemButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            baseballItemButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 80.scale)
        ])
        
        NSLayoutConstraint.activate([
            basketballItemButton.widthAnchor.constraint(equalToConstant: 80.scale),
            basketballItemButton.heightAnchor.constraint(equalToConstant: 80.scale),
            basketballItemButton.leadingAnchor.constraint(equalTo: baseballItemButton.trailingAnchor, constant: 12.scale),
            basketballItemButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 80.scale)
        ])
        
        NSLayoutConstraint.activate([
            footballItemButton.widthAnchor.constraint(equalToConstant: 80.scale),
            footballItemButton.heightAnchor.constraint(equalToConstant: 80.scale),
            footballItemButton.leadingAnchor.constraint(equalTo: basketballItemButton.trailingAnchor, constant: 12.scale),
            footballItemButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 80.scale)
        ])
        
        NSLayoutConstraint.activate([
            tennisItemButton.widthAnchor.constraint(equalToConstant: 80.scale),
            tennisItemButton.heightAnchor.constraint(equalToConstant: 80.scale),
            tennisItemButton.leadingAnchor.constraint(equalTo: footballItemButton.trailingAnchor, constant: 12.scale),
            tennisItemButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 80.scale)
        ])
        
        NSLayoutConstraint.activate([
            joystickItemButton.widthAnchor.constraint(equalToConstant: 80.scale),
            joystickItemButton.heightAnchor.constraint(equalToConstant: 80.scale),
            joystickItemButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            joystickItemButton.topAnchor.constraint(equalTo: baseballItemButton.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            noneItemButton.widthAnchor.constraint(equalToConstant: 80.scale),
            noneItemButton.heightAnchor.constraint(equalToConstant: 80.scale),
            noneItemButton.leadingAnchor.constraint(equalTo: joystickItemButton.trailingAnchor, constant: 12.scale),
            noneItemButton.topAnchor.constraint(equalTo: basketballItemButton.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            selectButtonContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            selectButtonContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            selectButtonContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            selectButtonContainer.heightAnchor.constraint(equalToConstant: 112.scale)
        ])
        
        NSLayoutConstraint.activate([
            selectButton.leadingAnchor.constraint(equalTo: selectButtonContainer.leadingAnchor, constant: 16.scale),
            selectButton.trailingAnchor.constraint(equalTo: selectButtonContainer.trailingAnchor, constant: -16.scale),
            selectButton.topAnchor.constraint(equalTo: selectButtonContainer.topAnchor, constant: 16.scale),
            selectButton.heightAnchor.constraint(equalToConstant: 56.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension PresetsView {
    func makeDimmedView() -> UIView {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = Appearance.mono100
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.main600
        view.layer.cornerRadius = 32.scale
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.semiBold(size: 24.scale))
            .lineHeight(36.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Presets.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCloseButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Close.Black"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeItemButton(preset: TournamentPreset) -> PresetsItemButton {
        let view = PresetsItemButton(preset: preset)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeSelectButtonContainer() -> UIView {
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
    
    func makeSelectButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.semiBold(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Presets.Select".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.main100
        view.layer.cornerRadius = 19.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        selectButtonContainer.addSubview(view)
        return view
    }
}
