#version 410

#include "uniforms.glsl"
#include "noise.glsl"

uniform vec3 dColor;

out vec4 fragColor;

struct Point {
  vec2 pos;
  float offset_x;
  float offset_y;
  float v_x;
  float v_y;
  float v_max;
  float max_x_offset;
  float max_y_offset;
  vec3 point_color;
};

Point init_point(float pos_init)
{
  Point point;
  point.pos = vec2(pos_init);
  point.offset_x = point.pos.x;
  point.offset_y = point.pos.y;
  point.v_x = 5.0;
  point.v_y = 5.0;
  point.v_max = 10.0;
  point.max_x_offset = 10.0;
  point.max_y_offset = 10.0;
  point.point_color = vec3(
        0.5,
        0.5,
        0.5
    );
  return point;
}

Point update_point(Point point, float k)
{
  point.pos = vec2(point.pos.x + k*10*point.v_y*(cos(uTime)) + 0.5*point.v_x*(sin(uTime)),
                   point.pos.y + k*10*point.v_y*(cos(uTime/5)))+ 0.5*point.v_x*(sin(uTime));
  return point;
}

Point point1 = init_point(0.0);
Point point2 = init_point(10.0);
float prev_time = uTime;

void main()
{
    // Avoid nags if these aren't used
    if (uTime < -1 || uRes.x < -1)
        discard;

    pcg_state = uvec3(gl_FragCoord.xy, uTime*100);
    vec2 uv = gl_FragCoord.xy*2.0 / uRes.xy - 1.0;
    float ar = float(uRes.x) / uRes.y;
    uv *= 100;
    uv.x *= ar;
    vec2 rOff = vec2(sin(uTime*0.432552), cos(uTime*0.127652));
    vec2 gOff = vec2(sin(uTime*0.245313), cos(uTime*0.628314));
    vec2 bOff = vec2(sin(uTime*0.120647), cos(uTime*0.394022));

    point1 = update_point(point1, 1);
    point2 = update_point(point2, 0.2*cos(uTime));

    //rnd01()*dColor;
    //TÄHÄN TUNNELIPIXELIN VÄRI
    float dist = distance(uv, point1.pos);
    float dist_mod = 200.0;
    float utime_mod = mod(uTime*800.0,1000.0);
    float k = mod(sqrt(dist/2)*150-utime_mod,dist_mod);
    //float k = mod(sqrt(dist/1)*80-utime_mod,dist_mod)-dist*0.2;
    vec3 color = vec3(
        (100.0-k)*0.004,
        sqrt((100.0-k))*0.003,
        sqrt((100.0-k))*0.005*sin(uTime)
    );

    if (distance(uv, point1.pos) < 3.70){
      color = vec3(
        (100.0-k)*0.004,
        sqrt((100.0-k))*0.003,
        sqrt((100.0-k))*0.005*sin(uTime)
      );
    }

    //traveler color
    if (distance(uv, point2.pos) < (rnd01()*6+2.5+abs(sin(uTime))*5.5)){
      color = vec3(
        .5+0.5*sin(length(uv + rOff)*1.4 + 1.0*cos(uTime * 1.5)),
        .5+0.5*cos(length(uv + gOff)*.9 + 10.0*cos(uTime * 0.2)),
        .5+0.5*sin(length(uv + bOff)*.3 + 10.0*cos(uTime * 0.9))
      );
    }
    /*
     + vec3(
        0.5+0.5*sin(length(uv + rOff)*3.4 + 10.0*cos(uTime * 1.0)),
        0.5+0.5*sin(length(uv + gOff)*2.9 + 10.0*cos(uTime * 1.2)),
        0.5+0.5*sin(length(uv + bOff)*1.3 + 10.0*cos(uTime * 0.9))
    );
*/
    fragColor = vec4(color, 1);
}
