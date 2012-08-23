package deep.dd.display.render;

import flash.Vector;
import flash.geom.Vector3D;
import flash.geom.Matrix3D;
import deep.dd.material.batch2d.Batch2DMaterial;
import deep.dd.display.SmartSprite2D;
import deep.dd.animation.AnimatorBase;
import deep.dd.camera.Camera2D;
import deep.dd.display.Node2D;
import deep.dd.display.Sprite2D;
import deep.dd.geometry.Geometry;
import deep.dd.material.Material;
import deep.dd.texture.Texture2D;
import deep.dd.utils.Frame;
import deep.dd.utils.FastHaxe;
import haxe.FastList;

class BatchRender extends RenderBase
{

    static public inline var MAX_SIZE = 20;

	public function new()
	{
        emptyMatrix = new Matrix3D();
        emptyVector = new Vector3D(0, 0, 0, 0);

        material = mat = new Batch2DMaterial();
        geometry = Geometry.createTexturedBatch(MAX_SIZE);
	}

    override public function copy():RenderBase
    {
        return new BatchRender();
    }

    var mat:Batch2DMaterial;

    var textureFrame:Frame;
    var animator:AnimatorBase;

    override public function drawStep(camera:Camera2D, invalidateTexture:Bool):Void
    {
        if (smartSprite.texture == null)
        {
            #if debug
            trace("BatchRender reqired texture. Render in simple mode");
            #end
            for (i in smartSprite.children) if (i.visible) i.drawStep(camera);
            return;
        }

		textureFrame = smartSprite.textureFrame;
        animator = smartSprite.animator;

		drawBatch(smartSprite, camera, invalidateTexture);
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
        var mpos = new Vector<Matrix3D>(MAX_SIZE, true);
        var cTrans = new Vector<Vector3D>(MAX_SIZE, true);
        var regions = new Vector<Vector3D>(MAX_SIZE, true);

        var idx = 0;
        var vectorsFull = false;
        for (c in batchList)
        {
            var s:Sprite2D = null;
            if (FastHaxe.is(c, Sprite2D))
            {
                s = flash.Lib.as(c, Sprite2D);
                if (s.invalidateWorldTransform || s.invalidateTransform) s.invalidateDrawTransform = true;
            }

            if (c.invalidateTransform) c.updateTransform();
            if (c.invalidateWorldTransform) c.updateWorldTransform();
            if (c.invalidateColorTransform) c.updateWorldColor();

            if (c.numChildren > 0 || s == null)
            {
                trace("to subnode");
                subNodes.add(c);
                continue;
            }

            #if debug
            if (!s.geometry.standart) throw "Batch2D ignore complex geometry";
            #end

            if (s.animator != null && s.animator != animator)
            {
                s.animator.draw(node.scene.time);
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

            mpos[idx] = s.drawTransform;
            cTrans[idx] = s.worldColorTransform;
            regions[idx] = s.textureFrame.region;

            idx ++;
            if (idx == MAX_SIZE)
            {
                mat.drawBatch(smartSprite, camera, smartSprite.texture, idx, mpos, cTrans, regions);
                vectorsFull = true;
                idx = 0;
            }
        }

        if (idx > 0)
        {
            if (!vectorsFull)
            {
                for (i in idx...MAX_SIZE)
                {
                    mpos[i] = emptyMatrix;
                    cTrans[i] = emptyVector;
                    regions[i] = emptyVector;
                }
            }
            mat.drawBatch(smartSprite, camera, smartSprite.texture, idx, mpos, cTrans, regions);
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
    var emptyVector:Vector3D;

    override public function dispose(deep = true)
    {
        super.dispose(deep);
        mat = null;
        emptyVector = null;
        emptyMatrix = null;
        textureFrame = null;
        animator = null;
    }
}