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
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    
} Matrix;

#endif /* Common_h */

