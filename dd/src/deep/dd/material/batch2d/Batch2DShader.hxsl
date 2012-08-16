var input : {
    pos : Float3,
    uv: Float2,
    index:FLoat
};

var tuv:Float2;
var cTrans:Float4;

function vertex(mpos:Array<M44>, mproj:M44, cTransArr:Array<Float4>, regions:Array<Float4>)
{
    out = pos.xyzw * mpos[index.x] * mproj;
    var region = regions[index.z];
    tuv = uv * region.zw + region.xy;
    cTrans = cTransArr[index.y];
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