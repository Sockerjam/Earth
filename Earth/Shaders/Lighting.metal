//
//  Lighting.metal
//  Earth
//
//  Created by Niclas Jeppsson on 21/02/2024.
//

#include <metal_stdlib>
#include "Lighting.h"

using namespace metal;

float3 phongLighting(float3 normal, float3 position, constant Params &params, constant Light *lights, float3 baseColor)
{
    
    float materialShininess = 10;
    float3 materialSpecularColor = float3(1);
    
    float3 diffuseColor = 0;
    float3 ambientColor = 0;
    float3 specularColor = 0;
    
    for (uint i = 0; i < params.lightCount; i++) {
        Light light = lights[i];
        
        switch (light.type)
        {
            case Sun: {
                float3 ligthDirection = normalize(-light.position);
                float diffuse = saturate(-dot(ligthDirection, normal));
                diffuseColor = light.color * baseColor * diffuse;
                
                float3 reflection = reflect(ligthDirection, normal);
                
                float3 viewDirection = normalize(params.cameraPosition);
                
                float specularIntensity = pow(saturate(dot(reflection, viewDirection)), materialShininess);
                
                specularColor += light.specularColor * materialSpecularColor * specularIntensity;
                
                break;
            }
            case Point: {
                break;
            }
            case Spot: {
                break;
            }
            case Ambient: {
                ambientColor += light.color;
                break;
            }
            case unused: {
                break;
            }
        }
    }
    
    return diffuseColor + ambientColor;
}


