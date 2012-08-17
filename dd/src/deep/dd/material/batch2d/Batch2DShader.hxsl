var input : {
    pos : Float3,
    uv: Float2,
    index:Float
};

var tuv:Float2;
var cTrans:Float4;

function vertex(mpos:M44<5>, mproj:Matrix, cTransArr:Float4<5>)
{
    out = pos.xyzw * mpos[index*4] * mproj;

    tuv = uv;
    cTrans = cTransArr[index];
}

function fragment(tex:Texture, region:Float4)
{
    var t = tuv * region.zw + region.xy;
    out = texture(tex, t) * cTrans + [0, 0, 0, 0.1];
}

/*
function texture(t:Texture, uv:Float2)
{
    return t.get(uv);
}
*/