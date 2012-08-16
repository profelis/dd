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
    }

    public var needUpdate:Bool = false;

    public function update()
    {
        if (needUpdate)
		{
			c.update();
			proj = c.m.toMatrix();
		}
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
	
	public var x(get_x, set_x):Float;
	
	function get_x():Float
	{
		return c.pos.x;
	}
	
	function set_x(val:Float):Float
	{
		c.pos.x = c.target.x = val;
		needUpdate = true;
		return val;
	}
	
	public var y(get_y, set_y):Float;
	
	function get_y():Float
	{
		return c.pos.y;
	}
	
	function set_y(val:Float):Float
	{
		c.pos.y = c.target.y = val;
		needUpdate = true;
		return val;
	}
	
	public var scale(get_scale, set_scale):Float;
	
	function get_scale():Float
	{
		return c.zoom;
	}
	
	function set_scale(val:Float):Float
	{
		c.zoom = val;
		needUpdate = true;
		return val;
	}
	
	public var angle(get_angle, set_angle):Float;
	
	function get_angle():Float
	{
		return c.angle;
	}
	
	function set_angle(val:Float):Float
	{
		c.angle = val;
		needUpdate = true;
		return val;
	}
}
