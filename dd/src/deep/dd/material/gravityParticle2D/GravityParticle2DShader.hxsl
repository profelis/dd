var input:
{
    pos:Float3,
    uv:Float2,

    startPos:Float3,
    velocity:Float3,

    color:Float4,
    dColor:Float4,

    scale:Float2, // startScale, dScale

    life:Float2,  // startTime, life
};

var tuv:Float2;
var cTrans:Float4;

function vertex(mproj:Matrix, mpos:Matrix, time:Float, gravity:Float3, region:Float4, texSize:Float2)
{
    var k = frc((time - life.x) / life.y);   // k = [0,1]
    var t = k * life.y;                      // t = [0, life]

    var v = gravity * t + velocity;          // velocity

    var vertex = pos.xyzw;
    vertex.xyz *= scale.x + scale.y * k;     // vertex *= scale

    var dt = startPos;
    dt.xy /= texSize.xy;
    vertex.xyz += dt + v * t;                // vertex += startPos + velocity * t

    out = vertex * mpos * mproj;             // out

    cTrans = color + dColor * k;             // tcolor = [startColor, endColor]
    tuv = uv * region.zw + region.xy;
}

function fragment(tex:Texture)
{
    out = texture(tex, tuv) * cTrans;
}

/*
function texture(t:Texture, uv:Float2)
{
    return t.get(uv);
}
*/