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

    override public function draw(camera:Camera2D):Void
    {
        if (needUpdateColor) update();

        super.draw(camera);
    }

    public function update():Void
    {
        if (geometry != null) geometry.setColor(0xFF << 24 | color);

        needUpdateColor = false;
    }

    override function set_geometry(g:Geometry)
    {
        if (g == geometry) return geometry;

        super.set_geometry(g);
        if (geometry != null) needUpdateColor = true;

        return geometry;
    }
}
