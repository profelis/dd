package deep.dd.display;

import flash.geom.Vector3D;
import haxe.FastList;
import deep.dd.material.Material;
import deep.dd.camera.Camera2D;
import deep.dd.material.cloud2d.Cloud2DMaterial;
import deep.dd.geometry.Geometry;

class Cloud2D extends Sprite2D
{
    static inline public var PER_VERTEX:UInt = 9;
    static inline public var MAX_SIZE:UInt = Std.int(65536 / PER_VERTEX / 4);

    var size:UInt;

    var mat:Cloud2DMaterial;

    public function new(size:UInt)
    {
        if (size > MAX_SIZE) throw "size > MAX_SIZE";

        this.size = size;

        super(new Cloud2DMaterial());

        ignoreInBatch = true;
    }

    override function createGeometry()
    {
        setGeometry(Geometry.createTexturedCloud(size, _width = 1, _height = 1));
    }

    override function set_material(m:Material):Material
    {
        if (m == material) return m;

        super.set_material(m);
        if (m != null) mat = cast(m, Cloud2DMaterial);

        return m;
    }

    override public function drawStep(camera:Camera2D):Void
    {
        if (mat == null || texture == null)
        {
            super.drawStep(camera);
            return;
        }

        var invalidateTexture:Bool = false;
        if (texture != null)
        {
            var f = texture.frame;
            if (animator != null)
            {
                animator.draw(scene.time);
                f = animator.frame;
            }

            if (frame != f)
            {
                invalidateTexture = true;
                invalidateDrawTransform = true;
                frame = f;
                _width = frame.width;
                _height = frame.height;
            }
        }

        if (invalidateWorldTransform || invalidateTransform) invalidateDrawTransform = true;

        if (invalidateTransform) updateTransform();
        if (invalidateWorldTransform) updateWorldTransform();
        if (invalidateColorTransform) updateWorldColor();

        if (invalidateDrawTransform) updateDrawTransform();

        drawBatch(this, camera, invalidateTexture);
    }

    function drawBatch(node:Node2D, camera:Camera2D, invalidateTexture:Bool)
    {
        var batchList = new FastList<Sprite2D>();
        var renderList = new FastList<Node2D>();
        var batchLen:UInt = 0;

        for (c in node.children)
        {
            if (!c.visible) continue;

            if (!c.ignoreInBatch && c.numChildren == 0 && Std.is(c, Sprite2D))
            {
                batchList.add(cast(c, Sprite2D));
                batchLen ++;
            }
            else
            {
                renderList.add(c);
            }
        }

        #if debug
        if (batchLen > size) throw "Cloud2D maxsize reached";
        #end

        var idx = 0;

        for (s in batchList)
        {
            if (s.invalidateWorldTransform || s.invalidateTransform) s.invalidateDrawTransform = true;

            if (s.invalidateTransform) s.updateTransform();
            if (s.invalidateWorldTransform) s.updateWorldTransform();
            if (s.invalidateColorTransform) s.updateWorldColor();

            if (invalidateTexture || s.invalidateDrawTransform)
            {
                s.drawTransform.rawData = frame.drawMatrix.rawData;
                s.drawTransform.append(s.worldTransform);

                s.invalidateDrawTransform = false;
            }

            #if debug
            if (s.geometry.triangles != 2) throw "can't batch complex geometry";
            #end

            var poly = geometry.poly;
            var sPoly = s.geometry.poly;

            var i = idx;

            for (p in sPoly.points)
            {
                var m = s.drawTransform.rawData;
                poly.points[i++].set(
                    m[0] * p.x + m[4] * p.y + m[8] * p.z + m[12],
                    m[1] * p.x + m[5] * p.y + m[9] * p.z + m[13],
                    m[2] * p.x + m[6] * p.y + m[10] * p.z + m[14]
                );
            }

            i = idx;
            for (o in 0...4)
            {
                var c = poly.colors[i++];
                c.fromVector(s.worldColorTransform);
            }

            i = idx;
            var r = frame.region;
            for (t in sPoly.tcoords)
            {
                poly.tcoords[i].u = t.u * r.z + r.x;
                poly.tcoords[i].v = t.v * r.w + r.y;
                i++;
            }

            idx+=4;
        }
        geometry.update();

        mat.draw(this, camera);


        for (s in renderList)
        {
            s.drawStep(camera);
        }

    }

}
