package deep.dd.geometry;

import mt.m3d.UV;
import deep.dd.utils.Color;
import flash.display3D.VertexBuffer3D;
import flash.display3D.IndexBuffer3D;
import mt.m3d.Vector;
import flash.display3D.Context3D;
import mt.m3d.Polygon;

class Geometry
{
    var poly:Poly2D;

    public var ibuf(default, null):IndexBuffer3D;
    public var vbuf(default, null):VertexBuffer3D;

    public function new(?p:Poly2D)
    {
        this.poly = p;
    }

    var normal:Bool = false;

    public var textured(default, null):Bool = false;

    public var width(default, null):Float;
    public var height(default, null):Float;

    public var offsetX(default, null):Float;
    public var offsetY(default, null):Float;

    public var stepsX(default, null):Int;
    public var stepsY(default, null):Int;

    public var needUpdate(default, null):Bool = true;

    var ctx:Context3D;

    public function init(ctx:Context3D)
    {
        if (this.ctx != ctx)
        {
            this.ctx = ctx;
            needUpdate = true;
        }
    }

    public function update():Void
    {
        poly.alloc(ctx);
        ibuf = poly.ibuf;
        vbuf = poly.vbuf;

        needUpdate = false;
    }

    public function dispose():Void
    {
        poly.dispose();
        poly = null;

        if (ibuf != null)
        {
            ibuf.dispose();
            ibuf = null;
        }
        if (vbuf != null)
        {
            vbuf.dispose();
            vbuf = null;
        }
    }

    static public function createTextured(width = 1.0, height = 1.0, stepsX = 1, stepsY = 1, dx = 0.0, dy = 0.0):Geometry
    {
        return create(true, width, height, stepsX, stepsY, dx, dy);
    }

    static public function createSolid(width = 1.0, height = 1.0, stepsX = 1, stepsY = 1, dx = 0.0, dy = 0.0):Geometry
    {
        return create(false, width, height, stepsX, stepsY, dx, dy);
    }

    static public function create(textured:Bool, width = 1.0, height = 1.0, stepsX = 1, stepsY = 1, dx = 0.0, dy = 0.0):Geometry
    {
        #if debug
        if (width < 0) throw "width < 0";
        if (height < 0) throw "height < 0";
        #end

        stepsX = stepsX < 1 ? 1 : stepsX;
        stepsY = stepsY < 1 ? 1 : stepsY;

        var res = new Geometry();
        res.normal = true;
        res.width = width;
        res.height = height;
        res.stepsX = stepsX;
        res.stepsY = stepsY;
        res.offsetX = dx;
        res.offsetY = dy;
        res.textured = textured;
        res.poly = createPoly(textured, width, height, dx, dy, stepsX, stepsY);

        return res;
    }

    static function createPoly(textured = false, w = 1.0, h = 1.0, dx = 0.0, dy = 0.0, stepsX = 1, stepsY = 1)
    {
        var vs:Array<Vector> = [];
        var v:Vector;

        var uv:Array<UV> = [];
        var u:UV;

        var sx = 1 / stepsX;
        var sy = 1 / stepsY;

        var ix:Array<UInt> = [];

        stepsX++;
        stepsY++;

        for(i in 0...stepsX)
        {

            for(j in 0...stepsY)
            {
                var x = i * sx;
                var y = j * sy;

                v = new Vector(x * w + dx, y * h + dy, 0.0);
                vs.push(v);

                if (textured)
                {
                    u = new UV(x, y);
                    uv.push(u);
                }

                if (i > 0 && j > 0)
                {
                    ix.push((i-1) * stepsY + j-1);
                    ix.push((i-1) * stepsY + j);
                    ix.push((i) * stepsY + j-1);

                    ix.push((i-1) * stepsY + j);
                    ix.push((i) * stepsY + j);
                    ix.push((i) * stepsY + j-1);
                }
            }
        }

        var res = new Poly2D(vs, ix);
        if (textured) res.tcoords = uv;
        return res;
    }

    public function resize(width:Float, height:Float)
    {
        #if debug
        if (!normal) throw "can't resize unnormal geometry";
        #end

        var kx = width / this.width;
        var ky = height / this.height;
        trace(kx + " " + ky);

        for (i in poly.points)
        {
            i.x *= kx;
            i.y *= ky;
        }

        this.width = width;
        this.height = height;

        needUpdate = true;
    }

    public function offset(dx = 0.0, dy = 0.0)
    {
        #if debug
        if (!normal) throw "can't resize unnormal geometry";
        #end

        var x = dx - this.offsetX;
        var y = dy - this.offsetY;

        for (i in poly.points)
        {
            i.x += x;
            i.y += y;
        }

        this.offsetX = dx;
        this.offsetY = dy;

        needUpdate = true;
    }

    public function setColor(color:UInt):Void
    {
        var c = new Color();
        c.fromUInt(color);

        if (poly.colors == null)
        {
            var colors = new Array<Color>();
            for (i in 0...poly.points.length)
                colors[i] = c.clone();

            poly.colors = colors;
        }
        else
        {
            for (i in poly.colors)
            {
                i.fromColor(c);
            }
        }

        needUpdate = true;
    }

    public function setVertexColor(vertex:Int, c:UInt, ?alpha:Float)
    {
        #if debug
        if (vertex < 0 || poly.points.length <= vertex) throw "out of vertex bounds";
        if (poly.colors == null) throw "set colors first";
        #end

        poly.colors[vertex].fromInt(c, alpha != null ? alpha : poly.colors[vertex].a);

        needUpdate = true;
    }

    public function removeColor():Void
    {
        if (poly.colors != null)
        {
            poly.colors = null;

            needUpdate = true;
        }
    }
}


//------------------------------------------

class Poly2D extends Polygon
{
    public function new(points, idx)
    {
        super(points, idx);
    }

    public var colors:Array<Color>;

    override public function alloc(c:Context3D)
    {
        var tempColors = colors;
		dispose();
		if (tempColors != null) colors = tempColors;
        ibuf = c.createIndexBuffer(idx.length);
        ibuf.uploadFromVector(flash.Vector.ofArray(idx), 0, idx.length);
        var size = 3;
        if (tcoords != null) size += 2;
        if (colors != null) size+=4;

        vbuf = c.createVertexBuffer(points.length, size);
        var buf = new flash.Vector<Float>();
        var i = 0;
        for (k in 0...points.length)
        {
            var p = points[k];
            buf[i++] = p.x;
            buf[i++] = p.y;
            buf[i++] = p.z;

            if( tcoords != null )
            {
                var t = tcoords[k];
                buf[i++] = t.u;
                buf[i++] = t.v;
            }
            if (colors != null)
            {
                var t = colors[k];
                buf[i++] = t.r;
                buf[i++] = t.g;
                buf[i++] = t.b;
                buf[i++] = t.a;
            }
        }
        vbuf.uploadFromVector(buf, 0, points.length);
    }
	
	override public function dispose():Dynamic 
	{
		super.dispose();
		colors = null;
	}

}
