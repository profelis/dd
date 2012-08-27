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
var tcolor:Float4;

function vertex(mproj:Matrix, mpos:Matrix, time:Float, gravity:Float3, region:Float4)
{
    var k = frc((time - life.x) / life.y);
    var t = k * life.y;

    var v = gravity * t + velocity;

    var vertex = pos.xyzw;
    vertex.xyz *= scale.x + scale.y * k;
    vertex.xyz += startPos + v * t;
    out = vertex * mpos * mproj;

    tcolor = color + dColor * k;
    tuv = uv * region.zw + region.xy;
}

function fragment(tex:Texture)
{
    out = texture(tex, tuv) * tcolor;
}

/*
function texture(t:Texture, uv:Float2)
{
    return t.get(uv);
}
*/