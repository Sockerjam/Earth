//
//  Transform.swift
//  Earth
//
//  Created by Niclas Jeppsson on 02/02/2024.
//

import MetalKit

struct Transform {
    
    var translation: float4x4 = float4x4(translation: [0, 0, 0])
    var rotation: float4x4 = float4x4(angle: 0)
    var scale: float4x4 = float4x4(scale: [1, 1, 1])
}

protocol Transformable {
    
    var transform: Transform { get set }
}

extension Transformable {
    
}
