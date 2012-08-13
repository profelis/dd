package ;

import flash.geom.Vector3D;
import flash.display3D.Context3D;
import deep.dd.camera.Camera2D;
import deep.dd.geometry.Geometry;
import deep.dd.material.Material;
import mt.m3d.PerlinShader;
import deep.dd.display.DisplayNode2D;
import mt.m3d.Vector;
import mt.m3d.Polygon;

class PerlinSprite extends DisplayNode2D {
    public function new() {

        super();

        geometry = new Geometry(new Poly2D([new Vector( -1, -1, 0), new Vector(1, -1, 0), new Vector( -1, 1, 0), new Vector(1, 1, 0)], [0, 1, 2, 1, 3, 2]));
        material = new PerlinMaterial();
    }

    override public function draw(camera:Camera2D)
    {
        transform.appendRotation(0.3, Vector3D.Y_AXIS);
        super.draw(camera);
    }


}

class PerlinMaterial extends Material
{
    public function new()
    {
        super(PerlinShader);

        time = Math.PI / 0.05;
    }

    var time:Float;

    override public function draw(sprite:DisplayNode2D, camera:Camera2D)
    {
        time += 0.1;
        cast(shader, PerlinShader).perlin(time * 0.05, time * 0.05, 0 * time * 0.005, 3);

        super.draw(sprite, camera);
    }

}
