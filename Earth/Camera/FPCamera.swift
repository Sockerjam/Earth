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
    var rotation: Movement = .rotation(0.005)
    
    private var aspectRatio: Float = 1
    private let fov = Float(70).degreesToRadians
    private let near: Float = 0.01
    private let far: Float = 100
        
    var rotationVector = SIMD3<Float>(0, 0, 0)
    var rotationQuaternion = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    var forwardVector = SIMD4<Float>(0, 0, -1, 1)
    
    var projectionMatrix: float4x4 {
        float4x4(projectionFov: fov, near: near, far: far, aspect: aspectRatio)
    }
    
    var viewMatrix: float4x4 {
        let translation = float4x4(translation: transform.translation).inverse
        let rotation = transform.rotationMatrix
        return rotation * translation
    }
    
    func update(size: CGSize) {
        aspectRatio = Float(size.width) / Float(size.height)
    }
    
    func update(time: Float) {

        let speed = time * translation.speed
        
        if InputController.shared.keysPressed.contains(.keyA) {
            let deltaRotation = simd_quatf(angle: -speed, axis: SIMD3<Float>(0, 1, 0))
            rotationQuaternion = simd_mul(deltaRotation, rotationQuaternion)
        }
        
        if InputController.shared.keysPressed.contains(.keyD) {
            let deltaRotation = simd_quatf(angle: speed, axis: SIMD3<Float>(0, 1, 0))
            rotationQuaternion = simd_mul(deltaRotation, rotationQuaternion)
        }
        
        transform.rotationMatrix = quaternionToMatrix(q: rotationQuaternion)
        
        let forwardVector = transform.rotationMatrix * forwardVector
        
        if InputController.shared.keysPressed.contains(.keyW) {
            transform.translation += SIMD3<Float>(-forwardVector.x, forwardVector.y, forwardVector.z) * speed
        }
        
        if InputController.shared.keysPressed.contains(.keyS) {

            transform.translation -= SIMD3<Float>(-forwardVector.x, forwardVector.y, forwardVector.z) * speed
        }
    }
    
    func createQuternion() -> float4x4 {
        
        let x = simd_quatf(angle: rotationVector.x, axis: SIMD3<Float>(1, 0, 0))
        let y = simd_quatf(angle: rotationVector.y, axis: SIMD3<Float>(0, 1, 0))
        let z = simd_quatf(angle: rotationVector.z, axis: SIMD3<Float>(0, 0, 1))
        
        let q = z * y * x
        
       return quaternionToMatrix(q: q)
    }
    
    func quaternionToMatrix(q: simd_quatf) -> simd_float4x4 {
        let x = q.vector.x
        let y = q.vector.y
        let z = q.vector.z
        let w = q.vector.w
        
        let matrix = simd_float4x4(rows: [
            SIMD4(1 - 2*y*y - 2*z*z,     2*x*y - 2*w*z,     2*x*z + 2*w*y, 0),
            SIMD4(    2*x*y + 2*w*z, 1 - 2*x*x - 2*z*z,     2*y*z - 2*w*x, 0),
            SIMD4(    2*x*z - 2*w*y,     2*y*z + 2*w*x, 1 - 2*x*x - 2*y*y, 0),
            SIMD4(                0,                 0,                 0, 1)
        ])
        
        return matrix
    }
    
}
