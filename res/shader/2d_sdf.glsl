// Interface based on hg_sdf by Mercury
// http://mercury.sexy/hg_sdf

#ifndef PI
#define PI 3.14159265
#endif // !PI

#ifndef INF
#define INF (1.0/0.0)
#endif // !INF

#ifndef saturate
#define saturate(x) clamp(x, .0, 1.)
#endif // saturate

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

float dCharA(vec2 p, inout float cursor)
{
    float d = dCircle(p - vec2(-.05, .0), 1.);
    d = fOpDifference(d, dCircle(p - vec2(-.05, .0), .6));
    d = fOpUnion(d, dRect(p - vec2(.8 , .0), vec2(.2, 1.)));
    cursor += 2.6;
    return d;
}

float dCharB(vec2 p, inout float cursor)
{
    float d = dCircle(p - vec2(.05, .0), 1.);
    d = fOpDifference(d, dCircle(p - vec2(.05, .0), .6));
    d = fOpUnion(d, dRect(p - vec2(-.79 , .75), vec2(.2, 1.75)));
    cursor += 2.5;
    return d;
}

float dCharC(vec2 p, inout float cursor)
{
    float d = dCircle(p, 1.05);
    d = fOpDifference(d, dCircle(p, .65));
    vec2 pp = p;
    pR(pp, PI / 7);
    d = fOpDifference(d, dRect(pp - vec2(.85 , -.1), vec2(.65, .25)));
    pR(pp, -PI / 3.5);
    d = fOpDifference(d, dRect(pp - vec2(.85 , -.1), vec2(.65, .25)));
    d = fOpDifference(d, dRect(p - vec2(1.25 , -.1), vec2(.75, .3)));
    cursor += 2.3;
    return d;
}

float dCharD(vec2 p, inout float cursor)
{
    float d = dCircle(p - vec2(-.05, .0), 1.);
    d = fOpDifference(d, dCircle(p - vec2(-.05, .0), .6));
    d = fOpUnion(d, dRect(p - vec2(.79 , .75), vec2(.2, 1.75)));
    cursor += 2.5;
    return d;
}

float dCharE(vec2 p, inout float cursor)
{
    float d = dCircle(p, 1.05);
    d = fOpDifference(d, dCircle(p, .65));
    d = fOpDifference(d, dRect(p - vec2(.85 , -.2), vec2(.65, .2)));
    vec2 pp = p;
    pR(pp, PI / 7);
    d = fOpDifference(d, dRect(pp - vec2(.85 , -.1), vec2(.65, .25)));
    d = fOpUnion(d, dRect(p - vec2(.01, .1), vec2(.9, .1)));
    cursor += 2.5;
    return d;
}

float dCharF(vec2 p, inout float cursor)
{
    float d = dCircle(p - vec2(-.2, 1.5), .8);
    d = fOpDifference(d, dCircle(p - vec2(-.19, 1.45), .42));
    d = fOpDifference(d, dRect(p - vec2(.25, .8), vec2(.9, .75)));
    d = fOpUnion(d, dRect(p - vec2(-.8 , .25), vec2(.2, 1.275)));
    d = fOpUnion(d, dRect(p - vec2(-.2 , .5), vec2(.5, .2)));
    cursor += 2.;
    return d;
}

float dCharG(vec2 p, inout float cursor)
{
    float d = dCircle(p - vec2(.07, -1.5), 1.);
    d = fOpDifference(d, dCircle(p - vec2(.07, -1.5), .6));
    d = fOpDifference(d, dRect(p - vec2(-.5, -.9), vec2(1.9, .75)));
    d = fOpUnion(d, dCircle(p - vec2(-.05, .0), 1.));
    d = fOpDifference(d, dCircle(p - vec2(-.05, .0), .6));
    d = fOpUnion(d, dRect(p - vec2(.855 , -.35), vec2(.2, 1.35)));
    cursor += 2.7;
    return d;
}

float dCharH(vec2 p, inout float cursor)
{
    float d = dCircle(p - vec2(.0, .0), 1.);
    d = fOpDifference(d, dCircle(p - vec2(.0, .0), .6));
    d = fOpDifference(d, dRect(p - vec2(-.5, -.75), vec2(1.9, .75)));
    d = fOpUnion(d, dRect(p - vec2(-.8 , .75), vec2(.2, 1.75)));
    d = fOpUnion(d, dRect(p - vec2(.8 , -.5), vec2(.2, .5)));
    cursor += 2.5;
    return d;
}

float dCharI(vec2 p, inout float cursor)
{
    float d = dRect(p - vec2(-.75, .25), vec2(.2, 1.25));
    d = fOpDifference(d, dRect(p - vec2(-.75, .75), vec2(.5, .3)));
    cursor += 1.1;
    return d;
}

float dCharJ(vec2 p, inout float cursor)
{
    float d = dCircle(p - vec2(-.5, -1.75), .8);
    d = fOpDifference(d, dCircle(p - vec2(-.5, -1.75), .42));
    d = fOpDifference(d, dRect(p - vec2(-.7, -1.), vec2(2.9, .75)));
    d = fOpUnion(d, dRect(p - vec2(.11, -.15), vec2(.2, 1.6)));
    d = fOpDifference(d, dRect(p - vec2(.35, .75), vec2(1., .3)));
    cursor += 2.;
    return d;
}

