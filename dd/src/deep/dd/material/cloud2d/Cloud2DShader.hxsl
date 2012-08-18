var input : {
    pos : Float3,
    uv: Float2,
    color:Float4
};

var tuv:Float2;
var cTrans:Float4;

function vertex(mproj:Matrix)
{
    out = pos * mproj;
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