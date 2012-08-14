var input : {
    pos : Float3,
    uv: Float2
};

var tuv:Float2;

function vertex(mpos:M44, mproj:M44, region:Float4)
{
    out = pos.xyzw * mpos * mproj;
    var t = uv;
    t.xy *= region.zw;
    t.xy += region.xy;
    tuv = t;
}

function fragment(tex:Texture)
{
    out = texture(tex, tuv);
}