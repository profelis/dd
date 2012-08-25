package deep.dd.display.render;

import haxe.Timer;
import flash.Vector;
import flash.geom.Vector3D;
import flash.geom.Matrix3D;
import deep.dd.material.batch2d.Batch2DMaterial;
import deep.dd.display.SmartSprite2D;
import deep.dd.animation.AnimatorBase;
import deep.dd.camera.Camera2D;
import deep.dd.display.Node2D;
import deep.dd.display.Sprite2D;
import deep.dd.geometry.BatchGeometry;
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
        geometry = BatchGeometry.createTexturedBatch(MAX_SIZE);

        mpos = new Vector<Matrix3D>(MAX_SIZE, true);
        cTrans = new Vector<Vector3D>(MAX_SIZE, true);
        regions = new Vector<Vector3D>(MAX_SIZE, true);
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

        mat.startBatch(smartSprite, smartSprite.texture);

		drawBatch(smartSprite, camera, invalidateTexture);

        mat.stopBatch();
    }

    var mpos:Vector<Matrix3D>;
    var cTrans:Vector<Vector3D>;
    var regions:Vector<Vector3D>;

    function drawBatch(node:Node2D, camera:Camera2D, invalidateTexture:Bool)
    {
        var renderList = new FastList<Node2D>();

        var subNodes = new FastList<Node2D>();

        var idx:UInt = 0;
        var vectorsFull = false;

        for (c in node.children)
        {
            if (!c.visible) continue;

            if (c.ignoreInBatch)
            {
                renderList.add(c);
            }
            else
            {
                var s:Sprite2D = flash.Lib.as(c, Sprite2D);
                if (s != null)
                {
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
                var sFrame = s.textureFrame;

                if (s.animator != null && s.animator != animator)
                {
                    s.animator.draw(node.scene.time);
                    var frame = s.animator.textureFrame;

                    if (frame != sFrame)
                    {
                        s.invalidateDrawTransform = true;
                        sFrame = frame;
                        s._width = frame.width;
                        s._height= frame.height;
                    }
                }
                else if (invalidateTexture || s.textureFrame == null)
                {
                    sFrame = textureFrame;
                    s.invalidateDrawTransform = true;
                }

                s.textureFrame = sFrame;

                if (invalidateTexture || s.invalidateDrawTransform) s.updateDrawTransform();

                mpos[idx] = s.drawTransform;
                cTrans[idx] = s.worldColorTransform;
                regions[idx] = sFrame.region;

                idx ++;
                if (idx == MAX_SIZE)
                {
                    mat.drawBatch(camera, idx, mpos, cTrans, regions);
                    vectorsFull = true;
                    idx = 0;
                }
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
            mat.drawBatch(camera, idx, mpos, cTrans, regions);
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

        mpos = null;
        cTrans = null;
        regions = null;
    }
}