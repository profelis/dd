package deep.dd.display;

import flash.geom.Vector3D;
import flash.geom.Matrix3D;
import deep.dd.geometry.Geometry;
import deep.dd.material.Material;
import deep.dd.camera.Camera2D;
import flash.display3D.Context3D;
import mt.m3d.Polygon;

class DisplayNode2D extends Node2D
{
    public var geometry(default, set_geometry):Geometry;

    public var material(default, set_material):Material;

    public var width(get_width, set_width):Float;
    public var height(get_height, set_height):Float;

    public function new(material:Material = null)
    {
        super();
        this.material = material;

        createGeometry();
    }

    function createGeometry()
    {
        geometry = Geometry.createSolid(_width = 1, _height = 1);
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
            Reflect.setField(material, "useCount", material.useCount - 1);
            material.dispose();
            Reflect.setField(this, "material", null);
        }
    }

    override public function init(ctx:Context3D):Void
    {
        if (this.ctx != ctx)
        {
            if (material != null) material.init(ctx);
            if (geometry != null) geometry.init(ctx);
        }
        super.init(ctx);
    }

    override public function updateStep()
    {
        if (geometry != null && geometry.needUpdate) geometry.update();

        super.updateStep();
    }

    override public function drawStep(camera:Camera2D):Void
    {
        if (material != null) material.draw(this, camera);

        super.drawStep(camera);
    }
	
    function set_geometry(g:Geometry):Geometry
    {
        if (g == geometry) return geometry;

        geometry = g;
        if (geometry != null && ctx != null) geometry.init(ctx);

        return geometry;
    }

    function set_material(m:Material):Material
    {
        if (m == material) return m;

        if (material != null) Reflect.setField(material, "useCount", material.useCount - 1);

        material = m;

        if (material != null)
        {
            if (ctx != null) material.init(ctx);
            Reflect.setField(material, "useCount", material.useCount + 1);
        }
        return m;
    }

    function get_width():Float
    {
        return _width * scaleX;
    }

    function set_width(v:Float):Float
    {
        scaleX = v / _width;
        return v;
    }

    function get_height():Float
    {
        return _height * scaleY;
    }

    function set_height(v:Float):Float
    {
        scaleY = v / _height;
        return v;
    }

}
