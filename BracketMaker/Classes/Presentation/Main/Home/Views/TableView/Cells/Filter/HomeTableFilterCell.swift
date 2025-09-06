//
//  HomeTableFilterCell.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 06.09.2025.
//

import UIKit

final class HomeTableFilterCell: UITableViewCell {
    var didTapFilter: ((HomeFilterItemButton.Filter) -> Void)?
    
    lazy var container = makeContainer()
    lazy var allButton = makeItemButton(filter: .all)
    lazy var inProgressButton = makeItemButton(filter: .inProgress)
    lazy var completedButton = makeItemButton(filter: .completed)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension HomeTableFilterCell {
    func setup(element: HomeFilterItemButton.Filter) {
        allButton.marked = element == .all
        inProgressButton.marked = element == .inProgress
        completedButton.marked = element == .completed
    }
}

// MARK: Private
private extension HomeTableFilterCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    @objc
    func filterTapped(sender: Any) {
        guard let itemButton = sender as? HomeFilterItemButton else { return }
        
        didTapFilter?(itemButton.filter)
    }
}

// MARK: Make constraints
private extension HomeTableFilterCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.heightAnchor.constraint(equalToConstant: 29.scale)
        ])
        
        NSLayoutConstraint.activate([
            allButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            allButton.topAnchor.constraint(equalTo: container.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            inProgressButton.leadingAnchor.constraint(equalTo: allButton.trailingAnchor, constant: 24.scale),
            inProgressButton.topAnchor.constraint(equalTo: container.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            completedButton.leadingAnchor.constraint(equalTo: inProgressButton.trailingAnchor, constant: 24.scale),
            completedButton.topAnchor.constraint(equalTo: container.topAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension HomeTableFilterCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeItemButton(filter: HomeFilterItemButton.Filter) -> HomeFilterItemButton {
        let view = HomeFilterItemButton(filter: filter)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(filterTapped(sender:)), for: .touchUpInside)
        container.addSubview(view)
        return view
    }
}
