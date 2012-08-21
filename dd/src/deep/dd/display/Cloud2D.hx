package deep.dd.display;

import flash.geom.Vector3D;
import haxe.FastList;
import deep.dd.material.Material;
import deep.dd.camera.Camera2D;
import deep.dd.material.cloud2d.Cloud2DMaterial;
import deep.dd.geometry.Geometry;
import deep.dd.utils.FastHaxe;

class Cloud2D extends Sprite2D
{
    static inline public var PER_VERTEX:UInt = 9; // xyz, uv, rgba
    static inline public var MAX_SIZE:UInt = 16383; //65535 / 4;

    public var size(default, null):UInt;
    public var incSize:UInt;

    var mat:Cloud2DMaterial;

    /**
    *  @param size - start size
    *  @param incSize - step of increment/decrement size
    **/
    public function new(startSize:UInt = 20, incSize:UInt = 20)
    {
        #if debug
        if (startSize > MAX_SIZE) throw "size > MAX_SIZE";
        if (startSize == 0) throw "startSize can't be 0";
        if (incSize == 0) throw "incSize can't be 0";
        #end

        this.size = startSize;
        this.incSize = incSize;

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
        if (FastHaxe.is(material, Cloud2DMaterial)) mat = flash.Lib.as(material, Cloud2DMaterial);

        return material;
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
                f = animator.textureFrame;
            }

            if (textureFrame != f)
            {
                invalidateTexture = true;
                invalidateDrawTransform = true;
                textureFrame = f;
                _width = textureFrame.width;
                _height = textureFrame.height;
            }
        }

        if (invalidateWorldTransform || invalidateTransform) invalidateDrawTransform = true;

        if (invalidateTransform) updateTransform();
        if (invalidateWorldTransform) updateWorldTransform();
        if (invalidateColorTransform) updateWorldColor();

        if (invalidateDrawTransform) updateDrawTransform();

        renderSize = 0;

        drawBatch(this, camera, invalidateTexture);
    }

    public var renderSize(default, null):UInt;

    inline function drawBatch(node:Node2D, camera:Camera2D, invalidateTexture:Bool)
    {
        var batchList = new FastList<Sprite2D>();
        var renderList = new FastList<Node2D>();

        for (c in node.children)
        {
            if (!c.visible) continue;

            if (!c.ignoreInBatch && c.numChildren == 0 && FastHaxe.is(c, Sprite2D))
            {
                batchList.add(flash.Lib.as(c, Sprite2D));
                renderSize ++;
            }
            else
            {
                renderList.add(c);
            }
        }

        #if debug
        if (renderSize > MAX_SIZE) throw "render size > MAX_SIZE";
        #end

        size = Math.ceil(renderSize / incSize) * incSize;
        if (size > MAX_SIZE) size = renderSize;
        else if (size == 0) size = 1;

        geometry.resizeCloud(size);

        var idx = 0;
        for (s in batchList)
        {
            #if debug
            if (!s.geometry.standart) throw "can't batch complex geometry";
            #end

            if (s.invalidateWorldTransform || s.invalidateTransform) s.invalidateDrawTransform = true;

            if (s.invalidateTransform) s.updateTransform();
            if (s.invalidateWorldTransform) s.updateWorldTransform();
            if (s.invalidateColorTransform) s.updateWorldColor();

            if (s.animator != null && s.animator != animator)
            {
                s.animator.draw(scene.time);
                var frame = s.animator.textureFrame;

                if (frame != s.textureFrame)
                {
                    s.invalidateDrawTransform = true;
                    s.textureFrame = frame;
                    s._width = frame.width;
                    s._height= frame.height;
                }
            }
            else if (invalidateTexture || s.textureFrame == null)
            {
                s.textureFrame = textureFrame;
            }

            if (invalidateTexture || s.invalidateDrawTransform) s.updateDrawTransform();

            var poly = geometry.poly;
            var sPoly = s.geometry.poly;

            var i = idx;

            var m = s.drawTransform.rawData;
            for (p in sPoly.points)
            {
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

            var r = s.textureFrame.region;
            i = idx;
            for (t in sPoly.tcoords)
            {
                poly.tcoords[i].u = t.u * r.z + r.x;
                poly.tcoords[i].v = t.v * r.w + r.y;
                i++;
            }

            idx+=4;
        }

        if (renderSize > 0)
        {
            geometry.update();
            mat.draw(this, camera);
        }

        for (s in renderList)
        {
            s.drawStep(camera);
        }

    }

}
