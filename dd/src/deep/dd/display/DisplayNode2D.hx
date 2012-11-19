package deep.dd.display;

import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.geom.Matrix3D;
import deep.dd.geometry.Geometry;
import deep.dd.material.Material;
import deep.dd.camera.Camera2D;
import flash.display3D.Context3D;
import mt.m3d.Polygon;

class DisplayNode2D extends Node2D
{
    public var geometry(get_geometry, set_geometry):Geometry;

    public var material(default, set_material):Material;

    /**
    * @private
    */
    public var _displayWidth:Float = 0;
    /**
    * @private
    */
    public var _displayHeight:Float = 0;

    public function new(material:Material = null)
    {
        super();
        this.material = material;

        createGeometry();
    }

    function createGeometry()
    {
        geometry = Geometry.createSolid(_displayWidth = 1, _displayHeight = 1);
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

    override function checkMouseOver(p:Vector3D)
    {
        var g = geometry;

        if (g == null || g.standart)
        {
            mouseOver = p.x >= 0 && p.x <= _displayWidth && p.y >= 0 && p.y <= _displayHeight;
        }
        else
        {
            var dx = -g.offsetX / g.width * _displayWidth;
            var dy = -g.offsetY / g.height * _displayHeight;
            mouseOver = p.x >= dx && p.x <= (_displayWidth-dx) && p.y >= dy && p.y <= (_displayHeight-dy);
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

    override public function drawStep(camera:Camera2D):Void
    {
        if (material != null) material.draw(this, camera);

        super.drawStep(camera);
    }

    function get_geometry():Geometry
    {
        if (geometry != null && geometry.needUpdate) geometry.update();

        return geometry;
    }
	
    function set_geometry(g:Geometry):Geometry
    {
        geometry = g;
        if (g != null && ctx != null) g.init(ctx);
        invalidateBounds = true;

        return g;
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

    public var displayWidth(get_displayWidth, set_displayWidth):Float;

    function get_displayWidth():Float
    {
        return _displayWidth * scaleX;
    }

    function set_displayWidth(v:Float):Float
    {
        if (_displayWidth == 0) _displayWidth = v;
        else scaleX = v / _displayWidth;
        return v;
    }

    public var displayHeight(get_displayHeight, set_displayHeight):Float;

    function get_displayHeight():Float
    {
        return _displayHeight * scaleY;
    }

    function set_displayHeight(v:Float):Float
    {
        if (_displayHeight == 0) _displayHeight = v;
        else scaleY = v / _displayHeight;
        return v;
    }
	
	override function getDisplayBounds(boundRect:Rectangle = null):Rectangle
	{
		boundRect = super.getDisplayBounds(boundRect);

        boundRect.width = _displayWidth;
        boundRect.height = _displayHeight;

        var g = geometry;
        if (g != null && !g.standart)
        {
            var dx = -g.offsetX / g.width * _displayWidth;
            var dy = -g.offsetY / g.height * _displayHeight;
            boundRect.x -= dx;
            boundRect.y -= dy;
        }

        return boundRect;
	}

}
