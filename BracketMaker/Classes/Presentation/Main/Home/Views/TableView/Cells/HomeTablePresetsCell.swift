//
//  HomeTablePresetsCell.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 05.09.2025.
//

import UIKit

final class HomeTablePresetsCell: UITableViewCell {
    var didTapPreset: ((TournamentPreset) -> Void)?
    
    lazy var titleLabel = makeTitleLabel()
    lazy var presetsContainer = makePresetsContainer()
    lazy var footballButton = makePresetButton(iconName: "Home.Preset.Football")
    lazy var basketballButton  = makePresetButton(iconName: "Home.Preset.Basketball")
    lazy var baseballButton  = makePresetButton(iconName: "Home.Preset.Baseball")
    lazy var tennisButton  = makePresetButton(iconName: "Home.Preset.Tennis")
    lazy var joystickButton  = makePresetButton(iconName: "Home.Preset.Joystick")
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension HomeTablePresetsCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    @objc
    func presetTapped(sender: UIButton) {
        if sender === footballButton {
            didTapPreset?(.football)
        } else if sender === basketballButton {
            didTapPreset?(.basketball)
        } else if sender === baseballButton {
            didTapPreset?(.baseball)
        } else if sender === tennisButton {
            didTapPreset?(.tennis)
        } else if sender === joystickButton {
            didTapPreset?(.joystick)
        }
    }
}

// MARK: Make constraints
private extension HomeTablePresetsCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            presetsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            presetsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            presetsContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.scale),
            presetsContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            presetsContainer.heightAnchor.constraint(equalToConstant: 64.scale)
        ])
        
        NSLayoutConstraint.activate([
            footballButton.widthAnchor.constraint(equalToConstant: 64.scale),
            footballButton.heightAnchor.constraint(equalToConstant: 64.scale),
            footballButton.leadingAnchor.constraint(equalTo: presetsContainer.leadingAnchor),
            footballButton.centerYAnchor.constraint(equalTo: presetsContainer.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            basketballButton.widthAnchor.constraint(equalToConstant: 64.scale),
            basketballButton.heightAnchor.constraint(equalToConstant: 64.scale),
            basketballButton.leadingAnchor.constraint(equalTo: footballButton.trailingAnchor, constant: 8.scale),
            basketballButton.centerYAnchor.constraint(equalTo: presetsContainer.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            baseballButton.widthAnchor.constraint(equalToConstant: 64.scale),
            baseballButton.heightAnchor.constraint(equalToConstant: 64.scale),
            baseballButton.leadingAnchor.constraint(equalTo: basketballButton.trailingAnchor, constant: 8.scale),
            baseballButton.centerYAnchor.constraint(equalTo: presetsContainer.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            tennisButton.widthAnchor.constraint(equalToConstant: 64.scale),
            tennisButton.heightAnchor.constraint(equalToConstant: 64.scale),
            tennisButton.leadingAnchor.constraint(equalTo: baseballButton.trailingAnchor, constant: 8.scale),
            tennisButton.centerYAnchor.constraint(equalTo: presetsContainer.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            joystickButton.widthAnchor.constraint(equalToConstant: 64.scale),
            joystickButton.heightAnchor.constraint(equalToConstant: 64.scale),
            joystickButton.leadingAnchor.constraint(equalTo: tennisButton.trailingAnchor, constant: 8.scale),
            joystickButton.centerYAnchor.constraint(equalTo: presetsContainer.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension HomeTablePresetsCell {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.medium(size: 24.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Home.Presents.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makePresetsContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makePresetButton(iconName: String) -> UIButton {
        let view = UIButton()
        view.setImage(UIImage(named: iconName), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(presetTapped(sender:)), for: .touchUpInside)
        presetsContainer.addSubview(view)
        return view
    }
}
