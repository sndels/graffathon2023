#version 410

#include "uniforms.glsl"
#include "hg_sdf.glsl"
#include "noise.glsl"
#include "shading.glsl"
#include "tonemap.glsl"

out vec4 fragColor;

#define INF (1.0/0.0)

#define SCALE 2.9
#define MINRAD2 .15

const float min_rad2 = 0.15;
//const float 

#define scale_normalized (vec4(SCALE, SCALE, SCALE, abs(SCALE)) / min_rad2)

uniform vec3 dAlbedo = vec3(0.926,0.721,0.502);
uniform float dRough = 1.23;

const float bpm = 145.0 / 4;
float beat = uTime * (bpm / 60);
float bv = (sin(beat * 4 * 3.1415) + 1) * 30.4;

/*
rPos = -17.160
dCamPos = 0.0, 3.630, -1.180
dCamTarget = 0.0, 3.830, 1.1
*/

uniform float rPos;



//----------------------------------------------------------------------------------------
float mandelbox(vec3 pos)
{

	vec4 p = vec4(pos,1);
	vec4 p0 = p;

	//p.x += beat * 0.1;
	for (int i = 0; i < 13; i++)
	{
		p.xyz = clamp(p.xyz, -1.0, 1.0) * 2.0 - p.xyz;

		float r2 = dot(p.xyz, p.xyz);
		p *= clamp(max(min_rad2/r2, min_rad2), 0.0, 1.0);

		p = p*scale_normalized + p0;
	}
	return ((length(p.xyz) - (SCALE + bv - 1.0)) / p.w - pow(abs(SCALE), -7.5 + bv * 0.01));
}


vec3 bg(vec3 d) {
    return mix(vec3(0), vec3(1), d.y);
}
// Returns distance to hit and material index
vec2 scene(vec3 p)
{
    p.xyz = p.yxz;
    vec2 h = vec2(INF);

    {
        vec3 pp = p;
        //pModMirror2(pp.xy, vec2(.4, .4));
        pR(pp.xz, rPos);
        pR(pp.yz, rPos);
        pp.x += sin(rPos);
        //float d = fIcosahedron(pp, 0.1, 30.);
        vec3 fp = p;
        fp.x += rPos * 0.01;
        fp.z += 0.02;
        float d = mandelbox(fp);
        h = d < h.x ? vec2(d, 0) : h;
    }

    return h;
}

// Naive sphere tracing
vec3 march(vec3 ro, vec3 rd, float prec, float tMax, int iMax)
{
    vec2 t = vec2(0.001, 0);
    int i;
    for (i = 0; i < iMax; ++i) {
        vec2 h = scene(ro + rd * t.x);
        if (h.x < prec || t.x > tMax)
            break;
        t.x += h.x;
        t.y = h.y;
    }
    if (t.x > tMax)
        t.x = INF;
    return vec3(t, i);
}

vec3 shade(vec3 p, vec3 n, vec3 v, float m)
{
    Material mat;
    mat.albedo = dAlbedo; //vec3(0.926,0.721,0.504);
    mat.metallic = 1;
    mat.roughness = dRough; //0.6;

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

vec3 dCamPos = vec3(0);
//vec3 dCamDir;
vec3 dCamTarget = vec3(0);

void main()
{
    // Avoid nags if these aren't used
    if (uTime < -1 || uRes.x < -1)
        discard;

    if (uTime > 160.0) {
        dCamPos = vec3(0.0, 3.630, -1.180);
        dCamTarget = vec3(0.0, 3.830, 1.1);
    }


    // Generate camera ray
    vec3 rd = rayDir(gl_FragCoord.xy);
    vec3 ro = vec3(0, 0, -3) - dCamPos;
    vec3 target = vec3(0, 1, 1);

    // Look at target or raw pitch/yaw angles
    rd = lookAt(ro, dCamTarget, rd);
    //   pR(rd.yz, dCamDir.y);
    //   pR(rd.xz, dCamDir.x);

    // Trace them spheres
    vec3 t = march(ro, rd, 0.0001, 128, 256);
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
    vec3 color = shade(p, n, v, m) * pow(0.96, t.z * t.x);

    // Color the pixel
    fragColor = vec4(tonemap(color), 1);
}
