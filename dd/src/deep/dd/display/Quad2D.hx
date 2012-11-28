package deep.dd.display;

import deep.dd.geometry.Geometry;
import deep.dd.camera.Camera2D;
import deep.dd.material.Quad2DMaterial;

class Quad2D extends DisplayNode2D
{
    public function new()
    {
        super(new Quad2DMaterial());
        ignoreInBatch = true;
    }

    var needUpdateColor:Bool = true;

    public var color(default, set_color):Int = 0x0000FF;

    function set_color(v)
    {
        if (color != v)
        {
            color = v;
            needUpdateColor = true;
        }
        return color;
    }

    override function get_geometry():Geometry
    {
        if (needUpdateColor && geometry != null)
        {
            geometry.setColor(0xFF << 24 | color);

            needUpdateColor = false;
        }
        return super.get_geometry();
    }

    override function set_geometry(g:Geometry)
    {
        super.set_geometry(g);
        if (g != null) needUpdateColor = true;

        return g;
    }
}
