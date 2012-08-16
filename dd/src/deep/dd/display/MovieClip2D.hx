package deep.dd.display;

import deep.dd.texture.atlas.animation.Animator;
import deep.dd.texture.atlas.animation.AnimatorBase;
import deep.dd.camera.Camera2D;
import deep.dd.geometry.Geometry;

class MovieClip2D extends Sprite2D
{
    var anim:Animator;

    public function new(geometry:Geometry = null)
    {
        super(geometry, anim = new Animator());
    }

    public var fps(default, set_fps):Int;

    function set_fps(v)
    {
        return anim.fps = fps = v;
    }
}
