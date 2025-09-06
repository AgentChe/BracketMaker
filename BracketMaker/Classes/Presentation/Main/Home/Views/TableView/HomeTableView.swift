//
//  HomeTableView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 05.09.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeTableView: UITableView {
    private lazy var elements = [HomeTableElement]()
    
    private lazy var didTapPresetTrigger = PublishRelay<TournamentPreset>()
    private lazy var didTapAddFirstBracketTrigger = PublishRelay<Void>()
    private lazy var didChangeFilterTrigger = PublishRelay<HomeFilterItemButton.Filter>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension HomeTableView {
    func setup(elements: [HomeTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didTapPreset: Signal<TournamentPreset> {
        didTapPresetTrigger.asSignal()
    }
    
    var didTapAddFirstBracket: Signal<Void> {
        didTapAddFirstBracketTrigger.asSignal()
    }
    
    var didChangeFilter: Signal<HomeFilterItemButton.Filter> {
        didChangeFilterTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension HomeTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .presets:
            let cell = dequeueReusableCell(withIdentifier: String(describing: HomeTablePresetsCell.self), for: indexPath) as! HomeTablePresetsCell
            cell.didTapPreset = { [weak self] preset in
                self?.didTapPresetTrigger.accept(preset)
            }
            return cell
        case .addFirstBracket:
            let cell = dequeueReusableCell(withIdentifier: String(describing: HomeTableAddFirstBracketCell.self), for: indexPath) as! HomeTableAddFirstBracketCell
            cell.didTapCreate = { [weak self] in
                self?.didTapAddFirstBracketTrigger.accept(Void())
            }
            return cell
        case .title:
            return dequeueReusableCell(withIdentifier: String(describing: HomeTableTitleCell.self), for: indexPath)
        case .demo:
            return dequeueReusableCell(withIdentifier: String(describing: HomeTableDemoCell.self), for: indexPath)
        case .filter(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: HomeTableFilterCell.self), for: indexPath) as! HomeTableFilterCell
            cell.setup(element: element)
            cell.didTapFilter = { [weak self] filter in
                self?.didChangeFilterTrigger.accept(filter)
            }
            return cell
        case .bracket(let element):
            switch element.state {
            case .inProgress:
                let cell = dequeueReusableCell(withIdentifier: String(describing: HomeTableInProgressBracketCell.self), for: indexPath) as! HomeTableInProgressBracketCell
                cell.setup(element: element.bracket)
                return cell
            case .completed(let winner):
                let cell = dequeueReusableCell(withIdentifier: String(describing: HomeTableCompletedBracketCell.self), for: indexPath) as! HomeTableCompletedBracketCell
                cell.setup(bracket: element.bracket, winner: winner)
                return cell
            }
        }
    }
}

// MARK: UITableViewDelegate
extension HomeTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: Private
private extension HomeTableView {
    func initialize() {
        backgroundColor = UIColor.clear
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        contentInset = UIEdgeInsets(vertical: 16.scale)
        setContentOffset(CGPoint(x: 0, y: -16.scale), animated: false)
        
        register(HomeTablePresetsCell.self, forCellReuseIdentifier: String(describing: HomeTablePresetsCell.self))
        register(HomeTableAddFirstBracketCell.self, forCellReuseIdentifier: String(describing: HomeTableAddFirstBracketCell.self))
        register(HomeTableTitleCell.self, forCellReuseIdentifier: String(describing: HomeTableTitleCell.self))
        register(HomeTableDemoCell.self, forCellReuseIdentifier: String(describing: HomeTableDemoCell.self))
        register(HomeTableFilterCell.self, forCellReuseIdentifier: String(describing: HomeTableFilterCell.self))
        register(HomeTableInProgressBracketCell.self, forCellReuseIdentifier: String(describing: HomeTableInProgressBracketCell.self))
        register(HomeTableCompletedBracketCell.self, forCellReuseIdentifier: String(describing: HomeTableCompletedBracketCell.self))
        
        dataSource = self
        delegate = self
    }
}
