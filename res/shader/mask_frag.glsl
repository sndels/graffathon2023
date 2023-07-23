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
    p *= 10;
    float r = .5;

    float d = INF;

    // Gridlines
    // if (fract(p.x) < .02 || fract(1. - p.x) < .02)
    //     color = vec3(.8);
    // if (fract(p.y) < .02 || fract(1. - p.y) < .02)
    //     color = vec3(.8);


    // d = fOpUnion(d, dCircle(p, 1.));
    // d = fOpUnion(d, dCircle(p - vec2(.0, -1.), 1.));
    // d = fOpDifference(d, dCircle(p - vec2(.0, -.5 ), 1.));
    // d = fOpUnion(d, dLine(p - vec2(.0, -5), .01));
    // d = fOpIntersection(d, dCircle(p - vec2(.0, -.5 ), 2.));

    // vec2 pp = p;
    // pR(pp, PI / 4);
    // d = fOpUnion(d, dLine(pp - vec2(.0, -.35), .01));

    // d = fOpIntersection(d, dCircle(p - vec2(0, -.5 ), 3.));

    // d = fOpUnion(d, dRect(p - vec2(.3, -.1), vec2(.05)));

    // d = fOpUnion(d, dHalfSpace(p.y, -2.5));

    // d = dCharE(p);

    float cursor = -7;
    vec2 pp = p;
    // d = fOpUnion(d, dCharD(pp - vec2(cursor, 0), cursor));
    // d = fOpUnion(d, dCharE(pp - vec2(cursor, 0), cursor));
    // d = fOpUnion(d, dCharL(pp - vec2(cursor, 0), cursor));
    // d = fOpUnion(d, dCharI(pp - vec2(cursor, 0), cursor));
    // d = fOpUnion(d, dCharB(pp - vec2(cursor, 0), cursor));
    // d = fOpUnion(d, dCharE(pp - vec2(cursor, 0), cursor));
    // d = fOpUnion(d, dCharR(pp - vec2(cursor, 0), cursor));
    // d = fOpUnion(d, dCharA(pp - vec2(cursor, 0), cursor));
    // d = fOpUnion(d, dCharT(pp - vec2(cursor, 0), cursor));
    // d = fOpUnion(d, dCharE(pp - vec2(cursor, 0), cursor));

    pp = p - vec2(0, 5);
    cursor = -10;
    d = fOpUnion(d, dCharA(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharB(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharC(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharD(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharE(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharF(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharG(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharH(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharI(pp - vec2(cursor, 0), cursor));
    cursor -= 0.7; // TODO: J is context sensitive
    d = fOpUnion(d, dCharJ(pp - vec2(cursor, 0), cursor));
    pp = p - vec2(0, 0);
    cursor = -10;
    d = fOpUnion(d, dCharK(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharL(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharM(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharN(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharO(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharP(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharQ(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharR(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharS(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharT(pp - vec2(cursor, 0), cursor));
    pp = p - vec2(0, -5);
    cursor = -10;
    d = fOpUnion(d, dCharU(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharV(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharW(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharX(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharY(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharZ(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharExclamation(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharColon(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharDash(pp - vec2(cursor, 0), cursor));
    d = fOpUnion(d, dCharUnderscore(pp - vec2(cursor, 0), cursor));


    // color = vec3(saturate(1. - max(abs(d), 0.01)* 20.));
    color += vec3(saturate(1. - (d * 20.)));

    fragColor = vec4(color , 1.);
}
