#version 410

#include "uniforms.glsl"
#include "hg_sdf.glsl"
#include "noise.glsl"
#include "shading.glsl"
#include "tonemap.glsl"

out vec4 fragColor;

#define INF (1.0/0.0)

#define NUM_SPHERES 32

uniform vec4 sphere_coords[NUM_SPHERES];
uniform vec3 dAlbedo = vec3(0.9, 0.36, 0.);
uniform float dMetallic;
uniform float dRoughness;


vec3 bg(vec3 d) {
    float v = fbm(d * 10 + vec3(uTime, 0, 0), 2, 3);
    return mix(vec3(0), vec3(0.7) * v, -d.y);
}

vec3 xform(vec3 p)
{
    p.x += 2.5;
    float v = -sin(uTime * 3.1415 / 60 * 145) * 1 + 0.5;
    p.z -= uTime * -2.5 - v;
        //pR(p.xz, uTime);
    pModMirror2(p.xz, vec2(5));
    return p;
}

// Returns distance to hit and material index
vec2 scene(vec3 p)
{
    vec2 h = vec2(INF);

    p = xform(p);

    //p.x = mod(p.x, 2);
    {
        vec3 pp = p;
        //pModMirror2(pp.xy, vec2(.4, .4));
        //pR(pp.yz, uTime);
        //float d = fIcosahedron(pp, 0.4, 30.);
        float d = fBox(pp - vec3(0, -0.2, 0), vec3(1.0, 0.2, 1.0));
        d += fbm(pp * 5, 2, 3) * 0.01;
        //d += fbm(pp * 8, 0.2, 12) * 0.1;






        h = d < h.x ? vec2(d, 0) : h;
    }

    {
        vec3 pp = p;
        //pModMirror2(pp.xy, vec2(.4, .4));
        pR(pp.xz, uTime);
        //pR(pp.yz, uTime);
        //float d = fIcosahedron(pp, 0.4, 30.);
        //float d = fBox(pp, vec3(1.0, 0.1, 1.0));
        //d = fOpUnion(d, fSphere(pp, 1.0), 0.1);

#if 1
        float d = 10000;
        for (int i = 0; i < NUM_SPHERES; ++i) {
            vec3 m = vec3(0);
            vec3 ppp = pp;
            ppp.y -= cos(i / 2.0 + uTime) * 2 + 2.0;
            ppp.x -= sin(i + uTime) * 0.6 ;
            ppp.z -= sin(i * 10 + uTime) * 0.6 ;
            /*
            ppp.x -= fbm(vec3(uTime, float(i), 0), 1, 4) * 0.6 - 1;
            ppp.z -= fbm(vec3(0, float(i), uTime), 1, 4) * 0.6 - 1;
            */
            //d = fOpUnionSoft(d, fSphere(ppp, 0.25), 0.4);
            d = fOpUnionSoft(d, fDodecahedron(ppp, 0.25), 0.4);
            //pp.x += 0.2;
            //d = min(d, fSphere(ppp, 1.0));
        }
#endif
        //d += fbm(pp * 8, 0.2, 12) * 0.1;
        h = d < h.x ? vec2(d, 0) : h;
    }

    return h;
}

vec2 scene2(vec3 p)
{
    vec2 h = vec2(INF);



    {
        vec3 pp = p;
        //pModMirror2(pp.xy, vec2(.4, .4));
        pR(pp.xz, uTime);

        //pR(pp.yz, uTime);
        //float d = fIcosahedron(pp, 0.4, 30.);
        //float d = fBox(pp, vec3(1.0, 0.1, 1.0));
        //d = fOpUnion(d, fSphere(pp, 1.0), 0.1);

#if 1
        float d = 10000;
        for (int i = 0; i < NUM_SPHERES; ++i) {
            vec3 m = vec3(0);
            vec3 ppp = pp;
            ppp.y -= cos(i / 5.0 + uTime) * 2 + 2.0;
            ppp.x -= fbm(vec3(uTime, float(i), 0), 1, 4) * 0.6 - 1;
            ppp.z -= fbm(vec3(0, float(i), uTime), 1, 4) * 0.6 - 1;
            d = fOpUnionSoft(d, fSphere(ppp, 0.25), 0.4);
            //pp.x += 0.2;
            //d = min(d, fSphere(ppp, 1.0));
        }
#endif
        //d += fbm(pp * 8, 0.2, 12) * 0.1;
        h = d < h.x ? vec2(d, 0) : h;
    }

    return h;
}

