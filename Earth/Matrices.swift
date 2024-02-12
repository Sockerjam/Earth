//
//  Matrices.swift
//  Earth
//
//  Created by Niclas Jeppsson on 01/02/2024.
//

import MetalKit

extension Float {
    
    var degreesToRadians: Float {
        self * Float.pi / 180
    }
}

extension float4x4 {
    
    // Translation and View
    init(translation: SIMD3<Float>) {
        var matrix = matrix_identity_float4x4
        matrix.columns.3.x = translation.x
        matrix.columns.3.y = translation.y
        matrix.columns.3.z = translation.z
        
        self = matrix
    }
    
    // Scale
    init(scale: SIMD3<Float>) {
        var matrix = matrix_identity_float4x4
        matrix.columns.0.x = scale.x
        matrix.columns.1.y = scale.y
        matrix.columns.2.z = scale.z
        
        self = matrix
    }
    
    // Rotation
    init(angle: SIMD3<Float>) {
        let matrixX = float4x4(angleX: angle.x)
        let matrixY = float4x4(angleY: angle.y)
        let matrixZ = float4x4(angleZ: angle.z)
        let matrix = matrixX * matrixY * matrixZ
        self = matrix
    }
    
    // Rotation
    init(angleY: Float) {
        let matrix = float4x4(
            [cos(angleY), 0, -sin(angleY), 0],
            [0,          1,     0,       0],
            [sin(angleY), 0, cos(angleY),  0],
            [0,          0,      0,      1]
        )
        
        self = matrix
    }
    
    // Rotation
    init(angleX: Float) {
        let matrix = float4x4(
            [1, 0,        0,               0],
            [0, cos(angleX), -sin(angleX), 0],
            [0, sin(angleX), cos(angleX),  0],
            [0,          0,      0,      1]
        )
        self = matrix
    }
    
    // Rotation
    init(angleZ: Float) {
        let matrix = float4x4(
            [cos(angleZ), -sin(angleZ), 0, 0],
            [sin(angleZ), cos(angleZ), 0,  0],
            [0,             0,         1,  0],
            [0,             0,         0,   1]
        )
        
        self = matrix
    }
    
    // MARK: - Left handed projection matrix
    init(projectionFov fov: Float, near: Float, far: Float, aspect: Float, lhs: Bool = true) {
        let y = 1 / tan(fov * 0.5)
        let x = y / aspect
        let z = lhs ? far / (far - near) : far / (near - far)
        let X = SIMD4<Float>( x,  0,  0,  0)
        let Y = SIMD4<Float>( 0,  y,  0,  0)
        let Z = lhs ? SIMD4<Float>( 0,  0,  z, 1) : SIMD4<Float>( 0,  0,  z, -1)
        let W = lhs ? SIMD4<Float>( 0,  0,  z * -near,  0) : SIMD4<Float>( 0,  0,  z * near,  0)
        self.init()
        columns = (X, Y, Z, W)
    }
}
