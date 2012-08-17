var input : {
    pos : Float3,
    uv: Float2,
    index:Float
};

var tuv:Float2;
var cTrans:Float4;

function vertex(mpos:M44<24>, mproj:Matrix, cTransArr:Float4<24>)
{
    // http://code.google.com/p/hxformat/issues/detail?id=28#c8
    var i = pos.xyzw;
    i.x = index.x * 4;
    out = pos.xyzw * mpos[i.x] * mproj;
    tuv = uv;
    cTrans = cTransArr[index.x];
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