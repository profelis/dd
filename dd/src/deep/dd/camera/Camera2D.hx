package deep.dd.camera;

import flash.geom.Vector3D;
import mt.m3d.Matrix;
import flash.geom.Matrix3D;
import mt.m3d.Vector;
import mt.m3d.Camera;

class Camera2D
{
    var c:Camera;

    public function new()
    {
        c = new Camera();
        c.up = new Vector(0, 1, 0);
        c.zFar = 10000;
        scale = c.zoom;

        needUpdate = true;
    }

    public var needUpdate:Bool = false;

    public function update()
    {
        c.w = w;
        c.h = h;
        c.ratio = w / h;
        c.pos.z = w * 0.5 / Math.tan(c.fov * Math.PI / 360);
        c.pos.x = c.target.x = w * 0.5 + x;
        c.pos.y = c.target.y = h * 0.5 + y;

        c.update();

        proj = c.mProj.toMatrix();
        ort = c.mOrt.toMatrix();

        needUpdate = false;
    }

    public var proj:Matrix3D;
    public var ort:Matrix3D;

    var w:Int;
    var h:Int;

    public function resize(w:Int, h:Int)
    {
        if (this.w != w || this.h != h)
        {
            this.w = w;
            this.h = h;
            needUpdate = true;
        }
    }
	
	public function dispose():Void
	{
		if (c != null) c.dispose();
		c = null;
		proj = null;
		ort = null;
	}
	
	public var x(default, set_x):Float = 0;
    public var y(default, set_y):Float = 0;

	function set_x(val:Float):Float
	{
        if (x != val)
        {
            needUpdate = true;
            x = val;
        }
        return val;
	}
	
	function set_y(val:Float):Float
	{
        if (y != val)
        {
            needUpdate = true;
            y = val;
        }
		return val;
	}
	
	public var scale(default, set_scale):Float;
	
	function set_scale(val:Float):Float
	{
		c.zoom = scale = val;
		needUpdate = true;
		return val;
	}

    public function toString()
    {
        return Std.format("{Camera2D: $x $y scale:$scale}");
    }
}
