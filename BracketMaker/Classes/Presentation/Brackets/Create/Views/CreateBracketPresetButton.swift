//
//  CreateBracketPresetButton.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 06.09.2025.
//

import UIKit

final class CreateBracketPresetButton: UIButton {
    lazy var innerView = makeInnerView()
    lazy var iconView = makeIconView()
    
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
extension CreateBracketPresetButton {
    func setup(preset: TournamentPreset) {
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
        iconView.image = UIImage(named: iconName)
    }
}

// MARK: Private
private extension CreateBracketPresetButton {
    func initialize() {
        backgroundColor = UIColor.clear
        layer.borderColor = Appearance.mono200.cgColor
        layer.borderWidth = 1.scale
        layer.cornerRadius = 16.scale
    }
}

// MARK: Make constraints
private extension CreateBracketPresetButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            innerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4.scale),
            innerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4.scale),
            innerView.topAnchor.constraint(equalTo: topAnchor, constant: 4.scale),
            innerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4.scale)
        ])
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 32.scale),
            iconView.heightAnchor.constraint(equalToConstant: 32.scale),
            iconView.centerXAnchor.constraint(equalTo: innerView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: innerView.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension CreateBracketPresetButton {
    func makeInnerView() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.main600
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = 16.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        innerView.addSubview(view)
        return view
    }
}
