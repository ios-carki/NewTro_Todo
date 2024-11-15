//
//  Importance.swift
//  NewTro_Todo
//
//  Created by OWEN on 11/14/24.
//

import SwiftUI

final class Info {
    enum Importance {
        case low
        case medium
        case high
        
        var id: Int {
            switch self {
            case .low:
                return 0
            case .medium:
                return 1
            case .high:
                return 2
            }
        }
        
        var text: String {
            switch self.id {
            case 0:
                return "detail_importance_low".localized()
            case 1:
                return "detail_importance_medium".localized()
            case 2:
                return "detail_importance_high".localized()
            default:
                return "Unknown"
            }
        }
        
        init?(id: Int) {
            switch id {
            case 0: self = .low
            case 1: self = .medium
            case 2: self = .high
            default: return nil
            }
        }
    }
    
    enum Favorite {
        case yes
        case no
        
        var text: String {
            switch self {
            case .yes:
                return "detail_favorite_true".localized()
            case .no:
                return "detail_favorite_false".localized()
            }
        }
        
        init(value: Bool) {
            switch value {
            case true: self = .yes
            case false: self = .no
            }
        }
    }
    
    enum Completed {
        case yes
        case no
        
        var text: String {
            switch self {
            case .yes:
                return "detail_completed_true".localized()
            case .no:
                return "detail_completed_false".localized()
            }
        }
        
        var color: Color {
            switch self {
            case .yes:
                return NewtroColor.success
            case .no:
                return NewtroColor.fail
            }
        }
        
        init(value: Bool) {
            switch value {
            case true: self = .yes
            case false: self = .no
            }
        }
    }
}
