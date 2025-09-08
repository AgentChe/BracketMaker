//
//  PresetsItemButton.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 07.09.2025.
//

import UIKit

final class PresetsItemButton: UIButton {
    lazy var marked = false {
        didSet {
            update()
        }
    }
    
    let preset: TournamentPreset
    
    lazy var innerView = makeInnerView()
    lazy var iconView = makeIconView()
    
    init(preset: TournamentPreset) {
        self.preset = preset
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension PresetsItemButton {
    func initialize() {
        backgroundColor = UIColor.clear
        layer.borderColor = Appearance.mono200.cgColor
        layer.borderWidth = 1.scale
        layer.cornerRadius = 16.scale
    }
    
    func update() {
        innerView.backgroundColor = marked ? Appearance.main100 : Appearance.main700
    }
}

// MARK: Make constraints
private extension PresetsItemButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            innerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4.scale),
            innerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4.scale),
            innerView.topAnchor.constraint(equalTo: topAnchor, constant: 4.scale),
            innerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4.scale)
        ])
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 56.scale),
            iconView.heightAnchor.constraint(equalToConstant: 56.scale),
            iconView.centerXAnchor.constraint(equalTo: innerView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: innerView.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension PresetsItemButton {
    func makeInnerView() -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = 16.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeIconView() -> UIImageView {
        let iconName: String = {
            switch preset {
            case .baseball:
                return "Presets.Baseball"
            case .basketball:
                return "Presets.Basketball"
            case .football:
                return "Presets.Football"
            case .tennis:
                return "Presets.Tennis"
            case .joystick:
                return "Presets.Joystick"
            case .none:
                return "Presets.None"
            }
        }()
        
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: iconName)
        view.translatesAutoresizingMaskIntoConstraints = false
        innerView.addSubview(view)
        return view
    }
}
