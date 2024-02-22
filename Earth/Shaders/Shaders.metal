//
//  Shaders.metal
//  Earth
//
//  Created by Niclas Jeppsson on 01/02/2024.
//

#include <metal_stdlib>
#include "Common.h"
#include "Lighting.h"

using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float2 uv [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 uv;
    float3 worldPosition;
    float3 worldNormal;
};

vertex VertexOut vertex_main(const VertexIn in [[stage_in]], constant Matrix &matrix [[buffer(10)]])
{
    float4 position = matrix.projectionMatrix * matrix.viewMatrix * matrix.modelMatrix * in.position;
    VertexOut out {
        .position = position,
        .uv = float2(1 - in.uv.x, in.uv.y),
        .worldPosition = (matrix.modelMatrix * in.position).xyz,
        .worldNormal = matrix.normalMatrix * in.normal
    };
    return out;
}

fragment float4 fragment_main(const VertexOut in [[stage_in]], 
                              texture2d<float> baseColorTexture [[texture(0)]],
                              constant Params &params [[buffer(ParamsBuffer)]],
                              constant Light *lights [[buffer(LightBuffer)]])
{
        
    constexpr sampler textureSampler(filter::linear,
                                     address::repeat,
                                     mip_filter::linear,
                                     max_anisotropy(8));
    
    float3 baseColor = baseColorTexture.sample(textureSampler, in.uv).rgb * 2;
    
    float3 normal = normalize(in.worldNormal);
    
    float3 color = phongLighting(normal, in.worldPosition, params, lights, baseColor);
    
    return float4(color, 1);
}
