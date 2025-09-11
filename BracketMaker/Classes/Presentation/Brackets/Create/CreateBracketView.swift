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
    lazy var bracketTypesView = makeBracketTypesView()
    lazy var numberTeamsView = makeNumberTeamsView()
    lazy var teamsHeaderView = makeTeamsHeaderView()
    lazy var tableView = makeTableView()
    lazy var createButtonContainer = makeCreateButtonContainer()
    lazy var createButton = makeCreateButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension CreateBracketView {
    func setup(canCreate: Bool) {
        createButton.isEnabled = canCreate
        createButton.alpha = canCreate ? 1 : 0.4
        createButton.backgroundColor = canCreate ? Appearance.main100 : Appearance.mono100
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
        
        NSLayoutConstraint.activate([
            bracketTypesView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            bracketTypesView.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 20.scale)
        ])
        
        NSLayoutConstraint.activate([
            numberTeamsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            numberTeamsView.trailingAnchor.constraint(equalTo: trailingAnchor),
            numberTeamsView.topAnchor.constraint(equalTo: bracketTypesView.bottomAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            teamsHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            teamsHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            teamsHeaderView.topAnchor.constraint(equalTo: numberTeamsView.bottomAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: teamsHeaderView.bottomAnchor, constant: 2.scale),
            tableView.bottomAnchor.constraint(equalTo: createButtonContainer.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            createButtonContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            createButtonContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            createButtonContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
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
    
    func makeBracketTypesView() -> CBBracketTypesView {
        let view = CBBracketTypesView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeNumberTeamsView() -> CBNumberTeamsView {
        let view = CBNumberTeamsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTeamsHeaderView() -> CBTeamsHeaderView {
        let view = CBTeamsHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTableView() -> CBTableView {
        let view = CBTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
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
        addSubview(view)
        return view
    }
    
    func makeCreateButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.semiBold(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("CreateBracket.Create".localized.attributed(with: attrs), for: .normal)
        view.layer.cornerRadius = 19.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        createButtonContainer.addSubview(view)
        return view
    }
}
