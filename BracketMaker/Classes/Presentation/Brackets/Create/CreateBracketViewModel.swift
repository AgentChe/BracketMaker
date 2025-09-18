//
//  CreateBracketViewModel.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 06.09.2025.
//

import RxSwift
import RxCocoa

final class CreateBracketViewModel {
    enum Action {
        case selectPreset(TournamentPreset)
        case openInfo
        case selectTeam((TeamPosition, [String]))
        case openPaygate
        case close
    }
    
    private let initialPreset: Driver<TournamentPreset?>
    
    private lazy var tournamentManager = TournamentManager()
    
    init(preset: TournamentPreset?) {
        self.initialPreset = BehaviorRelay(value: preset).asDriver()
    }
}

// MARK: Public
extension CreateBracketViewModel {
    struct Input {
        let didTapSelectPreset: Signal<Void>
        let didSelectPreset: Signal<TournamentPreset>
        let didTapInfo: Signal<Void>
        let didSelectBracketType: Signal<CBBracketTypeItemButton.BracketType>
        let didChangeNumberTeams: Signal<Int>
        let didChangeName: Signal<String>
        let didTapShuffle: Signal<Void>
        let didTapTeamPosition: Signal<TeamPosition>
        let didSelectTeam: Signal<(Team, TeamPosition)>
        let didTapCreate: Signal<Void>
    }
    
    struct Output {
        let preset: Driver<TournamentPreset>
        let action: Driver<Action>
        let currentBracketType: Driver<CBBracketTypeItemButton.BracketType>
        let canCreate: Driver<Bool>
        let canShuffle: Driver<Bool>
        let elements: Driver<[CBTableElement]>
    }
    
    func configure(input: Input) -> Output {
        let name = input.didChangeName.asDriver(onErrorDriveWith: .never())
        let numberTeams = input.didChangeNumberTeams.asDriver(onErrorDriveWith: .never())
        let currentPreset = makeCurrentPreset(
            initialPreset: initialPreset,
            didSelectPreset: input.didSelectPreset
        )
        let currentBracketType = makeCurrentBracketType(
            preset: currentPreset,
            didSelectBracketType: input.didSelectBracketType
        )
        let elements = makeTableElements(
            currentBracketType: currentBracketType,
            numberTeams: numberTeams,
            didSelectTeam: input.didSelectTeam,
            didTapShuffle: input.didTapShuffle
        )
        
        return Output(
            preset: currentPreset,
            action: makeAction(
                didTapSelectPreset: input.didTapSelectPreset,
                currentPreset: currentPreset,
                didTapInfo: input.didTapInfo,
                didTapTeamPosition: input.didTapTeamPosition,
                didTapCreate: input.didTapCreate,
                name: name,
                currentBracketType: currentBracketType,
                elements: elements
            ),
            currentBracketType: currentBracketType,
            canCreate: makeCanCreate(
                name: name,
                elements: elements
            ),
            canShuffle: makeCanShuffle(
                currentBracketType: currentBracketType,
                numberTeams: numberTeams
            ),
            elements: elements
        )
    }
}

// MARK: Private
private extension CreateBracketViewModel {
    func makeCurrentPreset(
        initialPreset: Driver<TournamentPreset?>,
        didSelectPreset: Signal<TournamentPreset>
    ) -> Driver<TournamentPreset> {
        Driver
            .merge(
                initialPreset.map { $0 ?? .none },
                didSelectPreset.asDriver(onErrorDriveWith: .never())
            )
    }
    
    func makeCurrentBracketType(
        preset: Driver<TournamentPreset>,
        didSelectBracketType: Signal<CBBracketTypeItemButton.BracketType>
    ) -> Driver<CBBracketTypeItemButton.BracketType> {
        let initial = preset
            .compactMap { PresetConfig().config[$0]?.0 }
            .asDriver(onErrorDriveWith: .never())
        
        let updated = didSelectBracketType
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(initial, updated)
    }
    
