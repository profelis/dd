package deep.dd.display;

import deep.dd.material.batch2d.Batch2DMaterial;
import deep.dd.display.Node2D;
import haxe.FastList;
import mt.m3d.Color;
import deep.dd.display.Sprite2D;
import flash.geom.Vector3D;
import flash.geom.Matrix3D;
import flash.Vector;
import deep.dd.camera.Camera2D;
import deep.dd.material.Material;
import deep.dd.texture.atlas.animation.AnimatorBase;
import deep.dd.geometry.Geometry;

class Batch2D extends Sprite2D
{
    var mat:Batch2DMaterial;

    static public inline var MAX_SIZE = 24;

    public function new()
    {
        emptyMatrix = new Matrix3D();
        emptyColor = new Vector3D(0, 0, 0, 0);

        super(new Batch2DMaterial());

        ignoreInBatch = true;
    }

    override function createGeometry()
    {
        setGeometry(Geometry.createTexturedBatch(MAX_SIZE, _width = 1, _height = 1));
    }

    override function set_material(m:Material):Material
    {
        if (m == material) return m;

        super.set_material(m);
        if (m != null) mat = cast(m, Batch2DMaterial);

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

            if (geometry.needUpdate) geometry.update();
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
        var batchList = new FastList<Node2D>();
        var renderList = new FastList<Node2D>();

        for (c in node.children)
        {
            if (!c.visible) continue;

            if (c.ignoreInBatch)
            {
                renderList.add(c);
            }
            else
            {
                batchList.add(c);
            }
        }

        var subNodes = new FastList<Node2D>();
        var mpos = new Vector<Matrix3D>();
        var cTrans = new Vector<Vector3D>();

        for (c in batchList)
        {
            var s:Sprite2D = null;
            if (Std.is(c, Sprite2D))
            {
                s = cast(c, Sprite2D);
                if (s.invalidateWorldTransform || s.invalidateTransform) s.invalidateDrawTransform = true;
            }

            if (c.invalidateTransform) c.updateTransform();
            if (c.invalidateWorldTransform) c.updateWorldTransform();
            if (c.invalidateColorTransform) c.updateWorldColor();

            if (c.numChildren > 0 || s == null)
            {
                subNodes.add(c);
                continue;
            }

            if (invalidateTexture || s.invalidateDrawTransform)
            {
                s.drawTransform.rawData = frame.drawMatrix.rawData;
                s.drawTransform.append(s.worldTransform);

                s.invalidateDrawTransform = false;
            }

            #if debug
            if (s.geometry.triangles != 2) throw "Batch2D ignore complex geometry";
            #end

            mpos.push(s.drawTransform);
            cTrans.push(s.worldColorTransform);

            if (mpos.length == MAX_SIZE)
            {
                mat.drawBatch(this, camera, this.texture, mpos, cTrans);
                mpos.length = 0;
                cTrans.length = 0;
            }
        }

        if (mpos.length > 0)
        {
            for (i in mpos.length...MAX_SIZE)
            {
                mpos.push(emptyMatrix);
                cTrans.push(emptyColor);
            }
            mat.drawBatch(this, camera, this.texture, mpos, cTrans);
        }

        for (s in subNodes)
        {
            drawBatch(s, camera, invalidateTexture);
        }

        for (s in renderList)
        {
            s.drawStep(camera);
        }
    }

    var emptyMatrix:Matrix3D;
    var emptyColor:Vector3D;
}