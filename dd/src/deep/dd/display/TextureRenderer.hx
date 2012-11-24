package deep.dd.display;

import flash.geom.Matrix3D;
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
            cam.resize(Math.ceil(texture.width), Math.ceil(texture.height));
        }
        return texture;
    }

    public var bgColor(default, set_bgColor):Color;

    function set_bgColor(c:Color):Color
    {
        return bgColor = c != null ? c : new Color(0, 0, 0, 0);
    }

    override public function updateStep()
    {
        renderToTexture = true;
        onWorldTransformChange.dispatch(this);

        super.updateStep();

        renderToTexture = false;
        onWorldTransformChange.dispatch(this);

        cam.resize(Std.int(texture.width), Std.int(texture.height));
        if (cam.needUpdate) cam.update();
    }

    static var EMPTY:Matrix3D = new Matrix3D();

    override function get_worldTransform()
    {
        if (renderToTexture)
            return EMPTY;

        return super.get_worldTransform();
    }

    var renderToTexture:Bool = false;

    override public function drawStep(camera:Camera2D):Void
    {
        ctx.setRenderToTexture(texture.texture, false, world.antialiasing);
        ctx.clear(bgColor.r, bgColor.g, bgColor.b, bgColor.a);

        for (i in children) if (i.visible) i.drawStep(cam);

        ctx.setRenderToBackBuffer();

        updateDrawTransform();
        if (material != null) material.draw(this, camera);
    }

    override public function dispose():Void
    {
        super.dispose();

        cam.dispose();
        cam = null;
    }
}
