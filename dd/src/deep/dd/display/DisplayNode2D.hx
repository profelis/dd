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
    public var geometry(default, set_geometry):Geometry;

    public var material(default, set_material):Material;

    public var width(get_width, set_width):Float;
    public var height(get_height, set_height):Float;

    public function new(material:Material = null)
    {
        super();
        this.material = material;

        createGeometry();
    }

    function createGeometry()
    {
        geometry = Geometry.createSolid(_width = 1, _height = 1);
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

    override public function init(ctx:Context3D):Void
    {
        if (this.ctx != ctx)
        {
            if (material != null) material.init(ctx);
            if (geometry != null) geometry.init(ctx);
        }
        super.init(ctx);
    }

    override public function updateStep()
    {
        if (geometry != null && geometry.needUpdate) geometry.update();

        super.updateStep();
    }

    override public function drawStep(camera:Camera2D):Void
    {
        if (material != null) material.draw(this, camera);

        super.drawStep(camera);
    }
	
    function set_geometry(g:Geometry):Geometry
    {
        if (g == geometry) return geometry;

        geometry = g;
        if (geometry != null && ctx != null) geometry.init(ctx);

        return geometry;
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

    function get_width():Float
    {
        return _width * scaleX;
    }

    function set_width(v:Float):Float
    {
        scaleX = v / _width;
        return v;
    }

    function get_height():Float
    {
        return _height * scaleY;
    }

    function set_height(v:Float):Float
    {
        scaleY = v / _height;
        return v;
    }
	
	override private function getAABB(boundRect:Rectangle = null):Rectangle 
	{
		boundRect = super.getAABB(boundRect);
		
		var xMin:Float = 0;
		var yMin:Float = 0;
		var xMax:Float = _width;
		var yMax:Float = _height;
		
		if (usePivot)
		{
			xMin = -pivot.x;
			yMin = -pivot.y;
			xMax += xMin;
			yMax += yMin;
		}
		
		if ((rotation % 360) == 0)	// simple calculation
		{
			boundRect.x = (xMin + x);
			boundRect.y = (yMin + y);
			boundRect.width = (xMax - xMin);
			boundRect.height = (yMax - yMin);
			
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
			
			return boundRect;
		}
		
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
