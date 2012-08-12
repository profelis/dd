package deep.hxd.camera;
import mt.m3d.Matrix;
import flash.geom.Matrix3D;
import mt.m3d.Vector;
import mt.m3d.Camera;

/**
 * Простая 2д камера, использует Николаса камеру для проекции, только выставляет ее на нужную высоту
 * и выравнивает по верхнему левому краю
**/
class Camera2D
{
    var c:Camera;

    public function new()
    {
        c = new Camera();
        c.up = new Vector(0, 1, 0);
        c.zFar = 10000;
    }

    public var needUpdate:Bool = false;

    public function update()
    {
        needUpdate = false;
    }

    public var proj:Matrix3D;

    var w:Int;
    var h:Int;

    public function resize(w:Int, h:Int)
    {
        this.w = w;
        this.h = h;

        c.w = w;
        c.h = h;
        c.ratio = w / h;
        c.pos.z = w * 0.5 / Math.tan(c.fov * Math.PI / 360);
        c.pos.x = c.target.x = w * 0.5;
        c.pos.y = c.target.y = h * 0.5;

        c.update();

        proj = c.m.toMatrix();
    }
	
	public function dispose():Void
	{
		if (c != null) c.dispose();
		c = null;
		proj = null;
	}
}