float dCharK(vec2 p, inout float cursor)
{
    vec2 pp = p - vec2(.1, .8);
    pR(pp, PI / 3.5);
    float d = dRect(pp, vec2(.2, 1.2));
    pp = p - vec2(.1, -.6);
    pR(pp, -PI / 4);
    d = fOpUnion(d, dRect(pp, vec2(.2, 1.2)));
    d = fOpDifference(d, dRect(p - vec2(.0, -1.4), vec2(1.5, .4)));
    d = fOpDifference(d, dRect(p - vec2(.0, 1.4), vec2(1.5, .4)));
    d = fOpUnion(d, dRect(p - vec2(-.75, .75), vec2(.2, 1.75)));
    cursor += 2.25;
    return d;
}


float dCharL(vec2 p, inout float cursor)
{
    float d = dRect(p - vec2(-.75, .75), vec2(.2, 1.75));
    cursor += 1.2;
    return d;
}

float dCharM(vec2 p, inout float cursor)
{
    float d = dCircle(p - vec2(.0, .0), 1.);
    d = fOpUnion(d, dCircle(p - vec2(1.5, .0), 1.));
    d = fOpDifference(d, dCircle(p - vec2(.0, .0), .6));
    d = fOpDifference(d, dCircle(p - vec2(1.5, .0), .6));
    d = fOpDifference(d, dRect(p - vec2(.25, -.65), vec2(2.9, .75)));
    d = fOpUnion(d, dRect(p - vec2(-.8 , .0), vec2(.2, 1.)));
    d = fOpUnion(d, dRect(p - vec2(.75, -.3), vec2(.2, .7)));
    d = fOpUnion(d, dRect(p - vec2(2.29, -.4), vec2(.2, .6)));
    cursor += 4.1;
    return d;
}

float dCharN(vec2 p, inout float cursor)
{
    float d = dCircle(p - vec2(.0, .0), 1.);
    d = fOpDifference(d, dCircle(p - vec2(.0, .0), .6));
    d = fOpDifference(d, dRect(p - vec2(.25, -.65), vec2(2.9, .75)));
    d = fOpUnion(d, dRect(p - vec2(-.8 , .0), vec2(.2, 1.)));
    d = fOpUnion(d, dRect(p - vec2(.8, -.45), vec2(.2, .55)));
    cursor += 2.5;
    return d;
}

float dCharO(vec2 p, inout float cursor)
{
    float d = dCircle(p, 1.05);
    d = fOpDifference(d, dCircle(p, .65));
    cursor += 2.5;
    return d;
}

float dCharP(vec2 p, inout float cursor)
{
    float d = dCircle(p - vec2(.0, .0), 1.);
    d = fOpDifference(d, dCircle(p - vec2(.0, .0), .6));
    d = fOpUnion(d, dRect(p - vec2(-.8 , -.75), vec2(.2, 1.75)));
    cursor += 2.5;
    return d;
}

float dCharQ(vec2 p, inout float cursor)
{
    float d = dCircle(p - vec2(-.05, .0), 1.);
    d = fOpDifference(d, dCircle(p - vec2(-.05, .0), .6));
    d = fOpUnion(d, dRect(p - vec2(.8 , -.75), vec2(.2, 1.75)));
    cursor += 2.6;
    return d;
}

float dCharR(vec2 p, inout float cursor)
{
    float d = dCircle(p - vec2(.0, .0), 1.);
    d = fOpDifference(d, dCircle(p - vec2(.0, .0), .6));
    d = fOpDifference(d, dRect(p - vec2(.25, -.65), vec2(.9, .75)));
    d = fOpUnion(d, dRect(p - vec2(-.8 , .0), vec2(.2, 1.)));
    cursor += 2.25;
    return d;
}

float dCharS(vec2 p, inout float cursor)
{
    float dTop = dCircle(p - vec2(-.1, .4), .6);
    dTop = fOpDifference(dTop, dCircle(p - vec2(-.1, .4), .2));
    vec2 pp = p - vec2(.75 , .4);
    pR(pp, -PI / 4);
    dTop = fOpDifference(dTop, dRect(pp, vec2(1., .5)));

    float dBottom = dCircle(p - vec2(-.3, -.39), .6);
    dBottom = fOpDifference(dBottom, dCircle(p - vec2(-.3, -.39), .2));
    pp = p - vec2(-1. , -.3);
    pR(pp, -PI / 5);
    dBottom = fOpDifference(dBottom, dRect(pp, vec2(.7, .5)));

    float d = fOpUnion(dTop, dBottom);
    cursor += 1.9;
    return d;
}

float dCharT(vec2 p, inout float cursor)
{
    float d = dRect(p - vec2(-.25, .75), vec2(.2, 1.75));
    d = fOpUnion(d, dRect(p - vec2(-.25, 1.25), vec2(.75, .2)));
    cursor += 2.;
    return d;
}

