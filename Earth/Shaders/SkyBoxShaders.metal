//
//  SkyBoxShaders.metal
//  Earth
//
//  Created by Niclas Jeppsson on 21/02/2024.
//

#include <metal_stdlib>
using namespace metal;

struct SkyVertexIn {
    float4 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float2 uv [[attribute(2)]];
};

struct SkyVertexOut {
    float4 position [[position]];
    float2 uv;
};

vertex SkyVertexOut skybox_vertex(const SkyVertexIn in [[stage_in]], constant float4x4 &matrix [[buffer(11)]], constant float4x4 &projection [[buffer(12)]])
{
    float4 position = projection * matrix * in.position;
    
    SkyVertexOut out {
        .position = position,
        .uv = in.uv
    };
    
    return out;
}

fragment float4 skybox_fragment(const SkyVertexOut in [[stage_in]], texture2d<float> baseColorTexture [[texture(10)]])
{
    constexpr sampler textureSampler(filter::linear,
                                     mip_filter::linear);
    
    float3 baseColor = baseColorTexture.sample(textureSampler, in.uv).rgb * 2;
    
    return float4(baseColor, 1);
}
