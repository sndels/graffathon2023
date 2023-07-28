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

float dHalfCircle(vec2 p, float r)
{
    float d = length(p) - r;
    d = fOpDifference(d, dHalfSpace(p.y, .0));
    return d;
}

#define FONT_WIDTH 3.
#define FONT_DESCENDERS -2.5

float dCharA(vec2 p)
{
    float d = dCircle(p - vec2(.0, .0), 1.);
    d = fOpDifference(d, dCircle(p - vec2(.0, .0), .6));
    d = fOpUnion(d, dRect(p - vec2(.8 , -.5), vec2(.2, 0.5)));
    return d;
}

float dCharB(vec2 p)
{
    float d = dCircle(p - vec2(.0, .0), 1.);
    d = fOpDifference(d, dCircle(p - vec2(.0, .0), .6));
    d = fOpUnion(d, dRect(p - vec2(-.8 , 1.25), vec2(.2, 1.25)));
    return d;
}

float dCharC(vec2 p)
{
    float d = dCircle(p, 1.);
    d = fOpDifference(d, dCircle(p, .6));
    vec2 pp = p - vec2(.85 , .4);
    pR(pp, -PI / 7);
    d = fOpDifference(d, dRect(pp, vec2(.65, .25)));
    pp = p - vec2(.85 , -.4);
    pR(pp, PI / 7);
    d = fOpDifference(d, dRect(pp, vec2(.65, .25)));
    d = fOpDifference(d, dRect(p - vec2(1.25 , -.1), vec2(.75, .4)));
    return d;
}

float dCharD(vec2 p)
{
    float d = dCircle(p - vec2(.0, .0), 1.);
    d = fOpDifference(d, dCircle(p - vec2(.0, .0), .6));
    d = fOpUnion(d, dRect(p - vec2(.79 , 1.25), vec2(.2, 1.25)));
    return d;
}

float dCharE(vec2 p)
{
    float d = dCircle(p, 1.);
    d = fOpDifference(d, dCircle(p, .6));
    d = fOpDifference(d, dRect(p - vec2(.85 , -.2), vec2(.65, .2)));
    vec2 pp = p - vec2(.85 , -.4);
    pR(pp, PI / 7);
    d = fOpDifference(d, dRect(pp, vec2(.65, .25)));
    d = fOpUnion(d, dRect(p - vec2(.01, .1), vec2(.9, .1)));
    return d;
}

float dCharF(vec2 p)
{
    float d = dCircle(p - vec2(-.2, 1.5), .8);
    d = fOpDifference(d, dCircle(p - vec2(-.19, 1.45), .414));
    d = fOpDifference(d, dRect(p - vec2(.3, .8), vec2(.9, .75)));
    d = fOpUnion(d, dRect(p - vec2(-.8 , .2), vec2(.2, 1.2)));
    d = fOpUnion(d, dRect(p - vec2(-.2 , .5), vec2(.5, .2)));
    return d;

}

float dCharG(vec2 p)
{
    float d = dCircle(p - vec2(.0, -1.5), 1.);
    d = fOpDifference(d, dCircle(p - vec2(.0, -1.5), .6));
    d = fOpDifference(d, dRect(p - vec2(-.5, -.8), vec2(1.9, .75)));
    d = fOpUnion(d, dCircle(p - vec2(.0, .0), 1.));
    d = fOpDifference(d, dCircle(p - vec2(.0, .0), .6));
    d = fOpUnion(d, dRect(p - vec2(.8 , -.8), vec2(.2, .8)));
    return d;
}

float dCharH(vec2 p)
{
    float d = dCircle(p - vec2(.0, .0), 1.);
    d = fOpDifference(d, dCircle(p - vec2(.0, .0), .6));
    d = fOpDifference(d, dRect(p - vec2(-.5, -.75), vec2(1.9, .75)));
    d = fOpUnion(d, dRect(p - vec2(-.8 , .75), vec2(.2, 1.75)));
    d = fOpUnion(d, dRect(p - vec2(.8 , -.5), vec2(.2, .5)));
    return d;
}

float dCharI(vec2 p)
{
    float d = dRect(p - vec2(.1, .6), vec2(.2, 1.3));
    d = fOpDifference(d, dRect(p - vec2(.1, 1.15), vec2(.5, .45)));
    d = fOpUnion(d, dHalfCircle(p - vec2(-.1, .6), .4));
    vec2 pp = p - vec2(.3, -.6);
    pR(pp, PI);
    d = fOpUnion(d, dHalfCircle(pp, .4));
    return d;
}

