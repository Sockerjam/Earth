//
//  SceneLighting.swift
//  Earth
//
//  Created by Niclas Jeppsson on 21/02/2024.
//

import MetalKit

struct SceneLighting {
    
    static func defaultLighting() -> Light {
        var light = Light()
        light.position = [0, 0, 0]
        light.color = [1, 1, 1]
        light.specularColor = [0.6, 0.6, 0.6]
        light.attenuation = [1, 0, 0]
        light.type = Sun
        return light
    }
    
    let sunlight: Light = {
        var sunlight = Self.defaultLighting()
        sunlight.position = [-1, 1, 0]
        return sunlight
    }()
    
    let ambientLight: Light = {
        var light = Self.defaultLighting()
        light.color = [0, 0, 0.1] * 0.5
        light.type = Ambient
        return light
    }()
    
    var lights: [Light] = []
    
    init() {
        lights.append(sunlight)
        lights.append(ambientLight)
    }
}
