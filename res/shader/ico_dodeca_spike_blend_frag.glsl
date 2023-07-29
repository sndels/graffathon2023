#version 410

#include "uniforms.glsl"
#include "hg_sdf.glsl"
#include "noise.glsl"
#include "shading.glsl"
#include "tonemap.glsl"

out vec4 fragColor;

#define INF (1.0/0.0)

uniform vec3 dColor = vec3(.0, .896, 1.);
uniform vec3 dPos;
uniform vec3 dRot;

vec3 bg(vec3 d) {
    return mix(vec3(.553, .903, .078) * .2, vec3(.879, .061, .995), d.y * 0.5 + 0.5);
}

// Returns distance to hit and material index
vec2 scene(vec3 p)
{
    vec2 h = vec2(INF);

    // { // Scaly thing
    //     pR(p.xz, uTime * .5);
    //     pR(p.yz, uTime * .8);
    //     vec3 pp = p;
    //     pR(pp.xz, .3);
    //     float d = fIcosahedron(pp, 4., 30.);

    //     pp = p;
    //     pMod1(pp.y, .2);
    //     pp -= vec3(.0, .4, .0);
    //     d = fOpDifferenceChamfer(d, fBox(pp, vec3(100., .4, 100.)), .1);

    //     d -= .1;

    //     h = d < h.x ? vec2(d, 1) : h;
    // }

    {
        // pR(p.yz, uTime);
        // pR(p.xz, PI / 2);
        pR(p.xy, PI / 4);
        pR(p.yz, .1);
        pR(p.xz, uTime * .2);
        vec3 pp = p;
        pR(pp.xz, .3);
        float d = fIcosahedron(pp, 4.);
        d = mix(d, fDodecahedron(pp, 3.), cos(uTime));

        pp = p;
        pp -= vec3(.0, fract(uTime) * 2, .0);
        pMod1(pp.y, 2.);


        d -= .1;

        h = d < h.x ? vec2(d, 1) : h;
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

vec2 marchEnhanced(vec3 ro, vec3 rd, float pixelRadius, float tMax, int iMax) {
    // o, d : ray origin, direction (normalized)
    // t_min, t_max: minimum, maximum t values
    // pixelRadius: radius of a pixel at t = 1
    // forceHit: boolean enforcing to use the
    // candidate_t value as result
    float t_min = 0.001;
    float omega = 1.2;
    float t = t_min;
    float candidate_error = INF;
    vec2 candidate_h = vec2(t_min, -1);
    float previousRadius = 0;
    float stepLength = 0;
    float functionSign = scene(ro).x < 0 ? -1 : +1;
    for (int i = 0; i < iMax; ++i) {
        vec2 h = scene(rd * t + ro);
        float signedRadius = functionSign * h.x;
        float radius = abs(signedRadius);
        bool sorFail = omega > 1 && (radius + previousRadius) < stepLength;
        if (sorFail) {
            stepLength -= omega * stepLength;
            omega = 1;
        } else {
            stepLength = signedRadius * omega;
        }
        previousRadius = radius;
        float error = radius / t;
        if (!sorFail && error < candidate_error) {
            candidate_h = vec2(t, h.y);
            candidate_error = error;
        }
        if (!sorFail && error < pixelRadius || t > tMax)
            break;
        t += stepLength;
    }
    if (t > tMax || candidate_error > pixelRadius)
        candidate_h.x = INF;
    return candidate_h;
}

vec3 shade(vec3 p, vec3 n, vec3 v, float m)
{
    Material mat;
    mat.albedo = vec3(0.926,0.721,0.504);
    mat.metallic = 1;
    mat.roughness = 0.2;

    vec3 l = normalize(vec3(1., -.8, -1.));
    vec3 I = 3. * vec3(.553, .903, .078);
    vec3 ret = evalBRDF(n, v, l, mat) * I;

    l = normalize(vec3(-1., .8, -1));
    I = 3. * vec3(.879, .061, .995);
    ret += evalBRDF(n, v, l, mat) * I;

    vec3 lBg = reflect(-v, n);
    ret += bg(lBg) * 0.1;
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

    pcg_state = uvec3(gl_FragCoord.xy, uTime * 1000);

    // Generate camera ray
    vec3 rd = rayDir(gl_FragCoord.xy);
    vec3 ro = vec3(0., 0., -12.);// - dCamPos;
    vec3 target = vec3(0., 2., 1.);

    float pixelRadius = distance(rd, rayDir(gl_FragCoord.xy + 1)) / 4;

    // Look at target or raw pitch/yaw angles
    rd = lookAt(ro, dCamTarget, rd);
    //   pR(rd.yz, dCamDir.y);
    //   pR(rd.xz, dCamDir.x);
    rd = normalize(rd);

    // Trace them spheres
    float tMax = 128;
    vec2 t = marchEnhanced(ro, rd, pixelRadius, tMax, 256);
    // vec2 t = march(ro, rd, 0.001, tMax, 256);
    if (t.x > tMax) {
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