float dCharJ(vec2 p)
{
    float d = dCircle(p - vec2(.0, -1.5), 1.);
    d = fOpDifference(d, dCircle(p - vec2(.0, -1.5), .6));
    d = fOpDifference(d, dRect(p - vec2(-.5, -.8), vec2(1.9, .75)));
    d = fOpUnion(d, dRect(p - vec2(.8, .2), vec2(.2, 1.8)));
    d = fOpDifference(d, dRect(p - vec2(.5, 1.3), vec2(1., .3)));
    return d;
}

float dCharK(vec2 p)
{
    vec2 pp = p - vec2(.15, .8);
    pR(pp, PI / 3.5);
    float d = dRect(pp, vec2(.2, 1.2));
    pp = p - vec2(.2, -.6);
    pR(pp, -PI / 3.7);
    d = fOpUnion(d, dRect(pp, vec2(.2, 1.2)));
    d = fOpDifference(d, dRect(p - vec2(.0, -1.4), vec2(1.5, .4)));
    d = fOpDifference(d, dRect(p - vec2(.0, 1.4), vec2(1.5, .4)));
    d = fOpUnion(d, dRect(p - vec2(-.75, .75), vec2(.2, 1.75)));
    return d;
}


float dCharL(vec2 p)
{
    float d = dRect(p - vec2(.0, 0.75), vec2(.2, 1.4));
    d = fOpUnion(d, dHalfCircle(p - vec2(-.2, 2.1), .4));
    vec2 pp = p;
    pR(pp, PI);
    d = fOpUnion(d, dHalfCircle(pp - vec2(-.2, .6), .4));
    return d;
}

float dCharM(vec2 p)
{
    float d = dCircle(p - vec2(-.35, .3), 0.7);
    d = fOpUnion(d, dCircle(p - vec2(.35, .3), 0.7));
    d = fOpDifference(d, dCircle(p - vec2(-.4, .5), .2));
    d = fOpDifference(d, dCircle(p - vec2(.4, .5), .2));
    d = fOpDifference(d, dRect(p - vec2(.25, -.2), vec2(2.9, .75)));
    d = fOpUnion(d, dRect(p - vec2(-.8 , -.225), vec2(.2, .775)));
    d = fOpUnion(d, dRect(p - vec2(.0, -.225), vec2(.2, .775)));
    d = fOpUnion(d, dRect(p - vec2(0.8, -.225), vec2(.2, .775)));
    return d;
}

float dCharN(vec2 p)
{
    float d = dCircle(p - vec2(.0, .0), 1.);
    d = fOpDifference(d, dCircle(p - vec2(.0, .0), .6));
    d = fOpDifference(d, dRect(p - vec2(.25, -.65), vec2(2.9, .75)));
    d = fOpUnion(d, dRect(p - vec2(-.8 , -.45), vec2(.2, .55)));
    d = fOpUnion(d, dRect(p - vec2(.8, -.45), vec2(.2, .55)));
    return d;
}

float dCharO(vec2 p)
{
    float d = dCircle(p, 1.);
    d = fOpDifference(d, dCircle(p, .6));
    return d;
}

float dCharP(vec2 p)
{
    float d = dCircle(p - vec2(.0, .0), 1.);
    d = fOpDifference(d, dCircle(p - vec2(.0, .0), .6));
    d = fOpUnion(d, dRect(p - vec2(-.8 , -1.15), vec2(.2, 1.1)));
    return d;
}

float dCharQ(vec2 p)
{
    float d = dCircle(p - vec2(.0, .0), 1.);
    d = fOpDifference(d, dCircle(p - vec2(.0, .0), .6));
    d = fOpUnion(d, dRect(p - vec2(.8 , -1.15), vec2(.2, 1.1)));
    return d;
}

float dCharR(vec2 p)
{
    float d = dCircle(p - vec2(.2, .0), 1.);
    d = fOpDifference(d, dCircle(p - vec2(.2, .0), .6));
    d = fOpDifference(d, dRect(p - vec2(.45, -.65), vec2(.9, .75)));
    vec2 pp = p - vec2(1.05 , .3);
    pR(pp, -PI / 7);
    d = fOpDifference(d, dRect(pp, vec2(.65, .4)));
    d = fOpUnion(d, dRect(p - vec2(-.6 , .0), vec2(.2, 1.)));
    return d;
}

float dCharS(vec2 p)
{
    float dTop = dCircle(p - vec2(.2, .45), .6);
    dTop = fOpDifference(dTop, dCircle(p - vec2(.2, .45), .25));
    vec2 pp = p - vec2(1.35, .6);
    pR(pp, -PI / 5);
    dTop = fOpDifference(dTop, dRect(pp, vec2(1.2, .5)));

    float dBottom = dCircle(p - vec2(-.0, -.4), .7);
    dBottom = fOpDifference(dBottom, dCircle(p - vec2(-.0, -.4), .35));
    pp = p - vec2(-.9 , -.4);
    pR(pp, -PI / 5);
    dBottom = fOpDifference(dBottom, dRect(pp, vec2(.9, .4)));

    float d = fOpUnion(dTop, dBottom);
    return d;
}

