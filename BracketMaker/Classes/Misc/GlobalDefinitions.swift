//
//  GlobalDefinitions.swift
//  Soccer
//
//  Created by Andrey Chernyshev on 16.01.2021.
//

import Foundation

final class GlobalDefinitions {
    static let otterScaleHost = "https://api.korrekted.com"
    static let otterScaleApiKey = "pmboxHN6XAoXEsbT"
    
    static let termsOfServiceUrl = URL(string: "https://maria-apps.com/terms")!
    static let privacyPolicyUrl = URL(string: "https://maria-apps.com/policy")!
    static let contactUsUrl = URL(string: "https://maria-apps.com/contact")!
    
    enum Paygate {
        static let yearly = "bracketmaker.yearly"
        static let weekly = "bracketmaker.weekly"
    }
}
