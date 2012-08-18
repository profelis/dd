package deep.dd.texture.atlas.animation;

import deep.dd.texture.atlas.AtlasTexture2D;

class AnimatorBase
{
    public var atlas:AtlasTexture2D;

    // private constructor
    function new()
    {

    }

    public function draw(time:Float):Void
    {

    }

    public function copy():AnimatorBase
    {
        throw "not implemented";
        return null;
    }

    public function dispose():Void
    {
        atlas = null;
    }
}
