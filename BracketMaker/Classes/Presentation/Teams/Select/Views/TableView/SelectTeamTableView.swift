//
//  SelectTeamTableView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 18.09.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class SelectTeamTableView: UITableView {
    private lazy var elements = [SelectTeamTableElement]()
    
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
extension SelectTeamTableView {
    func setup(elements: [SelectTeamTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelectTeam: Signal<Team> {
        didSelectTeamTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension SelectTeamTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .title:
            return dequeueReusableCell(withIdentifier: String(describing: TeamTableTitleCell.self), for: indexPath)
        case .team(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: SelectTeamTableCell.self)) as! SelectTeamTableCell
            cell.setup(element: element)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension SelectTeamTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case let .team(element) = elements[indexPath.row], element.canSelect else { return }
        
        didSelectTeamTrigger.accept(element.team)
    }
}

// MARK: Private
private extension SelectTeamTableView {
    func initialize() {
        backgroundColor = UIColor.clear
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        contentInset = UIEdgeInsets(vertical: 16.scale)
        setContentOffset(CGPoint(x: 0, y: -16.scale), animated: false)
        
        register(TeamTableTitleCell.self, forCellReuseIdentifier: String(describing: TeamTableTitleCell.self))
        register(SelectTeamTableCell.self, forCellReuseIdentifier: String(describing: SelectTeamTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
