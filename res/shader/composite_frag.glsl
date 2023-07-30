#version 410

#include "uniforms.glsl"
#include "noise.glsl"

uniform vec3 dColor;
uniform float rMix;
uniform float rFlowFeedback;
uniform float rFlow;
uniform float rSaturate;
uniform float rBlack;

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
#define PI 3.1415926535

uniform float rTextMode = 0.0;

uniform float rCaberr = 0.01;
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

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// f: initial flow value
// t: color to measure distance to
// sampler: sampler to use
vec2 resampleFlowPing(vec2 f, vec3 t, int nSamples)
{
    float sampleDistance = 0.1f;
    float weightSum = 0.0;
    vec2 ff = vec2(0.0, 0.0);
    for (int i=0; i<nSamples; ++i) {
        vec2 samplePos = texCoord+sampleDistance*2.0*(rnd2d01()-0.5);
        samplePos = clamp(samplePos, 0.0, 1.0);
        vec3 sRgb = texture(uPrevPing, samplePos).rgb;
        vec2 sFlow = texture(uFlow, samplePos).xy;
        vec2 fs = samplePos-texCoord;

        float weight = (vectorWeight(fs, sFlow)*exp(-4.0*pow(length(fs)/sampleDistance, 2.0))) /
            (length(t-sRgb) + 0.0001);
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
    float sampleDistance = 0.1f;
    float weightSum = 0.0;
    vec2 ff = vec2(0.0, 0.0);
    for (int i=0; i<nSamples; ++i) {
        vec2 samplePos = texCoord+sampleDistance*2.0*(rnd2d01()-0.5);
        samplePos = clamp(samplePos, 0.0, 1.0);
        vec3 sRgb = texture(uPrevPong, samplePos).rgb;
        vec2 sFlow = texture(uFlow, samplePos).wz;
        vec2 fs = samplePos-texCoord;

        float weight = (vectorWeight(fs, sFlow)*exp(-4.0*pow(length(fs)/sampleDistance, 2.0))) /
            (length(t-sRgb) + 0.0001);
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

    // init noise
    pcg_state = uvec3(gl_FragCoord.xy+uvec2(10, 0), uTime*120);

    vec4 ping = vec4(0);
    vec4 pong = vec4(0);
    if (rCaberr > .01)
    {
        ping = sampleSource(uScenePingColorDepth, rCaberr);
        pong = sampleSource(uScenePongColorDepth, rCaberr);
    }
    else {
        ping = texture(uScenePingColorDepth, texCoord);
        pong = texture(uScenePongColorDepth, texCoord);
    }

    if (rTextMode > .5)
    {
        // Assume pong is the text shader that marks 'transparency' as 0 alpha
        fragColor = (1.0-rBlack)*vec4(pong.a > 0 ? pong.rgb : ping.rgb, 1);
        return;
    }

    vec4 pingPrev = texture(uPrevPing, texCoord);
    vec4 pongPrev = texture(uPrevPong, texCoord);
    vec4 flowPrev = 0.2*texture(uFlow, texCoord) +
        0.15*texture(uFlow, texCoord+vec2(pixelSize.x, 0.0)) +
        0.15*texture(uFlow, texCoord+vec2(0.0, pixelSize.y)) +
        0.15*texture(uFlow, texCoord+vec2(-pixelSize.x, 0.0)) +
        0.15*texture(uFlow, texCoord+vec2(0.0, -pixelSize.y)) +
        0.05*texture(uFlow, texCoord+vec2(pixelSize.x, pixelSize.y)) +
        0.05*texture(uFlow, texCoord+vec2(pixelSize.x, -pixelSize.y)) +
        0.05*texture(uFlow, texCoord+vec2(-pixelSize.x, pixelSize.y)) +
        0.05*texture(uFlow, texCoord+vec2(-pixelSize.x, -pixelSize.y));

    // mix factors
    float mixPing = pow(clamp(1.0-rMix*1.8, 0.0, 1.0), 3.0);
    float mixPong = pow(clamp(rMix*1.8-0.8, 0.0, 1.0), 3.0);
    float mixFeedback = 1.0-mixPing-mixPong;
    float mixFlow = clamp(rMix*1.5-0.25, 0.0, 1.0);

    // sample
    float flowDamping = 0.999;
    float flowFeedback = sqrt(rFlowFeedback);
    flow.xy = ((1.0-flowFeedback)*resampleFlowPing(flowPrev.xy, ping.rgb, 20) +
        flowFeedback*flowPrev.xy)*flowDamping;
    flow.zw = ((1.0-flowFeedback)*resampleFlowPong(flowPrev.zw, pong.rgb, 20) +
        flowFeedback*flowPrev.zw)*flowDamping;

    vec2 f = mix(flow.xy, flow.zw, mixFlow);
    f = normalize(f) * 0.5*(length(flow.xy) + length(flow.zw));

    prevPing = ping;
    prevPong = pong;

    vec3 color = mixPing*ping.rgb + mixPong*pong.rgb + mixFeedback*
        texture(uColorFeedback, texCoord-f*(0.5+0.5*rnd01())*rFlow).rgb;
    color = rgb2hsv(color);
    color.y = mix(color.y, 1.0, rSaturate);
    color = hsv2rgb(color);
    colorFeedback.rgb = color;
//    color.rgb = texture(uColorFeedback, texCoord).rgb;

    fragColor = vec4(color*(1.0-rBlack), 1);

//    fragColor = fragColor*0.2 + 0.8*vec4(flow.xy*100.0f+0.5, 0.5, 1);
//    fragColor = vec4(f*10.0f+0.5, 0.5, 1);
    //fragColor = 0.05*vec4(color, 1) + 0.95*texture(uPrevAux, texCoord);


    //aux = (1.0-rMix)*vec4(color, 1) + rMix*texture(uPrevAux, texCoord);
}
