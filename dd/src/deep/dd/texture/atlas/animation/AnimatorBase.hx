package deep.dd.texture.atlas.animation;

import deep.dd.display.Sprite2D;

class AnimatorBase
{
    public var sprite:Sprite2D;

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
        sprite = null;
    }
}
