package deep.dd.display;

import flash.geom.Rectangle;
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
import deep.dd.material.Sprite2DMaterial;
import deep.dd.geometry.Geometry;
import deep.dd.utils.FastHaxe;

class CenteredSprite2D extends Sprite2D
{
    public function new(material:Sprite2DMaterial = null)
    {
        super(material);
    }

    override function createGeometry()
    {
        geometry = Geometry.createTextured(_displayWidth = 1, _displayHeight = 1, 1, 1, -0.5, -0.5);
    }
}

class Sprite2D extends BaseSprite2D<Sprite2DShader> {
	
	public function new(material:Sprite2DMaterial = null)
    {
        super(material != null ? material : new Sprite2DMaterial());
    }
}

class BaseSprite2D<T:hxsl.Shader> extends DisplayNode2D<T>
{
    public function new(material:Material<T> = null)
    {
        drawTransform = new Matrix3D();

        super(material);
    }

    override function createGeometry()
    {
        geometry = Geometry.createTextured(_displayWidth = 1, _displayHeight = 1);
    }

    public var animator(default, set_animator):AnimatorBase;

    var invalidateDrawTransform:Bool;
    public var drawTransform(default, null):Matrix3D;

    public var texture(default, set_texture):Texture2D;

    public var textureHitTest:Bool = false;

    override function displayHitTest(p:Vector3D, mouseHit = true)
    {
        var d = displayBounds;
        if (d.isEmpty()) return false;

        p = globalToLocal(p);
        if (!d.contains(p.x, p.y)) return false;

        if (mouseHit)
        {
            mouseX = p.x;
            mouseY = p.y;
        }
		
		var t = texture;
		//if (FastHaxe.is(t, SubTexture2D)) t = cast(t, SubTexture2D).baseTexture; TODO:

        if (textureHitTest && t != null && FastHaxe.is(t, BitmapTexture2D))
        {
            var b:BitmapData = flash.Lib.as(t, BitmapTexture2D).bitmapData;
            if (b == null)
            {
                #if debug trace("textureHitTest error. Bitmap is null"); #end
                return true;
            }

            try
            {
                b.width;
            }
            catch (e:Dynamic)
            {
                #if debug trace("textureHitTest error. Bitmap is disposed"); #end
                return true;
            }
            if (!b.transparent) return true;

            var x = p.x - d.x;
            var y = p.y - d.y;

            var border = textureFrame.border;
            if (border != null)
            {
                x -= border.x;
                y -= border.y;
            }
            if (x < 0 || y < 0 || x > textureFrame.frameWidth || y > textureFrame.frameHeight) return false;

            var region = textureFrame.region;
            x = x * region.z + region.x;
            y = y * region.w + region.y;

            if (texture.wrap)
            {
                x %= b.width;
                y %= b.height;
            }
            x *= t.textureWidth / b.width;
            y *= t.textureHeight / b.height;

            return (b.getPixel32(Std.int(x), Std.int(y)) >>> 24) > 0;
        }

        return true;
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
        textureFrame = null;
        drawTransform = null;
    }

    override public function init(ctx:Context3D):Void
    {
        if (texture != null) texture.init(ctx);
        super.init(ctx);
    }

    public var textureFrame(default, null):Frame;

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

        if (invalidateDrawTransform || invalidateWorldTransform) updateDrawTransform();
    }

    override function get_worldTransform():Matrix3D
    {
        invalidateDrawTransform = invalidateDrawTransform || invalidateWorldTransform;

        return super.get_worldTransform();
    }

    inline public function updateDrawTransform()
    {
        drawTransform.rawData = worldTransform.rawData;
        if (textureFrame != null) textureFrame.applyFrame(drawTransform);

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
        }
        else
        {
            textureFrame = null;
            _displayWidth = 0;
            _displayHeight = 0;
        }

        invalidateDrawTransform = true;

        return tex;
    }

    function set_animator(v)
    {
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

    override function get_displayBounds():Rectangle
    {
        if (invalidateDisplayBounds)
        {
            displayBounds.setTo(0, 0, _displayWidth, _displayHeight);

            var g = geometry;
            if (g != null && !g.standart)
            {
                var dx = g.offsetX / g.width;
                var dy = g.offsetY / g.height;
                var t = texture;
                if (t == null || t.frame == null)
                {
                    dx *= _displayWidth;
                    dy *= _displayHeight;
                }
                else
                {
                    dx *= t.frame.frameWidth;
                    dy *= t.frame.frameHeight;
                }
                displayBounds.x += dx;
                displayBounds.y += dy;
                displayBounds.width *= g.width;
                displayBounds.height *= g.height;
            }

            invalidateDisplayBounds = false;
        }

        return displayBounds;
    }

}