    func makeAction(
        didTapSelectPreset: Signal<Void>,
        currentPreset: Driver<TournamentPreset>,
        didTapInfo: Signal<Void>,
        didTapTeamPosition: Signal<TeamPosition>,
        didTapCreate: Signal<Void>,
        name: Driver<String>,
        currentBracketType: Driver<CBBracketTypeItemButton.BracketType>,
        elements: Driver<[CBTableElement]>
    ) -> Driver<Action> {
        let selectPreset = didTapSelectPreset
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(currentPreset)
            .map { Action.selectPreset($0) }
        
        let openInfo = didTapInfo
            .map { Action.openInfo }
            .asDriver(onErrorDriveWith: .never())
        
        let selectTeam = didTapTeamPosition
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(elements) { ($0, $1) }
            .compactMap { [weak self] teamPosition, elements -> Action? in
                guard let self else { return nil }
                
                switch teamPosition.content {
                case .none, .team:
                    let teamsIds = collectTeamsIds(elements: elements)
                    return Action.selectTeam((teamPosition, teamsIds))
                case .bye:
                    return nil
                }
            }
        
        let create = didTapCreate
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(name)
            .withLatestFrom(currentBracketType) { ($0, $1) }
            .withLatestFrom(elements) { ($0.0, $0.1, $1) }
            .flatMapLatest { [weak self] name, bracketType, elements -> Driver<Action> in
                guard let self else { return .never() }
                
                if SessionManager().hasActiveSubscriptions() {
                    return self.create(
                        name: name,
                        bracketType: bracketType,
                        elements: elements
                    )
                }
                
                return tournamentManager
                    .tournamentsTotalCount()
                    .asDriver(onErrorJustReturn: 0)
                    .flatMap { tournamentsTotalCount -> Driver<Action> in
                        tournamentsTotalCount > 0 ? .just(.openPaygate) : self.create(
                            name: name,
                            bracketType: bracketType,
                            elements: elements
                        )
                    }
            }
        
        return Driver
            .merge(selectPreset, openInfo, selectTeam, create)
    }
    
    func makeCanCreate(
        name: Driver<String>,
        elements: Driver<[CBTableElement]>
    ) -> Driver<Bool> {
        Driver
            .combineLatest(name, elements)
            .map { name, elements -> Bool in
                guard name.count > 3 else { return false }
                
                let allPositions: [TeamPosition] = elements.flatMap { element in
                    switch element {
                    case .oneRowTeam(let pos):
                        return [pos]
                    case .vsRow(let left, let right):
                        return [left, right]
                    }
                }
                
                return allPositions.allSatisfy { pos in
                    switch pos.content {
                    case .team, .bye:
                        return true
                    case .none:
                        return false
                    }
                }
            }
            .distinctUntilChanged()
    }
    
    func makeCanShuffle(
        currentBracketType: Driver<CBBracketTypeItemButton.BracketType>,
        numberTeams: Driver<Int>
    ) -> Driver<Bool> {
        Driver
            .combineLatest(currentBracketType, numberTeams)
            .map { bracketType, numberTeams -> Bool in
                switch bracketType {
                case .roundRobin:
                    return false
                case .singleElimination, .doubleElimination:
                    return numberTeams >= 3
                }
            }
    }
    
    func makeTableElements(
        currentBracketType: Driver<CBBracketTypeItemButton.BracketType>,
        numberTeams: Driver<Int>,
        didSelectTeam: Signal<(Team, TeamPosition)>,
        didTapShuffle: Signal<Void>
    ) -> Driver<[CBTableElement]> {
        currentBracketType
            .flatMapLatest { [weak self] bracketType -> Driver<[CBTableElement]> in
                guard let self else { return .never() }
                
                switch bracketType {
                case .singleElimination:
                    return makeElementsForEliminations(
                        numberTeams: numberTeams,
                        didSelectTeam: didSelectTeam,
                        didTapShuffle: didTapShuffle
                    )
                case .doubleElimination:
                    return makeElementsForEliminations(
                        numberTeams: numberTeams,
                        didSelectTeam: didSelectTeam,
                        didTapShuffle: didTapShuffle
                    )
                case .roundRobin:
                    return makeElementsForRoundRobin(
                        numberTeams: numberTeams,
                        didSelectTeam: didSelectTeam
                    )
                }
            }
    }
    
