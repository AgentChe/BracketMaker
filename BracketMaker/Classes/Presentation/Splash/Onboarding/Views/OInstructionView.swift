//
//  OInstructionView.swift
//  InventoryManagement
//
//  Created by Андрей Чернышев on 08.04.2025.
//

import UIKit

final class OInstructionView: OSlideView {
    enum Instruction {
        case tournament
        case teams
        case organized
    }
    
    lazy var imageView = makeImageView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var continueButton = makeContinueButton()
    
    private let onContinue: () -> Void
    
    private let instruction: Instruction
    
    init(instruction: Instruction, onContinue: @escaping () -> Void) {
        self.instruction = instruction
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
private extension OInstructionView {
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
private extension OInstructionView {
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
            imageView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 24.scale),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 390.scale),
            imageView.heightAnchor.constraint(equalToConstant: 390.scale)
        ])
        
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            continueButton.heightAnchor.constraint(equalToConstant: 56.scale),
            continueButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -28.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension OInstructionView {
    func makeImageView() -> UIImageView {
        let image: UIImage? = {
            switch instruction {
            case .tournament:
                return UIImage(named: "Onboarding.Instruction.Tournament")
            case .teams:
                return UIImage(named: "Onboarding.Instruction.Teams")
            case .organized:
                return UIImage(named: "Onboarding.Instruction.Organized")
            }
        }()
        
        let view = UIImageView()
        view.image = image
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
        
        let title: String = {
            switch instruction {
            case .tournament:
                return "Onboarding.Instruction.Tournament.Title".localized
            case .teams:
                return "Onboarding.Instruction.Teams.Title".localized
            case .organized:
                return "Onboarding.Instruction.Organized.Title".localized
            }
        }()
        
        let view = UILabel()
        view.attributedText = title.attributed(with: attrs)
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
        
        let subTitle: String = {
            switch instruction {
            case .tournament:
                return "Onboarding.Instruction.Tournament.SubTitle".localized
            case .teams:
                return "Onboarding.Instruction.Teams.SubTitle".localized
            case .organized:
                return "Onboarding.Instruction.Organized.SubTitle".localized
            }
        }()
        
        let view = UILabel()
        view.attributedText = subTitle.attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeContinueButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.semiBold(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Continue".localized.attributed(with: attrs), for: .normal)
        view.layer.cornerRadius = 19.scale
        view.backgroundColor = Appearance.main100
        view.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
