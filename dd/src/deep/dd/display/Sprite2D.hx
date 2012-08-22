package deep.dd.display;

import deep.dd.texture.atlas.AtlasTexture2D;
import deep.dd.utils.Frame;
import deep.dd.material.Material;
import deep.dd.animation.AnimatorBase;
import flash.geom.Matrix3D;
import deep.dd.camera.Camera2D;
import flash.display3D.Context3D;
import deep.dd.texture.Texture2D;
import deep.dd.material.sprite2d.Sprite2DMaterial;
import deep.dd.geometry.Geometry;
import deep.dd.utils.FastHaxe;

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

    public var invalidateDrawTransform:Bool;
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
            Reflect.setField(this, "animator", null);
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

    /**
    * @private setter
    */
    public var textureFrame(default, default):Frame;

    override public function drawStep(camera:Camera2D):Void
    {
        if (texture != null)
        {
            var f = texture.frame;
            if (animator != null)
            {
                animator.draw(scene.time);
                f = animator.textureFrame;
            }

            if (textureFrame != f)
            {
                invalidateDrawTransform = true;
                textureFrame = f;
                _width = textureFrame.width;
                _height = textureFrame.height;
            }
            else if (invalidateWorldTransform || invalidateTransform)
            {
                invalidateDrawTransform = true;
            }
        }

        super.drawStep(camera);
    }


    override public function draw(camera:Camera2D):Void
    {
        if (texture != null)
        {
            if (invalidateDrawTransform) updateDrawTransform();

            super.draw(camera);
        }
    }

    inline public function updateDrawTransform()
    {
        drawTransform.rawData = textureFrame.drawMatrix.rawData;
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
            textureFrame = texture.frame;
            _width = texture.width;
            _height = texture.height;

            if (FastHaxe.is(texture, AtlasTexture2D) && animator != null) animator.atlas = flash.Lib.as(texture, AtlasTexture2D);

            invalidateDrawTransform = true;
        }

        return tex;
    }

    function set_animator(v)
    {
        //if (animator != null) animator.atlas = null;

        animator = v;
		
		if (animator != null)
		{
			if (animator.atlas != null)
			{
				texture = animator.atlas;
			}
			else if (FastHaxe.is(texture, AtlasTexture2D))
			{
				animator.atlas = flash.Lib.as(texture, AtlasTexture2D);
			}
		}

        return animator;
    }

}
