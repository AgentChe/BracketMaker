//
//  TeamsCreateField.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 24.08.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class TeamsCreateField: UIView {
    lazy var textField = makeTextField()
    
    private lazy var didCreateTrigger = PublishRelay<String>()
    private lazy var didAttemptCreateWhenLockPaygateTrigger = PublishRelay<Void>()
    
    private lazy var canCreate = true
    
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
extension TeamsCreateField {
    func setup(canCreate: Bool) {
        self.canCreate = canCreate
    }
    
    var didCreate: Signal<String> {
        didCreateTrigger.asSignal()
    }
    
    var didAttemptCreateWhenLockPaygate: Signal<Void> {
        didAttemptCreateWhenLockPaygateTrigger.asSignal()
    }
}

// MARK: UITextFieldDelegate
extension TeamsCreateField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !canCreate {
            didAttemptCreateWhenLockPaygateTrigger.accept(Void())
            
            return false
        }
        
        let name = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !name.isEmpty {
            didCreateTrigger.accept(name)
            
            textField.resignFirstResponder()
            
            textField.text = nil
        }
    
        return !name.isEmpty
    }
}

// MARK: Private
private extension TeamsCreateField {
    func initialize() {
        backgroundColor = Appearance.mono200
        layer.cornerRadius = 16.scale
        layer.shadowColor = Appearance.mono100.withAlphaComponent(0.4).cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4.scale
    }
}

// MARK: Make constraints
private extension TeamsCreateField {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension TeamsCreateField {
    func makeTextField() -> PaddingTextField {
        let textAttrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.medium(size: 16.scale))
            .lineHeight(24.scale)
            .textAlignment(.left)
        let placeholderAttrs = TextAttributes()
            .textColor(Appearance.mono100.withAlphaComponent(0.5))
            .font(Fonts.Inter.medium(size: 16.scale))
            .lineHeight(24.scale)
            .textAlignment(.left)
        
        let view = PaddingTextField()
        view.delegate = self
        view.backgroundColor = UIColor.clear
        view.borderStyle = .none
        view.returnKeyType = .done
        view.textPadding = UIEdgeInsets(vertical: 16.scale, horizontal: 16.scale)
        view.defaultTextAttributes = textAttrs.dictionary
        view.attributedPlaceholder = "Teams.Create.Placeholder".localized.attributed(with: placeholderAttrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
