package deep.dd.display;

import mt.m3d.Color;
import deep.dd.display.Sprite2D;
import flash.geom.Vector3D;
import flash.geom.Matrix3D;
import flash.Vector;
import deep.dd.camera.Camera2D;
import deep.dd.material.Material;
import deep.dd.material.batch2d.Batch2DMaterial;
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
    }

    override function createGeometry()
    {
        setGeometry(Geometry.createTexturedBatch(MAX_SIZE, _width = 1, _height = 1));
    }

    override public function drawStep(camera:Camera2D):Void
    {
        if (mat == null)
        {
            super.drawStep(camera);
            return;
        }
        if (geometry.needUpdate) geometry.update();

        var invalidateTexture:Bool = false;
        if (texture != null)
        {
            if (animator != null) animator.draw(scene.time);

            if (texture.needUpdate)
            {
                texture.update();
                invalidateDrawTransform = true;
                _width = texture.width;
                _height = texture.height;
                invalidateTexture = true;
            }
        }

        if (invalidateWorldTransform || invalidateTransform) invalidateDrawTransform = true;

        if (invalidateTransform) updateTransform();
        if (invalidateWorldTransform) updateWorldTransform();
        if (invalidateColorTransform) updateWorldColor();

        if (invalidateDrawTransform) updateDrawTransform();

        if (texture != null) drawBatch(this, camera, invalidateTexture);
    }

    function drawBatch(node:Node2D, camera:Camera2D, invalidateTexture:Bool)
    {
        var mpos = new Vector<Matrix3D>();
        var cTrans = new Vector<Vector3D>();

        if (Std.is(node, Sprite2D))
        {
            var nodeSprite:Sprite2D = cast node;
            for (c in node.children)
            {
                var s = cast(c, Sprite2D);

                if (s == null || !s.visible) continue;

                if (invalidateTexture || s.invalidateWorldTransform || s.invalidateTransform) s.invalidateDrawTransform = true;

                if (s.invalidateTransform) s.updateTransform();
                if (s.invalidateWorldTransform) s.updateWorldTransform();
                if (s.invalidateColorTransform) s.updateWorldColor();

                if (s.invalidateDrawTransform)
                {
                    s.drawTransform.rawData = texture.drawMatrix.rawData;
                    s.drawTransform.append(s.worldTransform);

                    s.invalidateDrawTransform = false;
                }

                mpos.push(s.drawTransform);
                cTrans.push(s.worldColorTransform);

                if (mpos.length == MAX_SIZE)
                {
                    mat.drawBatch(nodeSprite, camera, nodeSprite.texture, mpos, cTrans);
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
                mat.drawBatch(nodeSprite, camera, nodeSprite.texture, mpos, cTrans);
            }
        }
    }

    var emptyMatrix:Matrix3D;
    var emptyColor:Vector3D;

    override function set_material(m:Material):Material
    {
        if (m == material) return m;

        super.set_material(m);
        if (m != null) mat = cast(m, Batch2DMaterial);

        return m;
    }
}
