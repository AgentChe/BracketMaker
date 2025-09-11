//
//  CBTeamButton.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 09.09.2025.
//

import UIKit

final class CBTeamButton: UIButton {
    enum Content {
        case none(Int)
        case bye
        case team(Team)
    }
    
    private lazy var noneAttrs = TextAttributes()
        .textColor(Appearance.mono100.withAlphaComponent(0.6))
        .font(Fonts.Inter.medium(size: 16.scale))
    private lazy var normalAttrs = TextAttributes()
        .textColor(Appearance.mono100)
        .font(Fonts.Inter.medium(size: 16.scale))
        .lineBreakMode(.byTruncatingTail)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension CBTeamButton {
    func setup(content: Content) {
        let attrs: TextAttributes = {
            switch content {
            case .none:
                return noneAttrs
            case .bye, .team:
                return normalAttrs
            }
        }()
        
        let title: String = {
            switch content {
            case .none(let index):
                return String(format: "CreateBracket.TeamIndex".localized, index)
            case .bye:
                return "CreateBracket.Bye".localized
            case .team(let team):
                return team.name
            }
        }()
        
        let attrsString = title.attributed(with: attrs)
        setAttributedTitle(attrsString, for: .normal)
        
        backgroundColor = {
            switch content {
            case .bye:
                return UIColor.clear
            case .none, .team:
                return Appearance.mono200
            }
        }()
    }
}

// MARK: Private
private extension CBTeamButton {
    func initialize() {
        layer.cornerRadius = 16.scale
        layer.borderWidth = 2.scale
        layer.borderColor = Appearance.mono200.cgColor
    }
}