    func makeElementsForEliminations(
        numberTeams: Driver<Int>,
        didSelectTeam: Signal<(Team, TeamPosition)>,
        didTapShuffle: Signal<Void>
    ) -> Driver<[CBTableElement]> {
        enum Action {
            case changeNumberTeams(Int)
            case selectedTeam(Team, TeamPosition)
            case shuffle
        }
        
        let action = Driver
            .merge(
                numberTeams
                    .map { Action.changeNumberTeams($0) },
                didSelectTeam
                    .map { Action.selectedTeam($0, $1) }
                    .asDriver(onErrorDriveWith: .never()),
                didTapShuffle
                    .map { Action.shuffle}
                    .asDriver(onErrorDriveWith: .never())
            )
        
        typealias VS = (TeamPosition, TeamPosition)
        
        return action
            .scan([]) { vs, action -> [VS] in
                switch action {
                case .changeNumberTeams(let numberTeams):
                    let oldPositions = vs.flatMap { [$0.0, $0.1] }
                    
                    var newPositions: [TeamPosition] = []
                    
                    for i in 0..<numberTeams {
                        if i < oldPositions.count, case .team = oldPositions[i].content {
                            newPositions.append(oldPositions[i])
                        } else {
                            newPositions.append(
                                TeamPosition(
                                    id: UUID().uuidString,
                                    content: .none(i + 1)
                                )
                            )
                        }
                    }
                    
                    if numberTeams % 2 != 0 {
                        newPositions.append(
                            TeamPosition(
                                id: UUID().uuidString,
                                content: .bye
                            )
                        )
                    }
                    
                    var result: [VS] = []
                    for i in stride(from: 0, to: newPositions.count, by: 2) {
                        let first = newPositions[i]
                        let second = newPositions[i + 1]
                        result.append((first, second))
                    }
                    
                    return result
                case .selectedTeam(let team, let teamPosition):
                    var result = vs
                    
                    if let index = result.firstIndex(where: { ($0.id == teamPosition.id) || ($1.id == teamPosition.id) }) {
                        let updatedTeamPosition = TeamPosition(
                            id: teamPosition.id,
                            content: .team(team)
                        )
                        
                        let vsRow = result[index]
                        let updatedVS: VS? = {
                            if vsRow.0.id == teamPosition.id {
                                return (updatedTeamPosition, vsRow.1)
                            } else if vsRow.1.id == teamPosition.id {
                                return (vsRow.0, updatedTeamPosition)
                            } else {
                                return nil
                            }
                        }()
                        
                        if let updatedVS {
                            result[index] = updatedVS
                        }
                    }
                    
                    return result
                case .shuffle:
                    var teamPositions = vs.flatMap { [$0.0, $0.1] }
                    
                    let byes = teamPositions.filter { teamPosition -> Bool in
                        switch teamPosition.content {
                        case .bye:
                            return true
                        case .team, .none:
                            return false
                        }
                    }
                    teamPositions.removeAll { teamPosition -> Bool in
                        switch teamPosition.content {
                        case .bye:
                            return true
                        case .team, .none:
                            return false
                        }
                    }
                    
                    teamPositions.shuffle()
                    
                    if let bye = byes.first {
                        teamPositions.append(bye)
                    }
                    
                    var result: [VS] = []
                    for i in stride(from: 0, to: teamPositions.count, by: 2) {
                        let first = teamPositions[i]
                        let second = teamPositions[i + 1]
                        result.append((first, second))
                    }
                    
                    return result
                }
            }
            .map { $0.map { .vsRow($0, $1) } }
    }
    
    func makeElementsForRoundRobin(
        numberTeams: Driver<Int>,
        didSelectTeam: Signal<(Team, TeamPosition)>
    ) -> Driver<[CBTableElement]> {
        enum Action {
            case changeNumberTeams(Int)
            case selectedTeam(Team, TeamPosition)
        }
        
        let action = Driver
            .merge(
                numberTeams
                    .map { Action.changeNumberTeams($0) },
                didSelectTeam
                    .map { Action.selectedTeam($0, $1) }
                    .asDriver(onErrorDriveWith: .never())
            )
        
        return action
            .scan([]) { teamPositions, action -> [TeamPosition] in
                switch action {
                case .changeNumberTeams(let numberTeams):
                    var result = teamPositions
                    
                    if result.count == numberTeams {
                        return result
                    } else if result.count > numberTeams {
                        return Array(result.prefix(numberTeams))
                    } else {
                        let initialCount = result.count
                        
                        let diff = numberTeams - initialCount
    
                        (0...(diff - 1)).forEach { index in
                            let teamPosition = TeamPosition(
                                id: UUID().uuidString,
                                content: .none(initialCount + (index + 1))
                            )
                            result.append(teamPosition)
                        }
                    }
                    
                    return result
                case .selectedTeam(let team, let teamPosition):
                    var result = teamPositions
                    
                    if let index = result.firstIndex(where: { $0.id == teamPosition.id }) {
                        let updated = TeamPosition(
                            id: teamPosition.id,
                            content: .team(team)
                        )
                        result[index] = updated
                    }
                    
                    return result
                }
            }
            .map { $0.map { .oneRowTeam($0) } }
    }
}

