#version 410

#include "uniforms.glsl"
#include "2d_sdf.glsl"

uniform vec3 dColor;

out vec4 fragColor;

 void main()
 {
    // Avoid nags if these aren't used
    if (uTime < -1. || uRes.x < -1.)
        discard;

    vec2 uv = gl_FragCoord.xy / uRes.xy;
    vec3 color = vec3(0);
    float ar = float(uRes.x) / uRes.y;

    vec2 p = (uv * 2. - 1.);
    p.x *= ar;
    p *= 3;
    float r = 0.5;

    float d = INF;

    d = fOpUnion(d, dCircle(p, 1.));
    d = fOpUnion(d, dCircle(p - vec2(0, -1), 1.));
    d = fOpDifference(d, dCircle(p - vec2(0,-0.5 ), 1.));
    d = fOpUnion(d, dLine(p - vec2(0, -0.5), 0.01));
    d = fOpIntersection(d, dCircle(p - vec2(0,-0.5 ), 2.));

    vec2 pp = p;
    pR(pp, PI / 4);
    d = fOpUnion(d, dLine(pp - vec2(0, -0.35), 0.01));

    d = fOpIntersection(d, dCircle(p - vec2(0,-0.5 ), 3.));

    d = fOpUnion(d, dRect(p - vec2(0.3, -0.1), vec2(0.05)));

    d = fOpUnion(d, dHalfSpace(p.y, -2.5));


    // color = vec3(saturate(1. - max(abs(d), 0.01)* 20.));
    color = vec3(saturate(1. - (d * 20.)));

    fragColor = vec4(color , 1.);
}
