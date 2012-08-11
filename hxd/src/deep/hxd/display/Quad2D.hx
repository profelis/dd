package deep.hxd.display;
import deep.hxd.camera.Camera2D;
import deep.hxd.material.Quad2DMaterial;
import deep.hxd.geometry.Geometry;

class Quad2D extends DisplayNode2D
{
    public function new(geometry:Geometry)
    {
        super(geometry, new Quad2DMaterial());

        alpha = 1.0;
        color = 0x0000FF;
    }

    var fullColor:UInt;
    var needUpdateColor:Bool;

    public var color(default, set_color):Int;
    public var alpha(default, set_alpha):Float;

    function set_color(v)
    {
        color = v;
        needUpdateColor = true;
        return color;
    }

    function set_alpha(v:Float)
    {
        alpha = v < 0 ? 0 : v;
        needUpdateColor = true;
        return alpha;
    }

    override public function draw(camera:Camera2D):Void
    {
        if (needUpdateColor)
        {
            update();
        }

        super.draw(camera);
    }

    public function update():Void
    {
        fullColor = (Std.int(alpha * 0xFF) & 0xFF) << 24 | color;
        if (geometry != null) geometry.setColor(fullColor);

        needUpdateColor = false;
    }
}
