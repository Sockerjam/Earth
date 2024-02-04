//
//  FPCamera.swift
//  Earth
//
//  Created by Niclas Jeppsson on 04/02/2024.
//

import MetalKit

class FPCamera: Camera, Transformable {
    
    var transform: Transform = Transform()
    var translation: Movement = .translation(1)
    var rotation: Movement = .rotation(0)
    
    private var aspectRatio: Float = 1
    private let fov = Float(70).degreesToRadians
    private let near: Float = 0.01
    private let far: Float = 100
    
    
    
    var projectionMatrix: float4x4 {
        float4x4(projectionFov: fov, near: near, far: far, aspect: aspectRatio)
    }
    
    var viewMatrix: float4x4 {
        transform.translation.inverse
    }
    
    func update(size: CGSize) {
        aspectRatio = Float(size.width) / Float(size.height)
    }
    
    func update(time: Float) {
        
        let translationSpeed = time * translation.speed
        var directionVector = SIMD3<Float>(0, 0, 0)
        
        if InputController.shared.keysPressed.contains(.keyW) {
            directionVector.z -= 1
        }
        
        if InputController.shared.keysPressed.contains(.keyS) {
            directionVector.z += 1
        }
        
        if InputController.shared.keysPressed.contains(.keyA) {
            directionVector.x += 1
        }
        
        if InputController.shared.keysPressed.contains(.keyD) {
            directionVector.x -= 1
        }
        
        if directionVector != SIMD3<Float>(0, 0, 0) {
            let normalisedVector = simd_normalize(directionVector)
            let translationVector = normalisedVector * translationSpeed
            
            transform.translation.columns.3 += SIMD4<Float>(translationVector, 0)
        }
        
    }
    
}
