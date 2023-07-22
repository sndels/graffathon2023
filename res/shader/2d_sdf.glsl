// Interface based on hg_sdf by Mercury
// http://mercury.sexy/hg_sdf

#define PI 3.14159265
#define INF (1.0/0.0)
#define saturate(x) clamp(x, 0.0, 1.0)

void pR(inout vec2 p, float a)
{
    p = mat2(cos(a), sin(a), -sin(a), cos(a)) * p;
}

float fOpUnion(float d0, float d1)
{
    return min(d0, d1);
}

float fOpDifference(float d0, float d1)
{
    return max(d0, -d1);
}

float fOpIntersection(float d0, float d1)
{
    return max(d0, d1);
}

float dCircle(vec2 p, float r)
{
    return length(p) - r;
}

float dRect(vec2 p, vec2 size)
{
    vec2 d = abs(p) - size;
    return max(d.x, d.y);
}

float dLine(vec2 p, float r)
{
    return length(p.y) - r;
}

float dHalfSpace(float p, float r)
{
    return p - r;
}