float dCharT(vec2 p)
{
    float d = dRect(p - vec2(.0, .75), vec2(.2, 1.4));
    d = fOpUnion(d, dRect(p - vec2(.0, 1.25), vec2(0.8, .2)));
    vec2 pp = p;
    pR(pp, PI);
    d = fOpUnion(d, dHalfCircle(pp - vec2(-.2, .6), .4));
    return d;
}

float dCharU(vec2 p)
{
    float d = dCircle(p - vec2(.0, .0), 1.);
    d = fOpDifference(d, dCircle(p - vec2(.0, .0), .6));
    d = fOpDifference(d, dRect(p - vec2(.25, .65), vec2(2.9, .7)));
    d = fOpUnion(d, dRect(p - vec2(-.8, .47), vec2(.2, .53)));
    d = fOpUnion(d, dRect(p - vec2(.8 , .47), vec2(.2, .53)));
    return d;
}

float dCharV(vec2 p)
{
    vec2 pp = p - vec2(.2, -.2);
    pR(pp, PI / 7);
    float d = dRect(pp, vec2(.2, 1.5));
    pp = p - vec2(-.2, -.2);
    pR(pp, -PI / 7);
    d = fOpUnion(d, dRect(pp, vec2(.2, 1.5)));
    d = fOpDifference(d, dRect(pp - vec2(-.45), vec2(.25, 1.2)));
    pR(pp, PI / 3.5);
    d = fOpDifference(d, dRect(pp - vec2(.81, -.6), vec2(.25, 1.2)));
    d = fOpDifference(d, dRect(p - vec2(.0, -1.4), vec2(1.5, .4)));
    d = fOpDifference(d, dRect(p - vec2(.0, 1.4), vec2(1.5, .4)));
    return d;
}

float dCharW(vec2 p)
{
    float d = dCharV(p - vec2(-.3, 0));
    d = fOpUnion(d, dCharV(p - vec2(.3, .0)));
    d = fOpDifference(d, dRect(p - vec2(.0, 1.4), vec2(1.5, 1.)));
    return d;
}
float dCharX(vec2 p)
{
    vec2 pp = p;
    pR(pp, PI / 5);
    float d = dRect(pp, vec2(.2, 1.5));
    pp = p;
    pR(pp, -PI / 5);
    d = fOpUnion(d, dRect(pp, vec2(.2, 1.5)));
    d = fOpDifference(d, dRect(p - vec2(.0, -1.4), vec2(1.25, .4)));
    d = fOpDifference(d, dRect(p - vec2(.0, 1.4), vec2(1.25, .4)));
    return d;
}

float dCharY(vec2 p)
{
    vec2 pp = p - vec2(-.15, -.2);
    pR(pp, -PI / 7);
    float d = dRect(pp, vec2(.2, 1.5));
    pp = p - vec2(.3, -.9);
    pR(pp, PI / 8);
    d = fOpDifference(d, dRect(pp - vec2(.4, -.7), vec2(.55, 1.2)));
    d = fOpUnion(d, dRect(pp - vec2(-.3, .25), vec2(.2, 2.3)));
    d = fOpDifference(d, dRect(p - vec2(.0, 1.4), vec2(1.5, .4)));
    d = fOpDifference(d, dRect(p - vec2(.0, FONT_DESCENDERS-0.4), vec2(1.5, .4)));
    return d;
}

float dCharZ(vec2 p)
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
    return d;
}

float dCharExclamation(vec2 p)
{
    float d = dRect(p - vec2(.0, .75), vec2(.2, 1.75));
    d = fOpDifference(d, dRect(p - vec2(-0, -.2), vec2(.5, .3)));
    return d;
}

float dCharColon(vec2 p)
{
    float d = dRect(p - vec2(.0, .0), vec2(.2, .75));
    d = fOpDifference(d, dRect(p - vec2(.0, .0), vec2(.5, .3)));
    return d;
}

float dCharDash(vec2 p)
{
    float d = dRect(p - vec2(.0, .0), vec2(.65, .2));
    d = fOpDifference(d, dRect(p - vec2(.0, .75), vec2(.5, .3)));
    return d;
}

float dCharUnderscore(vec2 p)
{
    float d = dRect(p - vec2(.0, -.75), vec2(.85, .2));
    d = fOpDifference(d, dRect(p - vec2(.0, .75), vec2(.5, .3)));
    return d;
}

float dCharSpace(vec2 p)
{
    return INF;
}

float dCharBox(vec2 p)
{
    float d = dRect(p, vec2(.85, 1.));
    return d;
}
