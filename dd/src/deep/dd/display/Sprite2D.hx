package deep.dd.display;

import deep.dd.material.Material;
import deep.dd.texture.atlas.animation.AnimatorBase;
import flash.geom.Matrix3D;
import deep.dd.camera.Camera2D;
import flash.display3D.Context3D;
import deep.dd.texture.Texture2D;
import deep.dd.material.sprite2d.Sprite2DMaterial;
import deep.dd.geometry.Geometry;

class Sprite2D extends DisplayNode2D
{
    public function new(material:Material = null)
    {
        drawTransform = new Matrix3D();

        super(material != null ? material : new Sprite2DMaterial());
    }

    override function createGeometry()
    {
        setGeometry(Geometry.createTextured(_width = 1, _height = 1));
    }

    public var animator(default, set_animator):AnimatorBase;

    var invalidateDrawTransform:Bool;
    public var drawTransform(default, null):Matrix3D;

    public var texture(default, set_texture):Texture2D;

    override public function dispose():Void
    {
        super.dispose();

        if (texture != null)
        {
            Reflect.setField(texture, "useCount", texture.useCount - 1);
            texture.dispose();
            Reflect.setField(this, "texture", null);
        }
        if (animator != null)
        {
            animator.dispose();
            animator = null;
        }
    }

    override public function init(ctx:Context3D):Void
    {
        if (this.ctx != ctx && texture != null)
        {
            texture.init(ctx);
        }
        super.init(ctx);
    }

    override public function drawStep(camera:Camera2D):Void
    {
        if (texture != null)
        {
            if (animator != null) animator.draw(scene.time);

            if (texture.needUpdate)
            {
                texture.update();
                invalidateDrawTransform = true;
                _width = texture.width;
                _height = texture.height;
            }
        }

        if (invalidateWorldTransform || invalidateTransform) invalidateDrawTransform = true;

        super.drawStep(camera);
    }


    override public function draw(camera:Camera2D):Void
    {
        if (texture == null) return;

        if (invalidateDrawTransform) updateDrawTransform();

        super.draw(camera);
    }

    public function updateDrawTransform()
    {
        drawTransform.rawData = texture.drawMatrix.rawData;
        drawTransform.append(worldTransform);

        invalidateDrawTransform = false;
    }

    function set_texture(tex:Texture2D):Texture2D
    {
        if (tex == texture) return tex;

        if (texture != null)
        {
            Reflect.setField(texture, "useCount", texture.useCount - 1);
        }

        texture = tex;

        if (texture != null)
        {
            Reflect.setField(texture, "useCount", texture.useCount + 1);
            if (ctx != null) texture.init(ctx);
            _width = texture.width;
            _height = texture.height;

            invalidateDrawTransform = true;
        }

        return tex;
    }

    function set_animator(v)
    {
        if (animator != null) animator.sprite = null;

        animator = v;

        if (animator != null) animator.sprite = this;

        return animator;
    }

}
