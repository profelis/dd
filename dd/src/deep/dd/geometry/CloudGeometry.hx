package deep.dd.geometry;

class CloudGeometry extends Geometry
{
    static public function createTexturedCloud(size:UInt, perVertex:UInt, width = 1.0, height = 1.0, offsetX = 0.0, offsetY = 0.0):CloudGeometry
    {
        var g:CloudGeometry = Geometry.create(CloudGeometry, true, width, height, 1, 1, offsetX, offsetY);
        g.resizable = false;

        g.perVertex = perVertex;
        g.rawVBuf = new flash.Vector<Float>(4 * perVertex, true);
        for (i in 0...g.rawVBuf.length)
        {
            g.rawVBuf[i] = 0;
        }

        g.poly.points = null;
        g.poly.tcoords = null;

        g.resizeCloud(size);

        return g;
    }

    var perVertex:UInt;

    public var rawVBuf:flash.Vector<Float>;

    public function resizeCloud(size:UInt)
    {
        if (size <= 0) size = 1;
        var csize:UInt = untyped __global__["uint"](triangles / 2);

        if (csize == size) return;

        poly.idx.fixed = false;
        rawVBuf.fixed = false;
        rawVBuf.length = size * 4 * perVertex;

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

            for (i in csize * 4 * perVertex...size * 4 * perVertex)
            {
                rawVBuf[i] = 0;
            }
        }

        poly.idx.fixed = true;
        rawVBuf.fixed = true;

        triangles = 2 * size;

        needUpdate = true;
    }

    inline public function uploadVBuf()
    {
        if (vbuf == null)
            poly.vbuf = vbuf = ctx.createVertexBuffer(triangles * 2, perVertex);

        vbuf.uploadFromVector(rawVBuf, 0, triangles * 2);
    }
}