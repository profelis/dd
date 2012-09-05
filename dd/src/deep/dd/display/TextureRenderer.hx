package deep.dd.display;

import mt.m3d.Color;
import flash.geom.Vector3D;
import flash.display3D.Context3D;
import deep.dd.camera.Camera2D;
import deep.dd.texture.Texture2D;

class TextureRenderer extends Sprite2D
{
    public function new(texture:Texture2D = null)
    {
        super();

        cam = new Camera2D();

        if (texture != null) this.texture = texture;

        bgColor = new Color(0, 0, 0, 0);
    }

    var cam:Camera2D;

    override function set_texture(t:Texture2D)
    {
        super.set_texture(t);

        if (texture != null)
        {
            cam.resize(texture.textureWidth, texture.textureHeight);
        }
        return texture;
    }

    public var bgColor(default, set_bgColor):Color;

    function set_bgColor(c:Color):Color
    {
        return bgColor = c != null ? c : new Color(0, 0, 0, 0);
    }

    override public function drawStep(camera:Camera2D):Void
    {
        if (texture != null)
        {
            if (texture.needUpdate) texture.update();

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

        if (invalidateTransform) updateTransform();
        if (invalidateWorldTransform) updateWorldTransform();
        if (invalidateColorTransform) updateWorldColor();

        //
        ctx.setRenderToTexture(texture.texture, false, world.antialiasing);
        ctx.clear(bgColor.r, bgColor.g, bgColor.b, bgColor.a);

        cam.x = worldTransform.rawData[12];
        cam.y = worldTransform.rawData[13];
        if (cam.needUpdate) cam.update();

        for (i in children) if (i.visible) i.drawStep(cam);

        ctx.setRenderToBackBuffer();
        //
        super.draw(camera);
    }

    override public function dispose():Void
    {
        super.dispose();

        cam.dispose();
        cam = null;
    }


}
