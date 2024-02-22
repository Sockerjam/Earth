//
//  SkyBoxRenderer.swift
//  Earth
//
//  Created by Niclas Jeppsson on 21/02/2024.
//

import MetalKit

class SkyBoxRenderer: NSObject {
    
    private var device: MTLDevice
    private var commandQueue: MTLCommandQueue
    private var pipelineState: MTLRenderPipelineState?
    private var depthStencilState: MTLDepthStencilState?
    
    let gameScene: GameScene
    
    init(device: MTLDevice?, metalView: MTKView, gameScene: GameScene) {
        
        guard
            let device = device,
            let commandQueue = device.makeCommandQueue()
        else {
            fatalError("Failed to setup commandQueue")
        }
        
        self.device = device
        self.commandQueue = commandQueue
        
        self.gameScene = gameScene
        
        super.init()
        buildDepthStencilState()
        setupPipelineState(view: metalView)
    }
    
    func buildDepthStencilState() {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = false
        self.depthStencilState = device.makeDepthStencilState(descriptor: descriptor)
    }
        
    private func setupPipelineState(view: MTKView) {
        
        guard let library = device.makeDefaultLibrary() else {
            fatalError("Couldn't create library")
        }
        
        let vertexFunction = library.makeFunction(name: "skybox_vertex")
        let fragmentFunction = library.makeFunction(name: "skybox_fragment")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(.defaultDescriptor)
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Couldn't create pipeline state")
        }
    }
    
}

extension SkyBoxRenderer {
    
    func draw(in view: MTKView, encoder: MTLRenderCommandEncoder) {
        guard
            let pipelineState = pipelineState,
            let depthStencilState = depthStencilState
        else { return }
        
        encoder.setRenderPipelineState(pipelineState)
        encoder.setDepthStencilState(depthStencilState)
        
        var rotationMatrix = gameScene.fpCamera.transform.rotationMatrix * 0.5
        var projectionMatrix = gameScene.fpCamera.projectionMatrix
        
        
        encoder.setVertexBytes(&rotationMatrix, length: MemoryLayout<float4x4>.size, index: 11)
        
        encoder.setVertexBytes(&projectionMatrix, length: MemoryLayout<float4x4>.size, index: 12)
        
        for (index, meshBuffer) in gameScene.skybox.mtkMesh.vertexBuffers.enumerated() {
            
            encoder.setVertexBuffer(meshBuffer.buffer, offset: 0, index: index)
        }
        
        for material in gameScene.skybox.materialProperties {
            
            encoder.setFragmentTexture(material.baseColorTexture, index: 10)
        }

        for submesh in gameScene.skybox.mtkMesh.submeshes {
            encoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: submesh.indexCount,
                indexType: submesh.indexType,
                indexBuffer: submesh.indexBuffer.buffer,
                indexBufferOffset: submesh.indexBuffer.offset)
        }
    }
}
