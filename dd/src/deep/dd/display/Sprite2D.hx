package deep.dd.display;

import deep.dd.camera.Camera2D;
import flash.display3D.Context3D;
import deep.dd.texture.Texture2D;
import deep.dd.material.sprite2d.Sprite2DMaterial;
import deep.dd.geometry.Geometry;

class Sprite2D extends DisplayNode2D
{
    public function new(geometry:Geometry = null)
    {
        super(geometry, new Sprite2DMaterial());
    }

    override public function init(ctx:Context3D):Void
    {
        if (this.ctx != ctx && texture != null)
        {
            texture.init(ctx);
        }
        super.init(ctx);
    }

    override public function draw(camera:Camera2D):Void
    {
        if (texture != null)
        {
            if (texture.needUpdate) texture.update();
            super.draw(camera);
        }
    }
	
	override public function dispose():Void 
	{
		super.dispose();

		if (texture != null)
        {
            texture.useCount --;
            texture.dispose();
            Reflect.setField(this, "texture", null);
        }
	}

    public var texture(default, set_texture):Texture2D;

    function set_texture(tex:Texture2D):Texture2D
    {
        if (tex == texture) return tex;

        if (texture != null) texture.useCount --;
        texture = tex;
        if (texture != null)
        {
            texture.useCount ++;
            if (ctx != null) texture.init(ctx);
            if (geometry != null) geometry.resize(texture.bw, texture.bh);
        }

        return tex;
    }

    override function set_geometry(g:Geometry):Geometry
    {
        if (g == geometry) return g;

        #if debug
        if (!g.textured) throw "geometry.textured != true";
        #end

        super.set_geometry(g);
        if (geometry != null && texture != null) geometry.resize(texture.bw, texture.bh);

        return geometry;
    }
}
