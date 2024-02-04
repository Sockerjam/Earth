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
    
    var lastTime: Double = CFAbsoluteTimeGetCurrent()
    var angle: Float = 4
    
    var matrix = Matrix()
    
    lazy var gameScene: GameScene = GameScene()
    
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
        gameScene.update(size: size)
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
        
        matrix.viewMatrix = gameScene.fpCamera.viewMatrix
        matrix.projectionMatrix = gameScene.fpCamera.projectionMatrix
        
        let currentTime = CFAbsoluteTimeGetCurrent()
        let deltaTime = Float(lastTime - currentTime)
        lastTime = currentTime
        
        gameScene.update(time: deltaTime)
        
        gameScene.models.forEach { model in
            
            model.render(matrix: matrix, encoder: encoder)
            
        }
        
        encoder.endEncoding()
        guard let drawable = view.currentDrawable else { return }
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
}
