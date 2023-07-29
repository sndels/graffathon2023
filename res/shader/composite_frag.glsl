#version 410

#include "uniforms.glsl"
#include "noise.glsl"

uniform vec3 dColor;
uniform float dMix;
uniform float dPrev;
uniform float uMultiplier;

uniform sampler2D uScenePingColorDepth;
uniform sampler2D uScenePongColorDepth;
uniform sampler2D uPrevPing;
uniform sampler2D uPrevPong;
uniform sampler2D uFlow;
uniform sampler2D uColorFeedback;

layout(location = 0) out vec4 fragColor;
layout(location = 1) out vec4 prevPing;
layout(location = 2) out vec4 prevPong;
layout(location = 3) out vec4 flow;
layout(location = 4) out vec4 colorFeedback;

#define ABERR_SAMPLES 16

uniform float dCaberr = .0;
vec4 sampleSource(sampler2D s, float aberr)
{
    vec2 texCoord = gl_FragCoord.xy / uRes;
    vec4 value = texture(s, texCoord);
    if (aberr > 0) {
        vec2 dir = 0.5 - texCoord;
        vec2 caOffset = dir * aberr * 0.1;
        vec2 blurStep = caOffset * 0.06;

        vec3 sum = vec3(0);
        // TODO: This is expensive
        for (int i = 0; i < ABERR_SAMPLES; i++) {
            sum += vec3(texture(s, texCoord + caOffset + i * blurStep).r,
                        texture(s, texCoord + i * blurStep).g,
                        texture(s, texCoord - caOffset + i * blurStep).b);
        }

        value.rgb = sum / ABERR_SAMPLES;
    }
    return value;
}

vec2 pixelSize = 1.0 / uRes;
vec2 texCoord = gl_FragCoord.xy / uRes;

float vectorWeight(vec2 v1, vec2 v2)
{
    float v1l = length(v1);
    float v2l = length(v2);
    if (v1l < 0.00001 || v2l < 0.00001)
        return 0.00001;

    float l = min(v1l / v2l, v2l / v1l);

    return l*0.5*(dot(normalize(v1), normalize(v2))+1.0);
}

// f: initial flow value
// t: color to measure distance to
// sampler: sampler to use
vec2 resampleFlowPing(vec2 f, vec3 t, int nSamples)
{
    float sampleDistance = length(f)+4.0*min(pixelSize.x, pixelSize.y);//50.0*min(pixelSize.x, pixelSize.y);
    float weightSum = 0.0;
    vec2 ff = vec2(0.0, 0.0);
    for (int i=0; i<nSamples; ++i) {
        vec2 fs = f + sampleDistance*2.0*(rnd2d01()-0.5);
        vec3 sRgb = texture(uPrevPing, texCoord+fs).rgb;
        vec2 sFlow = texture(uFlow, texCoord+fs).xy;

        float weight = (/*vectorWeight(f, sFlow)+*/1.0) / (length(t-sRgb) + 0.00001);
        weightSum += weight;
        ff += fs*weight;
    }
    ff /= weightSum;
    return ff;
}

// f: initial flow value
// t: color to measure distance to
// sampler: sampler to use
vec2 resampleFlowPong(vec2 f, vec3 t, int nSamples)
{
    float sampleDistance = length(f)+4.0*min(pixelSize.x, pixelSize.y);//50.0*min(pixelSize.x, pixelSize.y);
    float weightSum = 0.0;
    vec2 ff = vec2(0.0, 0.0);
    for (int i=0; i<nSamples; ++i) {
        vec2 fs = f + sampleDistance*2.0*(rnd2d01()-0.5);
        vec3 sRgb = texture(uPrevPong, texCoord+fs).rgb;
        vec2 sFlow = texture(uFlow, texCoord+fs).wz;

        float weight = (/*vectorWeight(f, sFlow)+*/1.0) / (length(t-sRgb) + 0.001);
        weightSum += weight;
        ff += fs*weight;
    }
    ff /= weightSum;
    return ff;
}

void main()
{
    // Avoid nags if these aren't used
    if (uTime < -1 || uRes.x < -1 ||
        texture(uFlow, vec2(0,0)).r < -1 ||
        texture(uPrevPing, vec2(0,0)).r < -1 ||
        texture(uPrevPong, vec2(0,0)).r < -1
    )
        discard;

    if (dCaberr > .1)
    {
        fragColor = sampleSource(uScenePingColorDepth, dCaberr - .1);
        return;
    }

    // init noise
    pcg_state = uvec3(gl_FragCoord.xy, uTime*120);

    vec4 ping = texture(uScenePingColorDepth, texCoord);
    vec4 pong = texture(uScenePongColorDepth, texCoord);
    vec4 pingPrev = texture(uPrevPing, texCoord);
    vec4 pongPrev = texture(uPrevPong, texCoord);
    vec4 flowPrev = 0.4*texture(uFlow, texCoord) +
        0.15*texture(uFlow, texCoord+vec2(pixelSize.x, 0.0)) +
        0.15*texture(uFlow, texCoord+vec2(0.0, pixelSize.y)) +
        0.15*texture(uFlow, texCoord+vec2(-pixelSize.x, 0.0)) +
        0.15*texture(uFlow, texCoord+vec2(0.0, -pixelSize.y));

    // mix factors
    float mixPing = pow(clamp(1.0-dMix*2.0, 0.0, 1.0), 4.0);
    float mixPong = pow(clamp(dMix*2.0-1.0, 0.0, 1.0), 4.0);
    float mixFeedback = 1.0-mixPing-mixPong;
    float mixFlow = clamp(dMix*2.0-0.5, 0.0, 1.0);

    // sample
    float flowDamping = 0.99;
    flow.xy = resampleFlowPing(flowPrev.xy, ping.rgb, 100)*flowDamping;
    flow.zw = resampleFlowPong(flowPrev.zw, pong.rgb, 100)*flowDamping;
//    flow.zw = resampleFlowPong(flowPrev.zw, pongPrev.rgb, uScenePongColorDepth, 20);

    vec2 f = mix(flow.xy, flow.zw, mixFlow);

    vec3 color = vec3(0);
//    color.rgb = mix(ping.rgb, pong.rgb, dMix);
//    vec3 prev = mix(texture(uPrevPing, texCoord).rgb, texture(uPrevPong, texCoord).rgb, dMix);
//    color.rgb = prev.rgb;
//    color.rgb -= dPrev*prev;
    //color.rgb = 0.33*color.rgb + 0.33*texture(uPrevPing, texCoord).rgb + 0.33*texture(uPrevPong, texCoord).rgb;

    prevPing = ping;
    prevPong = pong;
    //flow.xy = vec2(0.0, 0.0);//mix(f, flowPrev.xy, 0.95)*0.999;
    color.rgb = texture(uColorFeedback, texCoord).rgb;
    colorFeedback = mixPing*ping + mixPong*pong + mixFeedback*texture(uColorFeedback, texCoord-f);

    fragColor = vec4(color, 1);
//    fragColor = vec4(f.xy*1.0f+0.5, 0.5, 1);
//    fragColor = vec4(flow.zw*1.0f+0.5, 0.5, 1);
    //fragColor = 0.05*vec4(color, 1) + 0.95*texture(uPrevAux, texCoord);


    //aux = (1.0-dMix)*vec4(color, 1) + dMix*texture(uPrevAux, texCoord);
}