// MARK: Additional
private extension CreateBracketViewModel {
    func create(
        name: String,
        bracketType: CBBracketTypeItemButton.BracketType,
        elements: [CBTableElement]
    ) -> Driver<Action> {
        switch bracketType {
        case .singleElimination:
            let teams = collectTeamsForSE(from: elements)
            let pairs = buildSingleEliminationPairs(from: elements)
            
            return tournamentManager
                .createSingleElimination(name: name, teamsIds: teams)
                .asDriver(onErrorDriveWith: .never())
                .flatMap { [weak self] singleElimination -> Driver<Action> in
                    guard let self else { return .never() }
                    
                    return tournamentManager.createGames(array: pairs)
                        .flatMap { games in
                            self.tournamentManager.createSingleEliminationTournamentRound(
                                singleEliminationId: singleElimination.id,
                                gamesIds: games.map { $0.id },
                                round: 1
                            )
                        }
                        .map { _ in Action.close }
                        .asDriver(onErrorDriveWith: .never())
                }
        case .doubleElimination:
            return .never() // TODO: impl
        case .roundRobin:
            let teams = collectTeamsForRR(from: elements)
            let pairs = buildRoundRobinPairs(from: teams)
            
            return tournamentManager
                .createRoundRobin(name: name, teamsIds: teams)
                .asDriver(onErrorDriveWith: .never())
                .flatMap { [weak self] roundRobin in
                    guard let self else { return .never() }
                    
                    return tournamentManager.createGames(array: pairs)
                        .flatMap { games in
                            self.tournamentManager.createRoundRobinGames(
                                roundRobinId: roundRobin.id,
                                gamesIds: games.map { $0.id }
                            )
                        }
                        .map { _ in Action.close }
                        .asDriver(onErrorDriveWith: .never())
                }
        }
    }
    
    func collectTeamsForSE(from elements: [CBTableElement]) -> [String] {
        var ids: [String] = []
        for element in elements {
            if case let .vsRow(l, r) = element {
                if let team1Id = l.teamId { ids.append(team1Id) }
                if let team1Id = r.teamId { ids.append(team1Id) }
            }
        }
        return uniqueOrdered(ids)
    }
    
    func buildSingleEliminationPairs(from elements: [CBTableElement]) -> [(team1Id: String, team2Id: String, sort: Int)] {
        var pairs: [(String, String, Int)] = []
        for (idx, element) in elements.enumerated() {
            if case let .vsRow(team1, team2) = element, let team1Id = team1.teamId, let team2Id = team2.teamId {
                pairs.append((team1Id, team2Id, idx))
            }
        }
        return pairs
    }
    
    func collectTeamsForRR(from elements: [CBTableElement]) -> [String] {
        var ids: [String] = []
        for element in elements {
            if case let .oneRowTeam(tp) = element, let id = tp.teamId {
                ids.append(id)
            }
        }
        return uniqueOrdered(ids)
    }
    
    func buildRoundRobinPairs(from teamIds: [String]) -> [(team1Id: String, team2Id: String, sort: Int)] {
        guard teamIds.count >= 2 else { return [] }
        
        var ids: [String?] = teamIds
        if ids.count % 2 == 1 { ids.append(nil) }
        
        let n = ids.count
        let rounds = n - 1
        var out: [(String, String)] = []
        
        for _ in 0..<rounds {
            for i in 0..<(n / 2) {
                if let a = ids[i], let b = ids[n - 1 - i] {
                    out.append((a, b))
                }
            }
            
            let fixed = ids[0]
            var rest = Array(ids.dropFirst())
            if let last = rest.popLast() {
                rest.insert(last, at: 0)
            }
            ids = [fixed] + rest
        }
        
        return out.enumerated().map { (i, p) in (team1Id: p.0, team2Id: p.1, sort: i) }
    }
    
    func uniqueOrdered(_ ids: [String]) -> [String] {
        var seen = Set<String>()
        var out: [String] = []
        for id in ids where !seen.contains(id) {
            seen.insert(id)
            out.append(id)
        }
        return out
    }
    
    func collectTeamsIds(elements: [CBTableElement]) -> [String] {
        var ids: [String] = []
        for e in elements {
            switch e {
            case .oneRowTeam(let tp):
                if let id = tp.teamId { ids.append(id) }
            case .vsRow(let l, let r):
                if let id = l.teamId { ids.append(id) }
                if let id = r.teamId { ids.append(id) }
            }
        }
        return uniqueOrdered(ids)
    }
}

// MARK: Additional
private extension TeamPosition {
    var teamId: String? {
        switch content {
        case .team(let team):
            return team.id
        case .none, .bye:
            return nil
        }
    }
}
