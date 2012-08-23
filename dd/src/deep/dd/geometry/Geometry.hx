package deep.dd.geometry;

import flash.display3D.Context3D;
import deep.dd.display.render.CloudRender;
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

    public function new(?p:Poly2D)
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

    static public function createTexturedCloud(size:UInt, width = 1.0, height = 1.0, offsetX = 0.0, offsetY = 0.0):Geometry
    {
        var g = createTextured(width, height, 1, 1, offsetX, offsetY);
        g.resizable = false;

        g.rawVBuf = new flash.Vector<Float>(4 * CloudRender.PER_VERTEX, true);
        for (i in 0...g.rawVBuf.length)
        {
            g.rawVBuf[i] = 0;
        }

        g.poly.points = null;
        g.poly.tcoords = null;

        g.resizeCloud(size);

        return g;
    }

    public var rawVBuf:flash.Vector<Float>;

    public function resizeCloud(size:UInt)
    {
        if (size <= 0) size = 1;
        var csize:UInt = untyped __global__["uint"](triangles / 2);

        if (csize == size) return;

        poly.idx.fixed = false;
        rawVBuf.fixed = false;
        rawVBuf.length = size * 4 * CloudRender.PER_VERTEX;

        if (csize > size)
        {
            poly.idx.length = size * 6;
        }
        else
        {
            var is = poly.idx.slice(0, 6);      // 6

            for (n in csize...size)
            {
                for (i in is) poly.idx.push(Std.int(n * 4 + i));
            }

            for (i in csize * 4 * CloudRender.PER_VERTEX...size * 4 * CloudRender.PER_VERTEX)
            {
                rawVBuf[i] = 0;
            }
        }

        poly.idx.fixed = true;
        rawVBuf.fixed = true;

        triangles = 2 * size;

        needUpdate = true;
    }

    inline public function allocCloudVBuf()
    {
        if (vbuf == null)
            poly.vbuf = vbuf = ctx.createVertexBuffer(triangles * 2, CloudRender.PER_VERTEX);

        vbuf.uploadFromVector(rawVBuf, 0, triangles * 2);
    }

    static public function createTexturedBatch(size:Int, width = 1.0, height = 1.0, offsetX = 0.0, offsetY = 0.0):Geometry
    {
        var g = createTextured(width, height, 1, 1, offsetX, offsetY);
        var p = g.poly;

        p.points.fixed = false;
        p.tcoords.fixed = false;

        var ps = p.points.slice(0, p.points.length);
        var ts = p.tcoords.slice(0, p.tcoords.length);
        var is = p.idx.slice(0, p.idx.length);
        is.fixed = true;
        var sup:flash.Vector<Float> = flash.Vector.ofArray([0.0, 0, 0, 0]);
        p.idx.fixed = false;

        for (n in 1...size)
        {
            p.points = p.points.concat(ps);
            p.tcoords = p.tcoords.concat(ts);
            sup.push(n);
            sup.push(n);
            sup.push(n);
            sup.push(n);
            for (i in is) p.idx.push(Std.int(n * 4 + i));
        }
        sup.fixed = true;

        p.points.fixed = true;
        p.tcoords.fixed = true;
        p.idx.fixed = true;

        p.sup = sup;
        g.resizable = false;

        g.triangles *= size;

        return g;
    }

    static public function createTextured(width = 1.0, height = 1.0, stepsX = 1, stepsY = 1, offsetX = 0.0, offsetY = 0.0):Geometry
    {
        return create(true, width, height, stepsX, stepsY, offsetX, offsetY);
    }

    static public function createSolid(width = 1.0, height = 1.0, stepsX = 1, stepsY = 1, offsetX = 0.0, offsetY = 0.0):Geometry
    {
        return create(false, width, height, stepsX, stepsY, offsetX, offsetY);
    }

    static public function create(textured:Bool, width = 1.0, height = 1.0, stepsX = 1, stepsY = 1, offsetX = 0.0, offsetY = 0.0):Geometry
    {
        #if debug
        if (width < 0) throw "width < 0";
        if (height < 0) throw "height < 0";
        #end

        stepsX = stepsX < 1 ? 1 : stepsX;
        stepsY = stepsY < 1 ? 1 : stepsY;

        var res = new Geometry();
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

        return res;
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


        var size = 3;
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
