//
//  BracketInfoViewController.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 08.09.2025.
//

import UIKit

final class BracketInfoViewController: UIViewController {
    private lazy var mainView = BracketInfoView()
    
    override func loadView() {
        view = mainView
    }
}

// MARK: Public
extension BracketInfoViewController {
    static func make() -> BracketInfoViewController {
        let vc = BracketInfoViewController()
        vc.navigationItem.backButtonTitle = " "
        vc.navigationItem.title = "BracketInfo.Title".localized
        return vc
    }
}
