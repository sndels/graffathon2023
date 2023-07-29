#version 410

#include "uniforms.glsl"
#include "hg_sdf.glsl"
#include "noise.glsl"
#include "shading.glsl"
#include "tonemap.glsl"

out vec4 fragColor;

#define INF (1.0/0.0)


vec3 bg(vec3 d) {
    vec2 uv = gl_FragCoord.xy*2.0 / uRes.xy - 1.0;

    // Time varying pixel color
    float x_temp;
    float x =  0.0;
    float y = 0.0;
    int max_iter = 8000;
    int i = 0;
    
    mat2 rot = mat2(
        cos(uTime), -sin(uTime),
        sin(uTime), cos(uTime)
    );
    float zoomFactor = pow(2.0, -3.0+3.0*sin(uTime * 0.5));
    mat2 zoom = mat2(
        zoomFactor* 2.5, 0,
        0, 2.5 * zoomFactor
    );
    
    vec2 translation = vec2(0.33334,0.4201);
    
    uv = uv * rot * zoom + translation;
    
    for(i = 0;x*x + y*y <= 2.0*2.0 && i<max_iter;i++)
    {
        x_temp = x*x - y*y + uv.x;
        y = 2.0*x*y + uv.y;
        x = x_temp;
    }
    
    float log_zn;
    float nu;
    float i_float = float(i);
    if (i == max_iter) {
        i = 0;
        i_float = 0.0;
    }
    else if (i < max_iter) {
        log_zn = log(x*x + y*y) / 2.0;
        nu = log((log_zn / log(2.0))) / log(2.0);
        i_float = i_float - nu;
    }

    

    //vec3 col = vec3(x,y,0.0);
    vec3 col = vec3(i_float*0.01,i_float*0.01,0);
    col.x = pow(col.x, 0.5+0.5*cos(uTime));
    float parina = 10.0*pow(col.y, 0.05+0.05*sin(uTime));
    col.y = abs(0.5 - 0.5*cos(parina))+0.00001;
    col.z = abs(0.5 - 0.1*cos(parina))+0.00001;

    return mix(vec3(col.x*0.3,0,0), vec3(0,col.y*0.5,0), 0.5);
}
// Returns distance to hit and material index
vec2 scene(vec3 p)
{
    vec2 h = vec2(INF);

    {
        vec3 pp = p;
        pModMirror2(pp.xy, vec2(3, 3));
        pR(pp.xz, uTime);
        pR(pp.yz, uTime);
        float d = fIcosahedron(pp, .6+abs(sin(uTime)*0.3), 30.+abs(cos(uTime*5)*1.));
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

vec3 shade(vec3 p, vec3 n, vec3 v, float m)
{
        vec2 uv = gl_FragCoord.xy*2.0 / uRes.xy - 1.0;

    // Time varying pixel color
    float x_temp;
    float x =  0.0;
    float y = 0.0;
    int max_iter = 8000;
    int i = 0;
    
    mat2 rot = mat2(
        cos(uTime), sin(uTime),
        -sin(uTime), cos(uTime)
    );
    float zoomFactor = pow(2.0, sin(uTime * 0.5));
    mat2 zoom = mat2(
        zoomFactor* 2.5, 0,
        0, 2.5 * zoomFactor
    );
    
    vec2 translation = vec2(0.33334,0.4201);
    
    uv = uv * rot * zoom + translation;
    
    for(i = 0;x*x + y*y <= 2.0*2.0 && i<max_iter;i++)
    {
        x_temp = x*x - y*y + uv.x;
        y = 2.0*x*y + uv.y;
        x = x_temp;
    }
    
    float log_zn;
    float nu;
    float i_float = float(i);
    if (i == max_iter) {
        i = 0;
        i_float = 0.0;
    }
    else if (i < max_iter) {
        log_zn = log(x*x + y*y) / 2.0;
        nu = log((log_zn / log(2.0))) / log(2.0);
        i_float = i_float - nu;
    }

    

    //vec3 col = vec3(x,y,0.0);
    vec3 col = vec3(i_float*0.01,i_float*0.01,0);
    col.x = 0.2;
    float parina = 1000.0*pow(col.y, 0.05+0.05*sin(uTime));
    col.y = 0;
    col.z = abs(0.5 - 0.5*cos(parina))+0.00001;

    Material mat;
    mat.albedo = vec3(0.2342,0.8685,.98981);
    mat.metallic = 10;
    mat.roughness = 1;

    vec3 l = normalize(vec3(1, 1, -1));
    vec3 ret =  evalBRDF(n, v, l, mat) * vec3(col.x*.3,col.y*.3,col.z);
    ret += bg(-reflect(-v, n)) * 0.5;
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
        fragColor = vec4(bg(rd), 1.1);
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
