//
//  CRRGRTeamsView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 17.09.2025.
//

import UIKit

final class CRRGRTeamsView: UIView {
    lazy var team1View = makeTeamView(alignment: .left)
    lazy var vsLabel = makeVSLabel()
    lazy var team2View = makeTeamView(alignment: .right)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension CRRGRTeamsView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension CRRGRTeamsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            team1View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            team1View.topAnchor.constraint(equalTo: topAnchor),
            team1View.widthAnchor.constraint(equalToConstant: 161.scale),
            team1View.heightAnchor.constraint(equalToConstant: 56.scale)
        ])
        
        NSLayoutConstraint.activate([
            vsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            vsLabel.centerYAnchor.constraint(equalTo: team1View.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            team2View.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            team2View.topAnchor.constraint(equalTo: topAnchor),
            team2View.widthAnchor.constraint(equalToConstant: 161.scale),
            team2View.heightAnchor.constraint(equalToConstant: 56.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension CRRGRTeamsView {
    func makeTeamView(alignment: CRRGRTeamView.Alignment) -> CRRGRTeamView {
        let view = CRRGRTeamView(alignment: alignment)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeVSLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100.withAlphaComponent(0.5))
            .font(Fonts.Inter.semiBold(size: 14.scale))
            .lineHeight(21.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "CreateRRGameResult.VS".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
