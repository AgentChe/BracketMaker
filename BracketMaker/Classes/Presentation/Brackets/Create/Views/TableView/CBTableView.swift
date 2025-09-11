//
//  CBTableView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 09.09.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class CBTableView: UITableView {
    private lazy var elements = [CBTableElement]()
    
    private lazy var didSelectTrigger = PublishRelay<TeamPosition>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension CBTableView {
    func setup(elements: [CBTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelect: Signal<TeamPosition> {
        didSelectTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension CBTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .oneRowTeam(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: CBTableTeamCell.self), for: indexPath) as! CBTableTeamCell
            cell.setup(element: element)
            cell.didTap = { [weak self] in
                self?.didSelectTrigger.accept(element)
            }
            return cell
        case .vsRow(let team1, let team2):
            let cell = dequeueReusableCell(withIdentifier: String(describing: CBTableVSCell.self), for: indexPath) as! CBTableVSCell
            cell.setup(team1: team1, team2: team2)
            cell.didTapTeam1 = { [weak self] in
                self?.didSelectTrigger.accept(team1)
            }
            cell.didTapTeam2 = { [weak self] in
                self?.didSelectTrigger.accept(team2)
            }
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension CBTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80.scale
    }
}

// MARK: Private
private extension CBTableView {
    func initialize() {
        backgroundColor = UIColor.clear
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        contentInset = UIEdgeInsets(b: 16.scale)
        setContentOffset(CGPoint.zero, animated: false)
        
        register(CBTableTeamCell.self, forCellReuseIdentifier: String(describing: CBTableTeamCell.self))
        register(CBTableVSCell.self, forCellReuseIdentifier: String(describing: CBTableVSCell.self))
        
        dataSource = self
        delegate = self
    }
}
