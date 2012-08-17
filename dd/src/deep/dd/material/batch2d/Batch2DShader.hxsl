var input : {
    pos : Float3,
    uv: Float2,
    index:Float
};

var tuv:Float2;
var cTrans:Float4;

function vertex(cTransArr:Float4<24>, mpos:M44<24>, mproj:Matrix)
{
    var i = pos.xyzw;
    i.x = index*4;
    out = pos.xyzw * mpos[i.x] * mproj;

    tuv = uv;
    cTrans = cTransArr[index];
}

function fragment(tex:Texture, region:Float4)
{
    var t = tuv * region.zw + region.xy;
    out = texture(tex, t) * cTrans;
}

/*
function texture(t:Texture, uv:Float2)
{
    return t.get(uv);
}
*/