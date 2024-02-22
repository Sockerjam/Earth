//
//  Model.swift
//  Earth
//
//  Created by Niclas Jeppsson on 31/01/2024.
//

import MetalKit

class Model {
    
    var transform: Transform = Transform()
    let mtkMesh: MTKMesh
    var materialProperties: [MaterialProperty] = []
    
    init(fileName: String, device: MTLDevice?) {
        
        guard let device = device else {
            fatalError("Device is nil")
        }
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "obj") else {
            fatalError("Couldnt load url")
        }
        
        let allocator = MTKMeshBufferAllocator(device: device)
        
        let asset = MDLAsset(url: url, vertexDescriptor: .defaultDescriptor, bufferAllocator: allocator)
        
        if let modelMesh = asset.childObjects(of: MDLMesh.self).first as? MDLMesh {
            
            do {
                mtkMesh = try MTKMesh(mesh: modelMesh, device: device)
                loadMaterials(from: modelMesh, device: device)
            } catch {
                fatalError("Couldn't load model mesh data")
            }
        } else {
            
            fatalError("No Mesh Available")
        }
    }
    
    private func loadMaterials(from mesh: MDLMesh, device: MTLDevice) {
        
        guard let submeshes = mesh.submeshes as? [MDLSubmesh] else { return }
        
        for submesh in submeshes {
            guard let material = submesh.material else { return }
            
            var materialProperty = MaterialProperty(baseColorTexture: nil)
            
            guard
                let baseColorProperty = material.property(with: .baseColor),
                baseColorProperty.type == .string,
                let texturePath = baseColorProperty.stringValue,
                let textureURL = URL(string: texturePath)
            else {
                return
            }
            
            let texture = TextureController.texture(fileName: textureURL.absoluteString, device: device)
            
            materialProperty.baseColorTexture = texture
            
            self.materialProperties.append(materialProperty)
            
        }
        
    }
}

extension Model {
    
    func render(matrix: Matrix, params: Params, encoder: MTLRenderCommandEncoder) {
        var matrix = matrix
        
        matrix.modelMatrix = transform.modelMatrix
        matrix.normalMatrix = transform.modelMatrix.upperleft
        
        encoder.setVertexBytes(&matrix, length: MemoryLayout<Matrix>.stride, index: 10)
        
        var params = params
        
        encoder.setFragmentBytes(&params, length: MemoryLayout<Params>.stride, index: ParamsBuffer.index)
        
        for (index, meshBuffer) in mtkMesh.vertexBuffers.enumerated() {
            
            encoder.setVertexBuffer(meshBuffer.buffer, offset: 0, index: index)
        }
        
        for material in materialProperties {
            
            encoder.setFragmentTexture(material.baseColorTexture, index: 0)
        }
        
        for subMesh in mtkMesh.submeshes {
            
            encoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: subMesh.indexCount,
                indexType: subMesh.indexType,
                indexBuffer: subMesh.indexBuffer.buffer,
                indexBufferOffset: subMesh.indexBuffer.offset)
        }
        
    }
    
}
