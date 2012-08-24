package deep.dd.geometry;

import deep.dd.display.render.CloudRender;

class CloudGeometry extends Geometry
{
    static public function createTexturedCloud(size:UInt, width = 1.0, height = 1.0, offsetX = 0.0, offsetY = 0.0):CloudGeometry
    {
        var g:CloudGeometry = cast Geometry.create(true, width, height, 1, 1, offsetX, offsetY, CloudGeometry);
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
}