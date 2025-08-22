//
//  OnboardingView.swift
//  Soccer
//
//  Created by Андрей Чернышев on 23.08.2022.
//

import UIKit

final class OnboardingView: GradientView {
    enum Slide: Hashable {
        case welcome
        case instructionTournament
        case instructionTeams
        case instructionOrganized
        case role
    }
    
    private lazy var slidesViews: [Slide: OSlideView] = [
        .welcome: OWelcomeView { [weak self] in
            self?.scroll(from: .welcome, to: .instructionTournament)
        },
        .instructionTournament: OInstructionView(instruction: .tournament) { [weak self] in
            self?.scroll(from: .instructionTournament, to: .instructionTeams)
        },
        .instructionTeams: OInstructionView(instruction: .teams) { [weak self] in
            self?.scroll(from: .instructionTeams, to: .instructionOrganized)
        },
        .instructionOrganized: OInstructionView(instruction: .organized) { [weak self] in
            self?.scroll(from: .instructionOrganized, to: .role)
        },
        .role: ORoleView { [weak self] in
            self?.finish()
        }
    ]
    
    private let finish: () -> Void
    
    init(finish: @escaping () -> Void) {
        self.finish = finish
        
        super.init(frame: .zero)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        slidesViews.map { $1 }.forEach { slideView in
            slideView.frame.size = bounds.size
        }
    }
}

// MARK: Private
private extension OnboardingView {
    func initialize() {
        gradientLayer.colors = Appearance.mono900.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        if let view = slidesViews[.welcome] {
            view.frame.origin = CGPoint.zero
            addSubview(view)
            
            view.moveToThis()
        }
    }
    
    func scroll(from: Slide, to: Slide) {
        guard let currentView = slidesViews[from], let scrollToView = slidesViews[to] else { return }
        
        scrollToView.frame.origin = CGPoint(x: bounds.size.width, y: 0)
        
        addSubview(scrollToView)
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self else { return }
            
            currentView.frame.origin = CGPoint(x: -bounds.size.width, y: 0)
            scrollToView.frame.origin = CGPoint(x: 0, y: 0)
        }, completion: { result in
            scrollToView.moveToThis()
            currentView.removeFromSuperview()
        })
    }
}
