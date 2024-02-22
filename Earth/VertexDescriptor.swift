//
//  VertexDescriptor.swift
//  Earth
//
//  Created by Niclas Jeppsson on 31/01/2024.
//

import MetalKit

extension MDLVertexDescriptor {
    
    static var defaultDescriptor: MDLVertexDescriptor {
        
        let descriptor = MDLVertexDescriptor()
        
        var offset = 0
                
        descriptor.attributes[0] = MDLVertexAttribute(
            name: MDLVertexAttributePosition,
            format: .float3,
            offset: 0,
            bufferIndex: 0)
        
        offset += MemoryLayout<SIMD3<Float>>.stride
        
        descriptor.attributes[1] = MDLVertexAttribute(
            name: MDLVertexAttributeNormal,
            format: .float3,
            offset: offset,
            bufferIndex: 0)
        
        offset += MemoryLayout<SIMD3<Float>>.stride
        
        descriptor.attributes[2] = MDLVertexAttribute(
            name: MDLVertexAttributeTextureCoordinate,
            format: .float2,
            offset: offset,
            bufferIndex: 0)
        
        offset += MemoryLayout<SIMD2<Float>>.stride

        descriptor.layouts[0] = MDLVertexBufferLayout(stride: offset)
        
        return descriptor
    }
}

extension BufferIndices {
  var index: Int {
    return Int(rawValue)
  }
}
