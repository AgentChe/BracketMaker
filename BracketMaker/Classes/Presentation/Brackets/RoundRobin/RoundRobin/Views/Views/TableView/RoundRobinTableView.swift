//
//  RoundRobinTableView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 16.09.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class RoundRobinTableView: UITableView {
    private lazy var elements = [RoundRobinTableElement]()
    
    private lazy var didSelectGameElementTrigger = PublishRelay<RoundRobinTableGameElement>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension RoundRobinTableView {
    func setup(elements: [RoundRobinTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelectGameElement: Signal<RoundRobinTableGameElement> {
        didSelectGameElementTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension RoundRobinTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .ptsHeader:
            return dequeueReusableCell(withIdentifier: String(describing: RoundRobinTablePtsHeaderCell.self), for: indexPath)
        case .ptsTeam(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: RoundRobinTablePtsTeamCell.self), for: indexPath) as! RoundRobinTablePtsTeamCell
            cell.setup(element: element)
            return cell
        case .game(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: RoundRobinTableGameCell.self), for: indexPath) as! RoundRobinTableGameCell
            cell.setup(element: element)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension RoundRobinTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch elements[indexPath.row] {
        case .game:
            return 76.scale
        case .ptsHeader:
            return 36.scale
        case .ptsTeam:
            return 36.scale
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch elements[indexPath.row] {
        case .game(let element):
            didSelectGameElementTrigger.accept(element)
        default:
            return 
        }
    }
}

// MARK: Private
private extension RoundRobinTableView {
    func initialize() {
        backgroundColor = UIColor.clear
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        contentInset = UIEdgeInsets(vertical: 16.scale)
        setContentOffset(CGPoint(x: 0, y: -16.scale), animated: false)
        
        register(RoundRobinTablePtsHeaderCell.self, forCellReuseIdentifier: String(describing: RoundRobinTablePtsHeaderCell.self))
        register(RoundRobinTablePtsTeamCell.self, forCellReuseIdentifier: String(describing: RoundRobinTablePtsTeamCell.self))
        register(RoundRobinTableGameCell.self, forCellReuseIdentifier: String(describing: RoundRobinTableGameCell.self))
        
        dataSource = self
        delegate = self
    }
}
