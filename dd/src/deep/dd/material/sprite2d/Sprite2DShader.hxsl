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

function fragment(tex:Texture, region:Float4)
{
    var t = tuv;
    t.xy *= region.zw;
    t.xy += region.xy;
    out = texture(tex, t);
}