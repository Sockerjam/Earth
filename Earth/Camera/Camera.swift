//
//  Camera.swift
//  Earth
//
//  Created by Niclas Jeppsson on 04/02/2024.
//

import MetalKit

protocol Camera: Transformable {
    
    var projectionMatrix: float4x4 { get }
    var viewMatrix: float4x4 { get }
    
    func update(size: CGSize)
    func update(time: Float)
}
