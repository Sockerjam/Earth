//
//  TextureLoader.swift
//  Earth
//
//  Created by Niclas Jeppsson on 31/01/2024.
//

import MetalKit

enum TextureController {
    
    // This will store the textures loaded by our model
    static var texture: [String: MTLTexture] = [:]
    
    static func loadTexture(fileName: String) -> MTLTexture? {
        
        let textureLoader = MTKTextureLoader(device: Renderer.device)
        let textureOptions: [MTKTextureLoader.Option: Any] = [
            .origin: MTKTextureLoader.Origin.bottomLeft,
            .SRGB: false
        ]
        
        // Get file extension
        let fileExtension = URL(fileURLWithPath: fileName).pathExtension.isEmpty ? "jpeg" : nil
        
        
        // Get full url to file
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("URL Failed")
            return nil
        }
        
        guard let texture = try? textureLoader.newTexture(URL: url, options: textureOptions) else {
            print("Texture Failed")
            return nil
        }
        
        print("Texture found: ", texture.label ?? "")
        
        return texture
    }
    
    static func texture(fileName: String) -> MTLTexture? {
        
        // Checks if texture is already stored
        if let fileName = texture[fileName] {
            return fileName
        }
        
        // Loads texture
        guard let loadedTexture = loadTexture(fileName: fileName) else { return nil }
        
        // Saves it to dictionary to be returned if it's already saved
        texture[fileName] = loadedTexture
        
        return loadedTexture
    }
}
