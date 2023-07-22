#version 410

#include "uniforms.glsl"
#include "noise.glsl"

uniform vec3 dColor;
uniform float dMix;
uniform float uMultiplier;

uniform sampler2D uScenePingColorDepth;
uniform sampler2D uScenePongColorDepth;
uniform sampler2D uPrevAux;

layout(location = 0) out vec4 fragColor;
layout(location = 1) out vec4 aux;

#define ABERR_SAMPLES 16 

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

uniform float dCaberr;

void main()
{
    // Avoid nags if these aren't used
    if (uTime < -1 || uRes.x < -1)
        discard;

    vec4 ping = sampleSource(uScenePingColorDepth, dCaberr);
    vec4 pong = sampleSource(uScenePongColorDepth, dCaberr);

    vec3 color = vec3(0);
    color.rgb = ping.rgb * pong.rgb + (1-ping.rgb) * (1-pong.rgb);

    vec2 texCoord = gl_FragCoord.xy / uRes;
    fragColor = vec4(color, 1);
    fragColor = 0.05*vec4(color, 1) + 0.95*texture(uPrevAux, texCoord);
    aux = (1.0-dMix)*vec4(color, 1) + dMix*texture(uPrevAux, texCoord);
}
