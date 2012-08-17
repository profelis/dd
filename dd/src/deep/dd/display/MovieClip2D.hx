package deep.dd.display;

import deep.dd.texture.atlas.animation.Animator;
import deep.dd.texture.atlas.animation.AnimatorBase;
import deep.dd.camera.Camera2D;
import deep.dd.geometry.Geometry;

class MovieClip2D extends Sprite2D
{
    var anim:Animator;

    public function new()
    {
        super();
        animator = anim = new Animator();
    }

    public var fps(default, set_fps):Float;

    function set_fps(v)
    {
        return anim.fps = fps = v;
    }
}
