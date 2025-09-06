//
//  HomeFilterItemButton.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 06.09.2025.
//

import UIKit

final class HomeFilterItemButton: UIButton {
    enum Filter {
        case all, inProgress, completed
    }
    
    lazy var marked: Bool = false {
        didSet {
            update()
        }
    }
    
    lazy var label = makeLabel()
    lazy var separator = makeSeparator()
    
    let filter: Filter
    
    private lazy var selectedAttrs = TextAttributes()
        .textColor(Appearance.main100)
        .font(Fonts.Inter.semiBold(size: 16.scale))
        .lineHeight(24.scale)
        .textAlignment(.center)
    private lazy var normalAttrs = TextAttributes()
        .textColor(Appearance.mono100)
        .font(Fonts.Inter.semiBold(size: 16.scale))
        .lineHeight(24.scale)
        .textAlignment(.center)
    
    init(filter: Filter) {
        self.filter = filter
        
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
private extension HomeFilterItemButton {
    func initialize() {
        backgroundColor = UIColor.clear
    }
    
    func update() {
        let attrs = marked ? selectedAttrs : normalAttrs
        let text: String = {
            switch filter {
            case .all:
                return "Home.Filter.All".localized
            case .inProgress:
                return "Home.Filter.InProgress".localized
            case .completed:
                return "Home.Filter.Completed".localized
            }
        }()
        label.attributedText = text.attributed(with: attrs)
        
        separator.isHidden = !marked
    }
}

// MARK: Make constraints
private extension HomeFilterItemButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5.scale)
        ])
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension HomeFilterItemButton {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.main100
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
