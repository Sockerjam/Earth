//
//  Renderer.swift
//  2DTextures
//
//  Created by Niclas Jeppsson on 20/01/2024.
//

import MetalKit
import Combine

class Renderer: NSObject {
    
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    
    private var pipelineState: MTLRenderPipelineState?
    private var depthStencilState: MTLDepthStencilState?
    
    var timer: Float = 0
    var angle: Float = 4
    
    var matrix = Matrix()
    
    lazy private var model: Model = {
        Model(fileName: "earth", device: Renderer.device)
    }()
    
    init(metalView: MTKView) {
        
        guard 
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() 
        else {
            fatalError("Failed to setup device")
        }
        
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        metalView.device = device
        
        super.init()
        metalView.delegate = self
        setupPipelineState(view: metalView)
        buildDepthStencilState()
        metalView.clearColor = MTLClearColor(
            red: 0,
            green: 0,
            blue: 0,
            alpha: 1.0)
        metalView.depthStencilPixelFormat = .depth32Float
        mtkView(metalView, drawableSizeWillChange: metalView.drawableSize)
    }
    
    func buildDepthStencilState() {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        depthStencilState = Renderer.device.makeDepthStencilState(descriptor: descriptor)
    }
        
    private func setupPipelineState(view: MTKView) {
        
        guard let library = Renderer.device.makeDefaultLibrary() else {
            fatalError("Couldn't create library")
        }
        
        let vertexFunction = library.makeFunction(name: "vertex_main")
        let fragmentFunction = library.makeFunction(name: "fragment_main")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(.defaultDescriptor)
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        do {
            pipelineState = try Renderer.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Couldn't create pipeline state")
        }
    }
}

extension Renderer: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
        let aspect = Float(view.bounds.width) / Float(view.bounds.height)
        
        let projectionMatrix = float4x4(
            projectionFov: Float(70).degreesToRadians,
            near: 0.1,
            far: 100,
            aspect: aspect)
        
        matrix.projectionMatrix = projectionMatrix
    }
    
    func draw(in view: MTKView) {
        guard
            let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
            let renderPassDescriptor = view.currentRenderPassDescriptor,
            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else {
            return
        }
        
        guard 
            let pipelineState = pipelineState,
            let depthStencilState = depthStencilState
        else { return }
        
        encoder.setDepthStencilState(depthStencilState)
        encoder.setRenderPipelineState(pipelineState)
        
        timer += 1/60 * 4
        
        let translationMatrix = matrix_identity_float4x4
        let rotationMatrix = float4x4(angle: timer.degreesToRadians)
        let rotationMatrixX = float4x4(angleX: timer.degreesToRadians)
        let viewMatrix = float4x4(translation: [0, 0, 2])
        
        matrix.modelMatrix = rotationMatrixX * rotationMatrix * translationMatrix
        matrix.viewMatrix = viewMatrix
        
        encoder.setVertexBytes(&matrix, length: MemoryLayout<Matrix>.stride, index: 10)
        
        for (index, meshBuffer) in model.mtkMesh.vertexBuffers.enumerated() {
            
            encoder.setVertexBuffer(meshBuffer.buffer, offset: 0, index: index)
        }
        
        for material in model.materialProperties {
            
            encoder.setFragmentTexture(material.baseColorTexture, index: 0)
        }
        
        for subMesh in model.mtkMesh.submeshes {
            
            encoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: subMesh.indexCount,
                indexType: subMesh.indexType,
                indexBuffer: subMesh.indexBuffer.buffer,
                indexBufferOffset: subMesh.indexBuffer.offset)
        }
 
        encoder.endEncoding()
        guard let drawable = view.currentDrawable else { return }
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
}
