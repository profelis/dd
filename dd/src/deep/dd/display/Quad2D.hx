package deep.dd.display;

import deep.dd.camera.Camera2D;
import deep.dd.material.Quad2DMaterial;
import deep.dd.geometry.Geometry;

class Quad2D extends DisplayNode2D
{
    public function new(geometry:Geometry)
    {
        super(geometry, new Quad2DMaterial());
    }

    var needUpdateColor:Bool = true;

    var fullColor:UInt;
    public var color(default, set_color):Int = 0x0000FF;
    public var alpha(default, set_alpha):Float = 1.0;

    function set_color(v)
    {
        if (color != v)
        {
            color = v;
            needUpdateColor = true;
        }
        return color;
    }

    function set_alpha(v:Float)
    {
        v = v < 0 ? 0 : v;
        if (alpha != v)
        {
            alpha = v;
            needUpdateColor = true;
        }
        return v;
    }

    override public function draw(camera:Camera2D):Void
    {
        if (needUpdateColor) update();

        super.draw(camera);
    }

    public function update():Void
    {
        fullColor = (Std.int(alpha * 0xFF) & 0xFF) << 24 | color;
        if (geometry != null) geometry.setColor(fullColor);

        needUpdateColor = false;
    }

    override function set_geometry(g:Geometry):Geometry
    {
        if (g == geometry) return g;

        super.set_geometry(g);
        if (geometry != null) needUpdateColor = true;

        return geometry;
    }
}
