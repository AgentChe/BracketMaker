//
//  SingleEliminationPDFGenerator.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 21.09.2025.
//

import UIKit
import PDFKit

final class SingleEliminationPDFGenerator {
    struct Input {
        let title: String
        let subtitle: String
        let teams: [Team]
        let games: [SingleEliminationGame]
        let gameResults: [SingleEliminationGameResult]
        let tournamentResult: SingleEliminationResult?
        /// Внешние отступы полотна PDF
        var pageInsets: UIEdgeInsets = UIEdgeInsets(top: 48, left: 32, bottom: 48, right: 32)
        /// Межколоночные отступы как на экране
        var interRoundSpacing: CGFloat = 24
        var dividerWidth: CGFloat = 1
        /// Ширина зоны "Winner" справа от последнего столбца
        var winnerGap: CGFloat = 24
        var winnerLabelGap: CGFloat = 16
    }

    // MARK: Public

    func makePDF(_ input: Input) -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).pdf")
        try? makePDFData(input).write(to: url, options: .atomic)
        return url
    }
    
    func makePDFData(_ input: Input) -> Data {
        // 1) Подготовим раунды и победителя по той же логике, что в экране
        let rounds = Self.buildRounds(from: input.games, teams: input.teams, results: input.gameResults)
        let winnerTeam: SETeamView.Team? = input.tournamentResult.map { tournamentResult -> SETeamView.Team in
            SETeamView.Team(
                teamId: tournamentResult.winner,
                teamName: input.teams.first(where: { $0.id == tournamentResult.winner })?.name ?? tournamentResult.winner,
                isWinner: true,
                isBye: false
            )
        }

        // 2) Посчитаем габариты бранкета
        let gw = SERoundGamesView.Constants.gameWidth
        let gh = SERoundGamesView.Constants.gameHeight
        let inset = SERoundGamesView.Constants.inset
        let teamH: CGFloat = 56
        let scoreW: CGFloat = 28
        let cornerR: CGFloat = 19

        let roundHeights = rounds.map { CGFloat($0.games.count) * gh + CGFloat(max(0, $0.games.count - 1)) * inset }
        let bracketHeight = roundHeights.max() ?? 0

        var bracketWidth: CGFloat = 0
        for i in 0..<rounds.count {
            bracketWidth += gw + input.interRoundSpacing + input.dividerWidth
            if i != rounds.count - 1 { bracketWidth += input.interRoundSpacing }
        }
        var winnerPillWidth: CGFloat = 0
        if winnerTeam != nil {
            // как на экране: ширина "таблетки" сопоставима ширине игры, оставим под PDF фикс
            winnerPillWidth = gw
            bracketWidth += input.winnerGap + winnerPillWidth
        }

        // 3) Посчитаем общий размер страницы
        // Добавим место под шапку
        let titleH: CGFloat = 36
        let subtitleH: CGFloat = 22
        let headerGap: CGFloat = 8
        let headerBlockH = titleH + headerGap + subtitleH + 24

        let contentSize = CGSize(
            width: input.pageInsets.left + bracketWidth + input.pageInsets.right,
            height: input.pageInsets.top + headerBlockH + bracketHeight + input.pageInsets.bottom
        )

        // 4) Рендер в PDF
        let fmt = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: contentSize), format: fmt)
        let pdfData = renderer.pdfData { ctx in
            ctx.beginPage()

            let cg = ctx.cgContext

            // фон
            UIColor(integralRed: 215, green: 222, blue: 231).setFill()
            cg.fill(CGRect(origin: .zero, size: contentSize))

            // шапка
            let titleStyle = Self.centerStyle(font: .systemFont(ofSize: 28, weight: .semibold), color: Appearance.mono100)
            let subtitleStyle = Self.centerStyle(font: .systemFont(ofSize: 16, weight: .regular), color: Appearance.mono100.withAlphaComponent(0.7))

            let titleRect = CGRect(x: 0, y: input.pageInsets.top, width: contentSize.width, height: titleH)
            (input.title as NSString).draw(in: titleRect, withAttributes: titleStyle)

            let subtitleRect = CGRect(x: 0, y: titleRect.maxY + headerGap, width: contentSize.width, height: subtitleH)
            (input.subtitle as NSString).draw(in: subtitleRect, withAttributes: subtitleStyle)

            // область бранкета
            var x = input.pageInsets.left
            let topY = subtitleRect.maxY + 24

            for (rIndex, round) in rounds.enumerated() {
                // сам столбец игр
                let startY = topY + (bracketHeight - roundHeights[rIndex]) / 2.0

                for (gIndex, game) in round.games.enumerated() {
                    let gameTop = startY + CGFloat(gIndex) * (gh + inset)

                    // team1 pill
                    let t1Rect = CGRect(x: x, y: gameTop, width: gw, height: teamH)
                    Self.drawTeamPill(in: t1Rect,
                                      team: game.team1,
                                      scoreWidth: scoreW,
                                      corner: cornerR)

                    // team2 pill
                    let t2Rect = CGRect(x: x, y: gameTop + gh - teamH, width: gw, height: teamH)
                    Self.drawTeamPill(in: t2Rect,
                                      team: game.team2,
                                      scoreWidth: scoreW,
                                      corner: cornerR)
                }

                // divider
                let divX = x + gw + input.interRoundSpacing
                Appearance.main100.withAlphaComponent(0.5).setFill()
                cg.fill(CGRect(x: divX, y: startY, width: input.dividerWidth, height: roundHeights[rIndex]))

                // перейти к следующему столбцу
                x = divX + input.dividerWidth + input.interRoundSpacing
            }

            // Winner зона
            if let winner = winnerTeam {
                x += input.winnerGap

                // таблетка победителя
                let winnerRect = CGRect(x: x, y: topY + (bracketHeight - teamH) / 2.0, width: winnerPillWidth, height: teamH)
                Self.drawTeamPill(in: winnerRect, team: winner, scoreWidth: scoreW, corner: cornerR)

                // синяя полоска и подпись Winner
                let lineX = winnerRect.maxX + input.winnerLabelGap
                Appearance.main300.setFill()
                cg.fill(CGRect(x: lineX, y: winnerRect.minY + 8, width: 2, height: teamH - 16))

                let winnerAttrs = Self.leftStyle(font: .systemFont(ofSize: 18, weight: .regular), color: Appearance.mono100)
                let wText = "Winner" as NSString
                let wRect = CGRect(x: lineX + 8, y: winnerRect.minY, width: 200, height: teamH)
                wText.draw(in: wRect, withAttributes: winnerAttrs)
            }
        }

        return pdfData
    }

    // MARK: - Helpers (layout + draw)

    private static func centerStyle(font: UIFont, color: UIColor) -> [NSAttributedString.Key: Any] {
        let p = NSMutableParagraphStyle()
        p.alignment = .center
        p.minimumLineHeight = font.lineHeight
        p.maximumLineHeight = font.lineHeight
        return [.font: font, .foregroundColor: color, .paragraphStyle: p]
    }

    private static func leftStyle(font: UIFont, color: UIColor) -> [NSAttributedString.Key: Any] {
        let p = NSMutableParagraphStyle()
        p.alignment = .left
        p.minimumLineHeight = font.lineHeight
        p.maximumLineHeight = font.lineHeight
        return [.font: font, .foregroundColor: color, .paragraphStyle: p]
    }

    private static func teamStyle() -> [NSAttributedString.Key: Any] {
        let f = UIFont.systemFont(ofSize: 16, weight: .regular)
        let p = NSMutableParagraphStyle()
        p.alignment = .center
        p.minimumLineHeight = f.lineHeight
        p.maximumLineHeight = f.lineHeight
        return [.font: f, .foregroundColor: Appearance.mono100, .paragraphStyle: p]
    }

    private static func drawTeamPill(
        in rect: CGRect,
        team: SETeamView.Team?,
        scoreWidth: CGFloat,
        corner: CGFloat
    ) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        // Клип по единому скруглению как в UI
        let clip = UIBezierPath(roundedRect: rect, cornerRadius: corner)
        ctx.saveGState()
        clip.addClip()

        // Левая часть (фон команды). Непрозрачная, чтобы не было "просвета".
        Appearance.mono200.setFill()
        UIBezierPath(rect: rect).fill()

        // Полоса score справа. Без отдельного скругления. Клип задаёт нужные углы.
        let stripeRect = CGRect(x: rect.maxX - scoreWidth, y: rect.minY, width: scoreWidth, height: rect.height)
        let isWinner = team?.isWinner ?? false
        (isWinner ? Appearance.main200 : Appearance.main600).setFill()
        UIBezierPath(rect: stripeRect).fill()

        ctx.restoreGState()

        let name: String = {
            guard let t = team else { return "" }
            return t.isBye ? "bye" : t.teamName
        }()

        let font = UIFont.systemFont(ofSize: 16, weight: .regular)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineBreakMode = .byTruncatingTail

        let textColor: UIColor = {
            if team?.isWinner == false { return Appearance.mono100.withAlphaComponent(0.5) }
            return Appearance.mono100
        }()

        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraph
        ]

        let textRect = rect.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 41))
        let drawRect = CGRect(
            x: textRect.minX,
            y: textRect.midY - font.lineHeight / 2,
            width: textRect.width,
            height: font.lineHeight
        )
        (name as NSString).draw(with: drawRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attrs, context: nil)
    }

    // MARK: - Mapping (как в SingleEliminationViewModel)

    private static func buildRounds(
        from games: [SingleEliminationGame],
        teams: [Team],
        results: [SingleEliminationGameResult]
    ) -> [SERoundGamesView.Round] {
        guard !games.isEmpty else { return [] }

        let resByGame = Dictionary(uniqueKeysWithValues: results.map { ($0.gameId, $0) })
        let grouped = Dictionary(grouping: games, by: { $0.round })
        let orderedRoundKeys = grouped.keys.sorted()

        return orderedRoundKeys.map { roundKey in
            let roundGames = (grouped[roundKey] ?? []).sorted { $0.sort < $1.sort }
            return SERoundGamesView.Round(
                games: roundGames.map { mapGame($0, teams: teams, result: resByGame[$0.id]) },
                round: roundKey
            )
        }
    }

    private static func mapGame(
        _ game: SingleEliminationGame,
        teams: [Team],
        result: SingleEliminationGameResult?
    ) -> SEGameView.Game {
        SEGameView.Game(
            gameId: game.id,
            team1: mapTeam(game.team1, teams: teams, result: result),
            team2: mapTeam(game.team2, teams: teams, result: result)
        )
    }

    private static func mapTeam(
        _ team: SingleEliminationGame.Team,
        teams: [Team],
        result: SingleEliminationGameResult?
    ) -> SETeamView.Team? {
        switch team {
        case .team(let teamId):
            let name = teams.first(where: { $0.id == teamId })?.name ?? teamId
            let isWinner: Bool? = {
                guard let r = result else { return nil }
                if r.winnerTeamId == teamId { return true }
                if r.loserTeamId == teamId { return false }
                return nil
            }()
            return SETeamView.Team(teamId: teamId, teamName: name, isWinner: isWinner, isBye: false)
        case .bye:
            return SETeamView.Team(teamId: "bye", teamName: "bye", isWinner: nil, isBye: true)
        case .scheduled:
            return nil
        }
    }
}
