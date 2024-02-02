//
//  Shaders.metal
//  Earth
//
//  Created by Niclas Jeppsson on 01/02/2024.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float2 uv [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 normal;
    float2 uv;
};

vertex VertexOut vertex_main(const VertexIn in [[stage_in]], constant Matrix &matrix [[buffer(10)]])
{
    float4 position = matrix.projectionMatrix * matrix.viewMatrix * matrix.modelMatrix * in.position;
    VertexOut out {
        .position = position,
        .normal = in.normal,
        .uv = float2(1 - in.uv.x, in.uv.y)
    };
    return out;
}

fragment float4 fragment_main(const VertexOut in [[stage_in]], texture2d<float> baseColorTexture [[texture(0)]])
{
    constexpr sampler textureSampler;
    float3 baseColor = baseColorTexture.sample(textureSampler, in.uv).rgb;
    return float4(baseColor, 1);
}