// Naive sphere tracing
vec2 march(vec3 ro, vec3 rd, float prec, float tMax, int iMax)
{
    vec2 t = vec2(0.001, 0);
    for (int i = 0; i < iMax; ++i) {
        vec2 h = scene(ro + rd * t.x);

        if (h.x < prec || t.x > tMax)
            break;

        t.x += h.x;
        t.y = h.y;
    }
    if (t.x > tMax)
        t.x = INF;
    return t;
}

vec3 shade(vec3 p, vec3 n, vec3 v, float m)
{
    Material mat;
    mat.albedo = dAlbedo; //vec3(0.926,0.721,0.504);
    mat.metallic = dMetallic;
    mat.roughness = dRoughness;

    Material mata;
    mata.albedo = vec3(0.926, 0.721, 0.504);
    mata.metallic = 1.0;
    mata.roughness = 1.0;

    Material matb;
    matb.albedo = vec3(0.0721, 0.0504, 0.0926);
    matb.metallic = 1.0;
    matb.roughness = 1.0;

    vec3 l = normalize(vec3(-1, 1, 0));

    if (p.y > 0.11) {
        vec3 ret =  evalBRDF(n, v, l, mat) * vec3(3);
        ret += bg(-reflect(-v, n)) * 0.1;
        return ret;
    } else {
        vec3 pp = xform(p);
        float s = saturate(fbm(pp * 1, 0.4, 2) * 1.2);
        vec3 reta = evalBRDF(n, v, l, mata) * vec3(3);
        vec3 retb = evalBRDF(n, v, l, matb) * vec3(3);
        vec3 ret = mix(reta, retb, s);
        ret += bg(-reflect(-v, n)) * 0.1;
        return ret;
    }
}

vec3 normal(vec3 p)
{
    vec3 e = vec3(0.0001, 0, 0);
    vec3 n = vec3(scene(vec3(p + e.xyy)).x - scene(vec3(p - e.xyy)).x,
                  scene(vec3(p + e.yxy)).x - scene(vec3(p - e.yxy)).x,
                  scene(vec3(p + e.yyx)).x - scene(vec3(p - e.yyx)).x);
    return normalize(n);
}

vec3 rayDir(vec2 px)
{
    // Neutral camera ray (+Z)
    vec2 uv = px / uRes.xy; // uv
    uv -= 0.5; // origin at center
    uv /= vec2(uRes.y / uRes.x, 1); // fix aspect ratio
    return normalize(vec3(uv, 0.7)); // pull ray
}

vec3 lookAt(vec3 eye, vec3 target, vec3 viewRay) {
    vec3 up = vec3(0, 1, 0);
    vec3 fwd = normalize(target - eye);
    vec3 right = normalize(cross(up, fwd));
    vec3 newUp = normalize(cross(fwd, right));

    return mat3(
        right.x, right.y, right.z,
        newUp.x, newUp.y, newUp.z,
          fwd.x,   fwd.y,  fwd.z) * viewRay;
}

uniform vec3 dCamPos;
uniform vec3 dCamDir;
uniform vec3 dCamTarget = vec3(0, 1, 0);

void main()
{
    // Avoid nags if these aren't used
    if (uTime < -1 || uRes.x < -1)
        discard;

    // Generate camera ray
    vec3 rd = rayDir(gl_FragCoord.xy);
    vec3 ro = vec3(0, 2, -3) - dCamPos;
    vec3 target = vec3(0, 1, 1);

    // Look at target or raw pitch/yaw angles
    rd = lookAt(ro, dCamTarget, rd);
    //   pR(rd.yz, dCamDir.y);
    //   pR(rd.xz, dCamDir.x);

    // Trace them spheres
    vec2 t = march(ro, rd, 0.001, 128, 256);
    if (t.x > 128) {
        fragColor = vec4(bg(rd), 1);
        return;
    }

    // Get hit parameters
    vec3 p = ro + rd * t.x;
    vec3 n = normal(p);
    vec3 v = -rd;
    float m = t.y;

    // Shade
    vec3 color = shade(p, n, v, m);

    // Color the pixel
    fragColor = vec4(tonemap(color), 1);
}
