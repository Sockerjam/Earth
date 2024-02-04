//
//  GameScene.swift
//  Earth
//
//  Created by Niclas Jeppsson on 04/02/2024.
//

import MetalKit

class GameScene {
    
    lazy var earthModel: Model = {
        Model(fileName: "earth", device: Renderer.device)
    }()
    
    lazy var models: [Model] = [earthModel]
    
    var fpCamera: Camera = FPCamera()
    
    let angle = Float(1).degreesToRadians
    var deltaTime: Float = 0.0
    
    init() {
        fpCamera.transform.translation = float4x4(translation: [0, 0, -2])
    }
    
    func update(time: Float) {
        deltaTime += time
        let rotationMatrix = float4x4(angle: angle * deltaTime)
        let rotationMatrixX = float4x4(angleX: angle * deltaTime)
        
        earthModel.transform.rotation = rotationMatrixX * rotationMatrix
        earthModel.transform.translation = matrix_identity_float4x4
        
        fpCamera.update(time: time)

    }
    
    func update(size: CGSize) {
        fpCamera.update(size: size)
    }
}
