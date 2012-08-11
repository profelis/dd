package deep.hxd.display;

import deep.hxd.camera.Camera2D;
import flash.display3D.Context3D;
import deep.hxd.texture.Texture2D;
import deep.hxd.material.Sprite2DMaterial;
import deep.hxd.geometry.Geometry;

class Sprite2D extends DisplayNode2D
{
    public function new(geometry:Geometry = null)
    {
        super(geometry, new Sprite2DMaterial());
    }

    override public function init(ctx:Context3D):Void
    {
        super.init(ctx);
        if (texture != null) texture.init(ctx);
    }

    override public function draw(camera:Camera2D):Void
    {
        if (texture != null)
        {
            super.draw(camera);
        }
    }

    public var texture(default, set_texture):Texture2D;

    function set_texture(tex:Texture2D):Texture2D
    {
        texture = tex;
        if (texture != null)
        {
            if (ctx != null) texture.init(ctx);
            if (geometry != null) geometry.resize(texture.bw, texture.bh);
        }

        return tex;
    }

    override function set_geometry(g:Geometry):Geometry
    {
        super.set_geometry(g);
        if (geometry != null && texture != null) geometry.resize(texture.bw, texture.bh);

        return geometry;
    }
}
