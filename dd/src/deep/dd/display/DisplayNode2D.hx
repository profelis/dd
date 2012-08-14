package deep.dd.display;

import deep.dd.geometry.Geometry;
import deep.dd.material.Material;
import deep.dd.camera.Camera2D;
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

    public var width(get_width, set_width):Float;
    public var height(get_height, set_height):Float;

    override public function init(ctx:Context3D):Void
    {
        if (this.ctx != ctx)
        {
            if (material != null) material.init(ctx);
            if (geometry != null) geometry.init(ctx);
        }
        super.init(ctx);
    }

    override public function draw(camera:Camera2D):Void
    {
        if (material != null && geometry != null)
        {
            if (geometry.needUpdate) geometry.update();
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
        if (g == geometry) return g;

        geometry = g;
        if (geometry != null && ctx != null) geometry.init(ctx);

        return g;
    }

    function set_material(m:Material):Material
    {
        if (m == material) return m;

        if (material != null) material.useCount --;

        material = m;

        if (material != null)
        {
            if (ctx != null) material.init(ctx);
            material.useCount ++;
        }
        return m;
    }

    function get_width():Float
    {
        return geometry.width * scaleX;
    }

    function set_width(v:Float):Float
    {
        scaleX = v / geometry.width;
        return v;
    }

    function get_height():Float
    {
        return geometry.height * scaleX;
    }

    function set_height(v:Float):Float
    {
        scaleY = v / geometry.height;
        return v;
    }

}
