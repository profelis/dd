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
    var p:Poly2D;

    public var ibuf(default, null):IndexBuffer3D;
    public var vbuf(default, null):VertexBuffer3D;

    public function new(?p:Poly2D)
    {
        this.p = p;
    }

    public function resize(w:Float, h:Float)
    {
        // TODO: optimize
        p = createPoly(w, h, textured);
        needUpdate = true;
    }

    var textured:Bool;

    static public function create(w:Float, h:Float, textured:Bool = false):Geometry
    {
        var res = new Geometry();
        res.textured = textured;
        res.p = createPoly(w, h, textured);

        return res;
    }

    static function createPoly(w, h, textured)
    {
        var res = new Poly2D([new Vector( 0, 0, 0), new Vector(w, 0, 0), new Vector( 0, h, 0), new Vector(w, h, 0)], [0, 1, 2, 1, 3, 2]);
        if (textured)
        {
            res.tcoords = [new UV(0, 0), new UV(1, 0), new UV(0, 1), new UV(1, 1)];
        }
        return res;
    }

    public var needUpdate:Bool = true;
    var ctx:Context3D;

    public function init(ctx:Context3D)
    {
        if (this.ctx != ctx)
        {
            this.ctx = ctx;
            needUpdate = true;
        }
    }

    public function draw():Void
    {
        if (needUpdate)
        {
            p.alloc(ctx);
            ibuf = p.ibuf;
            vbuf = p.vbuf;

            needUpdate = false;
        }
    }
	
	public function handleDeviceLoss(context:Context3D):Void
	{
		init(context);
	}
	
	public function dispose():Void
	{
		p.dispose();
        p = null;

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

        colors = null;
	}

    public function setColor(color:Int):Void
    {
        p.setColors(color);
        needUpdate = true;

        colors = p.colors;
    }

    public var colors(default, null):Array<Color>;
}


//------------------------------------------

class Poly2D extends Polygon
{
    public function new(points, idx)
    {
        super(points, idx);
    }

    public var colors:Array<Color>;

    public function setColors(color:UInt):Void
    {
        var c = new Color().fromUint(color);

        colors = new Array();
        for (i in 0...points.length)
            colors[i] = c.clone();
    }

    override public function alloc(c:Context3D)
    {
        var tempColors = colors;
		dispose();
		if (tempColors != null) colors = tempColors;
        ibuf = c.createIndexBuffer(idx.length);
        ibuf.uploadFromVector(flash.Vector.ofArray(idx), 0, idx.length);
        var size = 3;
        if (normals != null) size += 3;
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
            if (normals != null)
            {
                var n = normals[k];
                buf[i++] = n.x;
                buf[i++] = n.y;
                buf[i++] = n.z;
            }
            if (tangents != null)
            {
                var t = tangents[k];
                buf[i++] = t.x;
                buf[i++] = t.y;
                buf[i++] = t.z;
            }
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
