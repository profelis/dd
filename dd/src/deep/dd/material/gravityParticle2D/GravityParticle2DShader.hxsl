var input : {
    startPos : Float3,
    uv: Float2,

    velocity : Float3,

    startColor:Float4,
    dColor:Float4,

    scale:Float2,

    startTime:Float
};

var tuv:Float2;
var cTrans:Float4;

function vertex(mproj:Matrix)
{
    out = pos.xyzw * mproj;
    tuv = uv;
    cTrans = color;
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