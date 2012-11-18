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
	
	override public function getDisplayBounds(boundRect:Rectangle = null):Rectangle
	{
		boundRect = super.getDisplayBounds(boundRect);
		
		var xMin:Float = 0;
		var yMin:Float = 0;
		var xMax:Float = _displayWidth;
		var yMax:Float = _displayHeight;
		
		if (usePivot)
		{
			xMin = -pivot.x;
			yMin = -pivot.y;
			xMax += xMin;
			yMax += yMin;
		}
		
		if ((rotation % 360) == 0)	// simple calculation
		{
			boundRect.x = xMin;
			boundRect.y = yMin;
			boundRect.width = xMax - xMin;
			boundRect.height = yMax - yMin;
			
			if (scaleX != 1)
			{
				boundRect.x *= scaleX;
				boundRect.width *= scaleX;
			}
			
			if (scaleY != 1)
			{
				boundRect.y *= scaleY;
				boundRect.height *= scaleY;
			}
			
			boundRect.x += x;
			boundRect.y += y;
			
			return boundRect;
		}

        var rads = this.rotation * Math.PI / 180;
        var cos = Math.cos(rads);
        var sin = Math.sin(rads);

		var xMinCos:Float = xMin * cos;
		var xMinSin:Float = xMin * sin;
		var xMaxCos:Float = xMax * cos;
		var xMaxSin:Float = xMax * sin;
		
		if (scaleX != 1)
		{
			xMinCos *= scaleX;
			xMinSin *= scaleX;
			xMaxCos *= scaleX;
			xMaxSin *= scaleX;
		}
		
		var yMinSin:Float = yMin * sin;
		var yMinCos:Float = yMin * cos;
		var yMaxSin:Float = yMax * sin;
		var yMaxCos:Float = yMax * cos;
		
		if (scaleY != 1)
		{
			yMinSin *= scaleY;
			yMinCos *= scaleY;
			yMaxSin *= scaleY;
			yMaxCos *= scaleY;
		}
		
		var x1:Float = xMinCos - yMinSin;
		var y1:Float = xMinSin + yMinCos;
		
		var x2:Float = xMaxCos - yMinSin;
		var y2:Float = xMaxSin + yMinCos;
		
		var x3:Float = xMaxCos - yMaxSin;
		var y3:Float = xMaxSin + yMaxCos;
		
		var x4:Float = xMinCos - yMaxSin;
		var y4:Float = xMinSin + yMaxCos;
		
		var mx1:Float = 0;
		var Mx1:Float = 0;
		var my1:Float = 0;
		var My1:Float = 0;
		
		if (x2 >= x1)
		{
			mx1 = x1;
			Mx1 = x2;
		}
		else
		{
			mx1 = x2;
			Mx1 = x1;
		}
		
		if (y2 >= y1)
		{
			my1 = y1;
			My1 = y2;
		}
		else
		{
			my1 = y2;
			My1 = y1;
		}
		
		var minX:Float = Math.min(Math.min(mx1, x3), x4);
		var minY:Float = Math.min(Math.min(my1, y3), y4);
		
		var maxX:Float = Math.max(Math.max(Mx1, x3), x4);
		var maxY:Float = Math.max(Math.max(My1, y3), y4);
		
		boundRect.x = minX + x;
		boundRect.y = minY + y;
		boundRect.width = maxX - minX;
		boundRect.height = maxY - minY;
		
		return boundRect;
	}

}
