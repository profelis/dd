package deep.hxd.display;

import deep.hxd.geometry.Geometry;
import deep.hxd.material.Material;
import deep.hxd.camera.Camera2D;
import flash.display3D.Context3D;
import format.hxsl.Shader;
import mt.m3d.Polygon;

class DisplayNode2D extends Node2D
{
    public function new(geometry:Geometry = null, material:Material = null)
    {
        super();
        this.geometry = geometry;
        this.material = material;
    }

    public var geometry(default, set_geometry):Geometry;

    public var material(default, set_material):Material;

    override public function init(ctx:Context3D):Void
    {
        super.init(ctx);

        if (material != null) material.init(ctx);
        if (geometry != null) geometry.init(ctx);
    }

    override public function draw(camera:Camera2D):Void
    {
        if (material != null && geometry != null)
        {
            geometry.draw();
            material.draw(this, camera);
        }

        super.draw(camera);
    }
	
	override public function dispose():Void 
	{
		super.dispose();

        if (geometry != null)
        {
            geometry.dispose();
            Reflect.setField(this, "geometry", null);
        }

		if (material != null)
        {
            material.useCount --;
            material.dispose();
            Reflect.setField(this, "material", null);
        }
	}

    function set_geometry(g:Geometry):Geometry
    {
        geometry = g;
        if (geometry != null && ctx != null) geometry.init(ctx);

        return g;
    }

    function set_material(m:Material):Material
    {
        if (material != null) material.useCount --;

        material = m;

        if (material != null)
        {
            if (ctx != null) material.init(ctx);
            material.useCount ++;
        }
        return m;
    }

}
