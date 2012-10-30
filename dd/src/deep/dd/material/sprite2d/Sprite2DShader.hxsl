var input : {
    pos : Float2,
    uv: Float2
};

var tuv:Float2;

function vertex(mpos:M44, mproj:M44, region:Float4)
{
    out = pos.xyzw * mpos * mproj;
    tuv = uv * region.zw + region.xy;
}

function fragment(tex:Texture, cTrans:Float4)
{
    out = texture(tex, tuv) * cTrans;
}

/*
function texture(t:Texture, uv:Float2)
{
    return t.get(uv);
}
*/