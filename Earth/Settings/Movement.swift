//
//  Movement.swift
//  Earth
//
//  Created by Niclas Jeppsson on 04/02/2024.
//

import Foundation

enum Movement {
    case translation(Float)
    case rotation(Float)
    case mousePan(Float)
    
    var speed: Float {
        switch self {
        case .translation(let speed):
            return speed
        case .rotation(let speed):
            return speed
        case .mousePan(let sensitivity):
            return sensitivity
        }
    }
}