float dCharU(vec2 p, inout float cursor)
{
    float d = dCircle(p - vec2(-.05, .0), 1.);
    d = fOpDifference(d, dCircle(p - vec2(-.05, .0), .6));
    d = fOpDifference(d, dRect(p - vec2(.25, .65), vec2(2.9, .7)));
    d = fOpUnion(d, dRect(p - vec2(-.84, .4), vec2(.2, .6)));
    d = fOpUnion(d, dRect(p - vec2(.75 , .0), vec2(.2, 1.)));
    cursor += 2.5;
    return d;
}

float dCharV(vec2 p, inout float cursor)
{
    vec2 pp = p - vec2(.5, -.2);
    pR(pp, PI / 7);
    float d = dRect(pp, vec2(.2, 1.5));
    pp = p - vec2(-.1, -.2);
    pR(pp, -PI / 7);
    d = fOpUnion(d, dRect(pp, vec2(.2, 1.5)));
    d = fOpDifference(d, dRect(pp - vec2(-.45), vec2(.25, 1.2)));
    pR(pp, PI / 3.5);
    d = fOpDifference(d, dRect(pp - vec2(1., -.6), vec2(.25, 1.2)));
    d = fOpDifference(d, dRect(p - vec2(.0, -1.4), vec2(1.5, .4)));
    d = fOpDifference(d, dRect(p - vec2(.0, 1.4), vec2(1.5, .4)));
    cursor += 2.8;
    return d;
}

float dCharW(vec2 p, inout float cursor)
{
    float d = dCharV(p, cursor);
    d = fOpUnion(d, dCharV(p - vec2(1.1, .0), cursor));
    cursor -= 1.6;
    return d;
}
float dCharX(vec2 p, inout float cursor)
{
    vec2 pp = p;
    pR(pp, PI / 5);
    float d = dRect(pp, vec2(.2, 1.5));
    pp = p;
    pR(pp, -PI / 5);
    d = fOpUnion(d, dRect(pp, vec2(.2, 1.5)));
    d = fOpDifference(d, dRect(p - vec2(.0, -1.4), vec2(1.25, .4)));
    d = fOpDifference(d, dRect(p - vec2(.0, 1.4), vec2(1.25, .4)));
    cursor += 2.5;
    return d;
}

float dCharY(vec2 p, inout float cursor)
{
    vec2 pp = p - vec2(-.1, -.2);
    pR(pp, -PI / 7);
    float d = dRect(pp, vec2(.2, 1.5));
    pp = p - vec2(.3, -.6);
    pR(pp, PI / 7);
    d = fOpDifference(d, dRect(pp - vec2(.5, -.7), vec2(.45, 1.2)));
    d = fOpUnion(d, dRect(pp, vec2(.2, 2.)));
    d = fOpDifference(d, dRect(p - vec2(.0, 1.4), vec2(1.5, .4)));
    cursor += 2.9;
    return d;
}

float dCharZ(vec2 p, inout float cursor)
{
    float d = dRect(p - vec2(.0, .8), vec2(1., .2));
    d = fOpUnion(d, dRect(p - vec2(.0, -.8), vec2(1., .2)));
    vec2 pp = p;
    pR(pp, PI / 5);
    d = fOpDifference(d, dRect(pp - vec2(0.4, 1.), vec2(.2, 1.)));
    d = fOpDifference(d, dRect(pp - vec2(-0.4, -1.), vec2(.2, 1.)));
    d = fOpUnion(d, dRect(pp , vec2(.2, 1.5)));
    d = fOpDifference(d, dRect(p - vec2(.0, -1.4), vec2(1.25, .4)));
    d = fOpDifference(d, dRect(p - vec2(.0, 1.4), vec2(1.25, .4)));
    cursor += 2.5;
    return d;
}

float dCharExclamation(vec2 p, inout float cursor)
{
    float d = dRect(p - vec2(-.75, .75), vec2(.2, 1.75));
    d = fOpDifference(d, dRect(p - vec2(-.75, -.2), vec2(.5, .3)));
    cursor += 1.;
    return d;
}

float dCharColon(vec2 p, inout float cursor)
{
    float d = dRect(p - vec2(-.75, .0), vec2(.2, .75));
    d = fOpDifference(d, dRect(p - vec2(-.75, .0), vec2(.5, .3)));
    cursor += 1.;
    return d;
}

float dCharDash(vec2 p, inout float cursor)
{
    float d = dRect(p - vec2(-.25, .0), vec2(.65, .2));
    d = fOpDifference(d, dRect(p - vec2(-.75, .75), vec2(.5, .3)));
    cursor += 2.1;
    return d;
}

float dCharUnderscore(vec2 p, inout float cursor)
{
    float d = dRect(p - vec2(-.5, -.75), vec2(.85, .2));
    d = fOpDifference(d, dRect(p - vec2(-.75, .75), vec2(.5, .3)));
    cursor += 1.55;
    return d;
}

float dCharSpace(vec2 p, inout float cursor)
{
    cursor += 2.;
    return INF;
}

float dCharBox(vec2 p, inout float cursor)
{
    float d = dRect(p, vec2(.85, 1.));
    cursor += 2.5;
    return d;
}
