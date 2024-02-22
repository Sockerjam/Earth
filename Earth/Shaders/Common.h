//
//  Common.h
//  Earth
//
//  Created by Niclas Jeppsson on 01/02/2024.
//

#ifndef Common_h
#define Common_h
#import <simd/simd.h>

typedef struct {
    uint lightCount;
    vector_float3 cameraPosition;
} Params;

typedef enum {
    ParamsBuffer = 2,
    LightBuffer = 1
} BufferIndices;


typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float3x3 normalMatrix;
} Matrix;

typedef enum {
    unused = 0,
    Sun = 1,
    Spot = 2,
    Point = 3,
    Ambient = 4
} LightType;

typedef struct {
    LightType type;
    vector_float3 position;
    vector_float3 color;
    vector_float3 specularColor;
    float radius;
    vector_float3 attenuation;
    float coneAngle;
    vector_float3 coneDirection;
    float coneAttenuation;
} Light;

#endif /* Common_h */

