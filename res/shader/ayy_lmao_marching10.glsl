#version 410

#include "uniforms.glsl"
#include "hg_sdf.glsl"
#include "noise.glsl"
#include "shading.glsl"
#include "tonemap.glsl"

out vec4 fragColor;

#define INF (1.0/0.0)


vec3 bg(vec3 d) {
    return mix(vec3(0), vec3(1), d.y);
}

vec3 bend(vec3 pp) {
    float kb = 0.9*sin(uTime*4.); // tweak me baby aha aha
    float cb = cos(kb*pp.x);
    float sb = sin(kb*pp.x); // lmao
    mat2 mb = mat2(cb, -sb, sb, cb);
    vec3 qb = vec3(mb*pp.xy, pp.z); // miksi
    return qb;
}

vec3 hyrtsiRep(in vec3 p, in vec3 c) {
    return mod(p+0.5*c,c)-0.5*c;
}

float fDiscHyrtsi(vec3 pp)
{
    pR(pp.xy, uTime*0.5);
    pR(pp.yz, uTime*0.5);
    float disc = fCylinder(pp, 1000., 0.02);
    return disc;
}

vec3 flurb(vec3 pp)
{
    float k = 1.5 * sin(uTime*0.9) + 0.1 * sin(uTime*10.0); // tweak me baby
    float c = cos(k*pp.y) + 0.15 * cos(1.0 + 7.0*k*pp.z);
    float s = sin(k*pp.y);
    mat2  m = mat2(c,-s,s,c);
    vec3  q = vec3(m*pp.xz, pp.y);
    return q;
}

// Returns distance to hit and material index
vec2 scene(vec3 p)
{
    vec2 h = vec2(INF);

    {
        vec3 pp = p;

        pp = bend(pp);
        pR(pp.yz, uTime*3.0);
        pR(pp.xz, uTime*2.0);
        pR(pp.xy, uTime*0.1);

        float disc = fDiscHyrtsi(pp);

        pR(pp.xz, uTime*0.1);
        pp = p;
        pp = hyrtsiRep(pp, vec3(7.0));
        pp = flurb(pp);
        
        float d = fSphere(pp, 1.0);
        float dism = sin(2.0*pp.x)*sin(10.1*pp.y)*sin(19.99*pp.z);
        float a = 0.99 * sin(uTime * .1 + 5.0);
        float aa = 0.1 * sin(PI + uTime * 2.0);
        float aaa = 0.001 * sin(uTime * 100.0);
        float aaaa = 0.0005 * sin(uTime * 500.0 + 7.0);
        float cycle = 0.5 * (a + aa + aaa + aaaa);
        d = d + dism*cycle;

        d = max(d,disc);
        // d = disc;
        // d = fOpIntersectionRound(d, disc, 0.8);

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
    mat.albedo = vec3(0.926,0.721,0.504);
    mat.metallic = 1;
    mat.roughness = 0.1;

    vec3 l = normalize(vec3(1, 1, -1));
    vec3 ret =  evalBRDF(n, v, l, mat) * vec3(3);
    ret += bg(-reflect(-v, n)) * 0.1;
    return ret;
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
uniform vec3 dCamTarget;

void main()
{
    // Avoid nags if these aren't used
    if (uTime < -1 || uRes.x < -1)
        discard;

    // Generate camera ray
    vec3 rd = rayDir(gl_FragCoord.xy);
    vec3 ro = vec3(0, 0, -3) - dCamPos;
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
