package deep.dd.geometry;


class BatchGeometry extends Geometry
{
    static public function createTexturedBatch(size:Int, width = 1.0, height = 1.0, offsetX = 0.0, offsetY = 0.0):BatchGeometry
    {
        var g:BatchGeometry = Geometry.create(BatchGeometry, true, width, height, 1, 1, offsetX, offsetY);
        var p = g.poly;

        var ps = p.points.slice(0, p.points.length);
        var ts = p.tcoords.slice(0, p.tcoords.length);
        var is = p.idx.slice(0, p.idx.length);

        p.points.fixed = false;
        p.tcoords.fixed = false;
        p.idx.fixed = false;

        ps.fixed = true;
        ts.fixed = true;
        is.fixed = true;

        var sup:flash.Vector<Float> = flash.Vector.ofArray([0.0, 0, 0, 0]);
        p.sup = sup;

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

        p.points.fixed = true;
        p.tcoords.fixed = true;
        p.idx.fixed = true;
        sup.fixed = true;

        g.resizable = false;
        g.triangles *= size;

        g.size = size;

        return g;
    }

    override public function copy():Geometry
    {
        return createTexturedBatch(size, width, height, offsetX, offsetY);
    }

    public var size(default, null):Int;
}