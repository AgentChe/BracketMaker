//
//  TeamsTableView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 24.08.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class TeamsTableView: UITableView {
    private lazy var elements = [TeamTableElement]()
    
    private lazy var didDeleteTrigger = PublishRelay<String>()
    private lazy var didSelectTeamTrigger = PublishRelay<Team>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension TeamsTableView {
    func setup(elements: [TeamTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didDelete: Signal<String> {
        didDeleteTrigger.asSignal()
    }
    
    var didSelectTeam: Signal<Team> {
        didSelectTeamTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension TeamsTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .title:
            return dequeueReusableCell(withIdentifier: String(describing: TeamTableTitleCell.self), for: indexPath)
        case .team(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: TeamsTableCell.self)) as! TeamsTableCell
            cell.setup(element: element)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension TeamsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard case .team = elements[indexPath.row] else { return nil }
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] action, view, completion in
            guard let self else { return }
            
            let teamId: String? = {
                guard case .team(let team) = self.elements[indexPath.row] else { return nil }
                return team.id
            }()
            
            if let teamId {
                didDeleteTrigger.accept(teamId)
            }
            
            completion(true)
        }
        deleteAction.title = "Delete".localized
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case let .team(team) = elements[indexPath.row] else { return }
        
        didSelectTeamTrigger.accept(team)
    }
}

// MARK: Private
private extension TeamsTableView {
    func initialize() {
        backgroundColor = UIColor.clear
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        contentInset = UIEdgeInsets(vertical: 16.scale)
        setContentOffset(CGPoint(x: 0, y: -16.scale), animated: false)
        
        register(TeamTableTitleCell.self, forCellReuseIdentifier: String(describing: TeamTableTitleCell.self))
        register(TeamsTableCell.self, forCellReuseIdentifier: String(describing: TeamsTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
