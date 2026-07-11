// Shaders.metal
// Scribe — Metal shaders for canvas background rendering

#include <metal_stdlib>
using namespace metal;

// MARK: - Vertex Shader

struct VertexIn {
    float2 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut vertexShader(
    const VertexIn in [[stage_in]],
    constant float4x4 &mvp [[buffer(1)]]
) {
    VertexOut out;
    out.position = mvp * float4(in.position, 0.0, 1.0);
    out.texCoord = in.texCoord;
    return out;
}

// MARK: - Grid Pattern Fragment Shader

fragment float4 gridFragmentShader(
    VertexOut in [[stage_in]],
    constant float4 &lineColor [[buffer(0)]],
    constant float4 &bgColor [[buffer(1)]],
    constant float2 &gridSpacing [[buffer(2)]],
    constant float &lineWidth [[buffer(3)]]
) {
    float2 pos = in.texCoord;
    
    // Grid lines
    float2 grid = fmod(pos, gridSpacing);
    float2 halfLine = float2(lineWidth * 0.5);
    
    bool onHLine = grid.y < halfLine.y || grid.y > (gridSpacing.y - halfLine.y);
    bool onVLine = grid.x < halfLine.x || grid.x > (gridSpacing.x - halfLine.x);
    
    if (onHLine || onVLine) {
        return lineColor;
    }
    
    return bgColor;
}

// MARK: - Dot Grid Pattern Fragment Shader

fragment float4 dotGridFragmentShader(
    VertexOut in [[stage_in]],
    constant float4 &dotColor [[buffer(0)]],
    constant float4 &bgColor [[buffer(1)]],
    constant float2 &gridSpacing [[buffer(2)]],
    constant float &dotRadius [[buffer(3)]]
) {
    float2 pos = in.texCoord;
    
    // Find nearest grid intersection
    float2 nearest = round(pos / gridSpacing) * gridSpacing;
    float dist = distance(pos, nearest);
    
    if (dist < dotRadius) {
        float alpha = smoothstep(dotRadius, dotRadius * 0.5, dist);
        return mix(bgColor, dotColor, alpha);
    }
    
    return bgColor;
}

// MARK: - Lined Pattern Fragment Shader

fragment float4 linedFragmentShader(
    VertexOut in [[stage_in]],
    constant float4 &lineColor [[buffer(0)]],
    constant float4 &bgColor [[buffer(1)]],
    constant float &lineSpacing [[buffer(2)]],
    constant float &lineWidth [[buffer(3)]]
) {
    float y = in.texCoord.y;
    float halfLine = lineWidth * 0.5;
    
    float gridY = fmod(y, lineSpacing);
    
    if (gridY < halfLine || gridY > (lineSpacing - halfLine)) {
        return lineColor;
    }
    
    return bgColor;
}
