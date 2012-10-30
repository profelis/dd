var input:
{
    pos:Float2,
    uv:Float2,

    scale:Float2,  // startScale, dScale
    radialData:Float4,  // angle, angleSpeed, radius, dRadius

    color:Float4,
    dColor:Float4,

    life:Float2,  // startTime, life
};

var tuv:Float2;
var cTrans:Float4;

function vertex(mproj:Matrix, mpos:Matrix, time:Float, region:Float4, texSize:Float2, pcTrans:Float4)
{
    var k = frc((time - life.x) / life.y);   // k = [0,1]
    var t = k * life.y;                      // t = [0, life]

    var vertex = pos.xyzw;
    vertex.xyz *= scale.z + scale.w * k; // vertex *= scale

    var a = radialData.x + radialData.y * t; // angle
    var r = radialData.z + radialData.w * k; // radius
    var z = scale.x + scale.y * t;

    var pos = [r * cos(a), r * sin(a), z];   // radial position
    pos.xy /= texSize;

    vertex.xyz += pos;                       // vertex += pos

    out = vertex * mpos * mproj;             // out

    cTrans = pcTrans * (color + dColor * k); // cTrans = parentColor * [startColor, endColor]
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