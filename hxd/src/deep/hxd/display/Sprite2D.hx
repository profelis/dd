package deep.hxd.display;
import deep.hxd.geometry.Geometry;
import deep.hxd.material.Material;
import deep.hxd.camera.Camera2D;
import flash.display3D.Context3D;
import format.hxsl.Shader;
import mt.m3d.Polygon;

class Sprite2D extends Node2D
{
    public function new(geometry:Geometry = null, material:Material = null)
    {
        super();
        this.geometry = geometry;
        this.material = material;
    }

    public var geometry:Geometry;

    public var material:Material;

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


}
