package deep.dd.display;

import flash.display.BitmapData;
import flash.geom.Vector3D;
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

class CenteredSprite2D extends Sprite2D
{
    public function new(material:Material = null)
    {
        super(material);
    }

    override function createGeometry()
    {
        geometry = Geometry.createTextured(_displayWidth = 1, _displayHeight = 1, 1, 1, -0.5, -0.5);
    }
}

class Sprite2D extends DisplayNode2D
{
    public function new(material:Material = null)
    {
        drawTransform = new Matrix3D();

        super(material != null ? material : new Sprite2DMaterial());
    }

    override function createGeometry()
    {
        geometry = Geometry.createTextured(_displayWidth = 1, _displayHeight = 1);
    }

    public var animator(default, set_animator):AnimatorBase;

    /**
    * @private
    */
    public var invalidateDrawTransform:Bool;
    /**
    * @private
    */
    public var drawTransform(default, null):Matrix3D;

    public var texture(default, set_texture):Texture2D;

    public var textureHitTest:Bool = false;

    override function displayHitTest(p:Vector3D, mouseHit = true)
    {
        if (super.displayHitTest(p))
        {
            if (textureHitTest && texture != null && FastHaxe.is(texture, BitmapTexture2D))
            {
                var b:BitmapData = flash.Lib.as(texture, BitmapTexture2D).bitmapData;
                if (b == null)
                {
                    #if debug trace("bitmap is null"); #end
                    return true;
                }

                try
                {
                    b.getPixel(0, 0);
                }
                catch (e:Dynamic)
                {
                    #if debug trace("bitmap is disposed"); #end
                    return true;
                }
                if (!b.transparent) return true;

                p = globalToLocal(p);
                var x = p.x;
                var y = p.y;

                var border = textureFrame.border;
                if (border != null)
                {
                    x -= border.x;
                    y -= border.y;
                }
                if (x < 0 || y < 0 || x > textureFrame.frameWidth || y > textureFrame.frameHeight) return false;

                var region = textureFrame.region;
                x *= region.z;
                y *= region.w;
                x += region.x;
                y += region.y;

                if ((texture.options & Texture2DOptions.REPEAT_NORMAL) > 0)
                {
                    x %= b.width;
                    y %= b.height;
                }
                x *= texture.textureWidth / b.width;
                y *= texture.textureHeight / b.height;

                return b.rect.contains(x, y) && (b.getPixel32(Std.int(x), Std.int(y)) >>> 24) > 0;
            }

            return true;
        }

        return false;
    }

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
        if (this.ctx != ctx && texture != null) texture.init(ctx);
        super.init(ctx);
    }

    /**
    * @private setter
    */
    public var textureFrame(default, default):Frame;

    override public function updateStep()
    {
        if (texture != null)
        {
            if (texture.needUpdate) texture.update();

            var f = texture.frame;
            if (animator != null)
            {
                animator.update(scene.time);
                f = animator.textureFrame;
            }

            if (textureFrame != f)
            {
                invalidateBounds = true;
                invalidateDrawTransform = true;
                invalidateDisplayBounds = true;
                textureFrame = f;
                _displayWidth = textureFrame.width;
                _displayHeight = textureFrame.height;
            }
        }

        super.updateStep();

        invalidateDrawTransform = invalidateDrawTransform || invalidateWorldTransform;
        if (invalidateDrawTransform) updateDrawTransform();
    }

    override function get_worldTransform():Matrix3D
    {
        invalidateDrawTransform = invalidateDrawTransform || invalidateWorldTransform;

        return super.get_worldTransform();
    }

    inline public function updateDrawTransform()
    {
        drawTransform.rawData = worldTransform.rawData;
        textureFrame.applyFrame(drawTransform);
        //drawTransform.rawData = textureFrame.drawMatrix.rawData;

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
        invalidateBounds = true;
        invalidateDisplayBounds = true;

        if (texture != null)
        {
            Reflect.setField(texture, "useCount", texture.useCount + 1);
            if (ctx != null) texture.init(ctx);
            textureFrame = texture.frame;
            _displayWidth = texture.width;
            _displayHeight = texture.height;

            if (FastHaxe.is(texture, AtlasTexture2D) && animator != null) animator.atlas = flash.Lib.as(texture, AtlasTexture2D);

            invalidateDrawTransform = true;
        }
        else
        {
            _displayWidth = 0;
            _displayHeight = 0;
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
                texture = animator.atlas;
			else if (FastHaxe.is(texture, AtlasTexture2D))
				animator.atlas = flash.Lib.as(texture, AtlasTexture2D);
		}

        return animator;
    }

}
