package deep.dd.geometry;

import flash.display3D.Context3D;
import mt.m3d.UV;
import mt.m3d.Color;
import flash.display3D.VertexBuffer3D;
import flash.display3D.IndexBuffer3D;
import mt.m3d.Vector;
import flash.display3D.Context3D;
import mt.m3d.Polygon;

class Geometry
{
    public var poly(default, null):Poly2D;

    public var ibuf(default, null):IndexBuffer3D;
    public var vbuf(default, null):VertexBuffer3D;

    function new(?p:Poly2D)
    {
        this.poly = p;
    }

    public var resizable(default, null):Bool = false;
    public var standart(default, null):Bool = false;

    public var textured(default, null):Bool = false;

    public var width(default, null):Float;
    public var height(default, null):Float;

    public var offsetX(default, null):Float;
    public var offsetY(default, null):Float;

    public var stepsX(default, null):Int;
    public var stepsY(default, null):Int;

    public var needUpdate(default, null):Bool = true;

    public var triangles(default, null):UInt;

    var ctx:Context3D;

    public function init(ctx:Context3D)
    {
        if (this.ctx != ctx)
        {
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

    static public function createTextured(width = 1.0, height = 1.0, stepsX = 1, stepsY = 1, offsetX = 0.0, offsetY = 0.0):Geometry
    {
        return create(Geometry, true, width, height, stepsX, stepsY, offsetX, offsetY);
    }

    static public function createSolid(width = 1.0, height = 1.0, stepsX = 1, stepsY = 1, offsetX = 0.0, offsetY = 0.0):Geometry
    {
        return create(Geometry, false, width, height, stepsX, stepsY, offsetX, offsetY);
    }

    static public function create<T:Geometry>(ref:Class<T>, textured:Bool, width = 1.0, height = 1.0, stepsX = 1, stepsY = 1, offsetX = 0.0, offsetY = 0.0):T
    {
        #if debug
        if (width < 0) throw "width < 0";
        if (height < 0) throw "height < 0";
        #end

        stepsX = stepsX < 1 ? 1 : stepsX;
        stepsY = stepsY < 1 ? 1 : stepsY;

        var res:Geometry = Type.createInstance(ref, []);
        res.resizable = true;
        res.width = width;
        res.height = height;
        res.stepsX = stepsX;
        res.stepsY = stepsY;
        res.offsetX = offsetX;
        res.offsetY = offsetY;
        res.textured = textured;
        res.poly = createPoly(textured, width, height, offsetX, offsetY, stepsX, stepsY);

        res.triangles = Std.int(res.poly.idx.length / 3);

        res.standart = width == 1 && height == 1 && stepsX == 1 && stepsY == 1 && offsetX == 0 && offsetY == 0;

        return cast res;
    }

    static function createPoly(textured = false, w = 1.0, h = 1.0, dx = 0.0, dy = 0.0, stepsX = 1, stepsY = 1)
    {
        var vs:flash.Vector<Vector> = new flash.Vector();
        var v:Vector;

        var uv:flash.Vector<UV> = new flash.Vector();
        var u:UV;

        var sx = 1 / stepsX;
        var sy = 1 / stepsY;

        var ix:flash.Vector<UInt> = new flash.Vector();

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
                    ix.push((i-1) * stepsY + j-1); // 0
                    ix.push((i-1) * stepsY + j);   // 1
                    ix.push((i) * stepsY + j);     // 2

                    ix.push((i-1) * stepsY + j-1); // 0
                    ix.push((i) * stepsY + j);     // 2
                    ix.push((i) * stepsY + j-1);   // 3
                }
            }
        }
        vs.fixed = true;
        uv.fixed = true;
        ix.fixed = true;
        var res = new Poly2D(vs, ix);
        if (textured) res.tcoords = uv;
        return res;
    }

    function resize(width:Float, height:Float)
    {
        #if debug
        if (!resizable) throw "can't resize geometry";
        #end
        if (this.width == width && this.height == height) return;

        var kx = width / this.width;
        var ky = height / this.height;

        for (i in poly.points)
        {
            i.x *= kx;
            i.y *= ky;
        }

        this.width = width;
        this.height = height;

        needUpdate = true;
    }

    function offset(dx = 0.0, dy = 0.0)
    {
        #if debug
        if (!resizable) throw "can't resize geometry";
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
            var colors = new flash.Vector<Color>(poly.points.length, true);
            for (i in 0...poly.points.length)
                colors[i] = c.copy();

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

    public function setVertexColor(vertex:UInt, c:UInt, ?alpha:Float)
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

    public var colors:flash.Vector<Color>;

    public var sup:flash.Vector<Float>;

    override public function alloc(c:Context3D)
    {
        var tempColors = colors;
		dispose();
		if (tempColors != null) colors = tempColors;
        ibuf = c.createIndexBuffer(idx.length);
        ibuf.uploadFromVector(idx, 0, idx.length);

        if (points == null) return;


        var size = 2;
        if (tcoords != null) size += 2;
        if (colors != null) size+=4;
        if (sup != null) size+=1;

        vbuf = c.createVertexBuffer(points.length, size);
        var buf = new flash.Vector<Float>(size * points.length, true);
        var i = 0;
        for (k in 0...points.length)
        {
            var p = points[k];
            buf[i++] = p.x;
            buf[i++] = p.y;
            //buf[i++] = p.z;

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
            if (sup != null)
            {
                buf[i++] = sup[k];
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
