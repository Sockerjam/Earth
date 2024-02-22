//
//  Renderer.swift
//  2DTextures
//
//  Created by Niclas Jeppsson on 20/01/2024.
//

import MetalKit
import Combine

class Renderer: NSObject {
    
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    
    private var pipelineState: MTLRenderPipelineState?
    private var depthStencilState: MTLDepthStencilState?
    
    var lastTime: Double = CFAbsoluteTimeGetCurrent()
    var angle: Float = 4
    
    var matrix = Matrix()
    var params = Params()
    
    var gameScene: GameScene
    var skyboxRenderer: SkyBoxRenderer
    
    init(device: MTLDevice, metalView: MTKView, gameScene: GameScene, skyboxRenderer: SkyBoxRenderer?) {
        
        guard
            let commandQueue = device.makeCommandQueue(),
            let skyboxRenderer = skyboxRenderer
        else {
            fatalError("Failed to setup commandQueue")
        }
        
        self.device = device
        self.commandQueue = commandQueue
        
        self.gameScene = gameScene
        self.skyboxRenderer = skyboxRenderer
        
        super.init()
        metalView.delegate = self
        setupPipelineState(view: metalView)
        buildDepthStencilState()
        mtkView(metalView, drawableSizeWillChange: metalView.drawableSize)
    }
    
    func buildDepthStencilState() {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: descriptor)
    }
        
    private func setupPipelineState(view: MTKView) {
        
        guard let library = device.makeDefaultLibrary() else {
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
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Couldn't create pipeline state")
        }
    }
}

extension Renderer: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        gameScene.update(size: size)
    }
    
    func draw(in view: MTKView) {
        guard
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let renderPassDescriptor = view.currentRenderPassDescriptor,
            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else {
            return
        }
        
        guard 
            let pipelineState = pipelineState,
            let depthStencilState = depthStencilState
        else { return }
        
        skyboxRenderer.draw(in: view, encoder: encoder)
        
        encoder.setDepthStencilState(depthStencilState)
        encoder.setRenderPipelineState(pipelineState)
        
        matrix.viewMatrix = gameScene.fpCamera.viewMatrix
        matrix.projectionMatrix = gameScene.fpCamera.projectionMatrix
        
        var lighting = gameScene.sceneLighting.lights
        params.lightCount = UInt32(lighting.count)
        
        encoder.setFragmentBytes(&lighting, length: MemoryLayout<Light>.stride * lighting.count, index: LightBuffer.index)
        
        params.cameraPosition = gameScene.fpCamera.transform.translation
        
        let currentTime = CFAbsoluteTimeGetCurrent()
        let deltaTime = Float(lastTime - currentTime)
        lastTime = currentTime
        
        gameScene.update(time: deltaTime)
        
        gameScene.models.forEach { model in
            
            model.render(matrix: matrix, params: params, encoder: encoder)
            
        }
        
        encoder.endEncoding()
        guard let drawable = view.currentDrawable else { return }
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
}
