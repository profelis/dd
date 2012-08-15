package deep.dd.display;

import deep.dd.camera.Camera2D;
import deep.dd.geometry.Geometry;
import deep.dd.texture.atlas.animation.Animator;

class MovieClip2D extends Sprite2D
{
    public var animator(default, set_animator):Animator;

    public function new(animator:Animator, geometry:Geometry = null)
    {
        this.animator = animator;

        super(geometry);
    }

    function set_animator(v)
    {
        if (animator != null) animator.sprite = null;

        animator = v;

        if (animator != null) animator.sprite = this;

        return animator;
    }

    override public function draw(camera:Camera2D):Void
    {
        animator.draw(scene.time);

        super.draw(camera);
    }

    override public function dispose():Void
    {
        super.dispose();
        animator.dispose();
        animator = null;
    }

}
