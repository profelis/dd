var input : {
    pos : Float3,
    uv: Float2
};

var tuv:Float2;

function vertex(mpos:M44, mproj:M44)
{
    out = pos.xyzw * mpos * mproj;
    tuv = uv;
}

function fragment(tex:Texture, cTrans:Float4, region:Float4)
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