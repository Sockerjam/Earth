//
//  Transform.swift
//  Earth
//
//  Created by Niclas Jeppsson on 02/02/2024.
//

import MetalKit

struct Transform {
    
    var translation: SIMD3<Float> = [0, 0, 0]
    var rotation: SIMD3<Float> = [0, 0, 0]
    var scale: SIMD3<Float> = [1, 1, 1]
    var rotationMatrix: float4x4 = matrix_identity_float4x4
}

extension Transform {
    
    var modelMatrix: float4x4 {
        let translation = float4x4(translation: translation)
        let rotation = float4x4(angle: rotation)
        let scale = float4x4(scale: scale)
        return translation * rotation * scale
    }
}

protocol Transformable {
    
    var transform: Transform { get set }
}
