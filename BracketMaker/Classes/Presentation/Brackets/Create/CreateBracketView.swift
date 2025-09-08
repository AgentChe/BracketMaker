//
//  CreateBracketView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 06.09.2025.
//

import UIKit

final class CreateBracketView: GradientView {
    lazy var nameField = makeNameField()
    lazy var presetButton = makePresetButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UITextFieldDelegate
extension CreateBracketView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: Private
private extension CreateBracketView {
    func initialize() {
        gradientLayer.colors = Appearance.mono900.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    }
}

// MARK: Make constraints
private extension CreateBracketView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            nameField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            nameField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -88.scale),
            nameField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            presetButton.leadingAnchor.constraint(equalTo: nameField.trailingAnchor, constant: 8.scale),
            presetButton.topAnchor.constraint(equalTo: nameField.topAnchor),
            presetButton.bottomAnchor.constraint(equalTo: nameField.bottomAnchor),
            presetButton.widthAnchor.constraint(equalToConstant: 64.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension CreateBracketView {
    func makeNameField() -> PaddingTextField {
        let textAttrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.medium(size: 18.scale))
            .lineHeight(24.scale)
            .textAlignment(.left)
        let placeholderAttrs = TextAttributes()
            .textColor(Appearance.mono100.withAlphaComponent(0.4))
            .font(Fonts.Inter.medium(size: 18.scale))
            .lineHeight(24.scale)
            .textAlignment(.left)
        
        let view = PaddingTextField()
        view.delegate = self
        view.backgroundColor = Appearance.mono200
        view.layer.cornerRadius = 16.scale
        view.layer.shadowColor = Appearance.mono200.withAlphaComponent(0.4).cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 4.scale
        view.borderStyle = .none
        view.returnKeyType = .default
        view.textPadding = UIEdgeInsets(value: 16.scale)
        view.defaultTextAttributes = textAttrs.dictionary
        view.attributedPlaceholder = "CreateBracket.Name.Placeholder".localized.attributed(with: placeholderAttrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePresetButton() -> CreateBracketPresetButton {
        let view = CreateBracketPresetButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
