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

float sdRoundBox( vec3 p, vec3 b, float r )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}

vec3 opRep( in vec3 p, in vec3 c)
{
    return mod(p+0.5*c,c)-0.5*c;
}

// Returns distance to hit and material index
vec2 scene(vec3 p)
{
    vec2 h = vec2(INF);
    vec3 pr = p;
    // pr.x += sin(pr.y) * sin(uTime*0.5);
    // pr.z += log2(length(pr)) * sin(pr.z * 100.0);
    // pr.x *= 5.0;
    // pr.x *= 5.0;
    pr *= log2(length(pr));
    pr -= vec3(0.0, 2.0, 30.0);
    pR(pr.xz, uTime*0.9);
    pR(pr.xy, uTime);
    
    float bleb = 12.0;
    float pehmeys = 0.17;
    float paksuus = 1.0;
    pr = opRep(pr, vec3(2.0 * bleb));

    float rod1 = sdRoundBox(pr, vec3(bleb, paksuus, paksuus), pehmeys);
    float rod2 = sdRoundBox(pr, vec3(paksuus, bleb, paksuus), pehmeys);
    float rod3 = sdRoundBox(pr, vec3(paksuus, paksuus, bleb), pehmeys);


    float d = fOpUnionChamfer(rod1, rod2, 0.0);
    d = fOpUnionChamfer(d, rod3, 0.0);

    h = d < h.x ? vec2(d, 0) : h;
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

uniform vec3 dColor = vec3(0.442,0.166,0.513);
vec3 shade(vec3 p, vec3 n, vec3 v, float m)
{
    Material mat;
    mat.albedo = dColor;
    mat.metallic = 1;
    mat.roughness = 0.1;

    vec3 l = normalize(vec3(1, 1, -1));

    vec3 ret = evalBRDF(n, v, l, mat) / length((p-vec3(0.0, 3.0, 30.0)) * vec3(0.00005));
    v = -reflect(-v, n);
    ret += evalBRDF(n, v, l, mat) * bg(v);
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
    float tmax = 1024;
    vec2 t = march(ro, rd, 0.001, tmax, 256);
    if (t.x > tmax) {
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
