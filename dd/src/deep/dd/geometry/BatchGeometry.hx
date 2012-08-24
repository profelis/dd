package deep.dd.geometry;


class BatchGeometry extends Geometry
{
    static public function createTexturedBatch(size:Int, width = 1.0, height = 1.0, offsetX = 0.0, offsetY = 0.0):BatchGeometry
    {
        var g:BatchGeometry = Geometry.create(BatchGeometry, true, width, height, 1, 1, offsetX, offsetY);
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
}