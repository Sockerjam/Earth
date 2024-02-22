//
//  MetalView.swift
//  QuadMetalTest
//
//  Created by Niclas Jeppsson on 21/11/2023.
//

import SwiftUI
import MetalKit

struct MetalView: View {
    
    @State private var skyboxRenderer: SkyBoxRenderer?
    @State private var renderer: Renderer?
    @State private var metalView = MTKView()
    
    static var mainDevice: MTLDevice?
    
    var body: some View {
        VStack {
            MetalViewRepresentable(skyboxRenderer: skyboxRenderer, renderer: renderer, metalView: $metalView)
            .onAppear {
                guard let device = MTLCreateSystemDefaultDevice() else {
                    fatalError("Failed to create device")
                }
                MetalView.mainDevice = device
                metalView.device = MetalView.mainDevice
                metalView.depthStencilPixelFormat = .depth32Float
                let gameScene = GameScene()
                skyboxRenderer = SkyBoxRenderer(device: MetalView.mainDevice, metalView: metalView, gameScene: gameScene)
                renderer = Renderer(device: device, metalView: metalView, gameScene: gameScene, skyboxRenderer: skyboxRenderer)
            }
        }
    }
}

#if os(macOS)
typealias ViewRepresentable = NSViewRepresentable
typealias MyMetalView = NSView
#elseif os(iOS)
typealias ViewRepresentable = UIViewRepresentable
typealias MyMetalView = UIView
#endif

struct MetalViewRepresentable: ViewRepresentable {
    let skyboxRenderer: SkyBoxRenderer?
    let renderer: Renderer?
    @Binding var metalView: MTKView
    
#if os(macOS)
    func makeNSView(context: Context) -> some NSView {
        metalView
    }
    func updateNSView(_ uiView: NSViewType, context: Context) {
        updateMetalView()
    }
#elseif os(iOS)
    func makeUIView(context: Context) -> MTKView {
        metalView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        updateMetalView()
    }
#endif
    
    func makeMetalView(_ metalView: MyMetalView) {
    }
    
    func updateMetalView() {
    }
}
