package deep.dd.display.smart.render;

import flash.Vector;
import flash.geom.Vector3D;
import flash.geom.Matrix3D;
import deep.dd.material.Batch2DMaterial;
import deep.dd.display.smart.SmartSprite2D;
import deep.dd.camera.Camera2D;
import deep.dd.display.Node2D;
import deep.dd.display.Sprite2D;
import deep.dd.geometry.BatchGeometry;
import deep.dd.material.Material;
import deep.dd.texture.Texture2D;
import deep.dd.utils.Frame;
import deep.dd.utils.FastHaxe;
import haxe.ds.GenericStack;

class BatchRender extends RenderBase<Batch2DShader>
{

    static public inline var MAX_SIZE = 20;

	public function new(geometry:BatchGeometry = null)
	{
        emptyMatrix = new Matrix3D();
        emptyVector = new Vector3D(0, 0, 0, 0);

        material = mat = new Batch2DMaterial();
        this.geometry = geometry != null ? geometry : BatchGeometry.createTexturedBatch(MAX_SIZE);

        mpos = new Array<Matrix3D>();
        cTrans = new Array<Vector3D>();
        regions = new Array<Vector3D>();

        ignoreInBatch = true;
	}

    override public function copy():RenderBase<Batch2DShader>
    {
        return new BatchRender(cast(geometry.copy(), BatchGeometry));
    }

    var mat:Batch2DMaterial;

    var textureFrame:Frame;

    override public function updateStep()
    {
        smartSprite.nativeUpdateStep();
    }

    override public function drawStep(camera:Camera2D):Void
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

        mat.startBatch(smartSprite, smartSprite.texture);

		drawBatch(smartSprite, camera);

        mat.stopBatch();
    }

    var mpos:Array<Matrix3D>;
    var cTrans:Array<Vector3D>;
    var regions:Array<Vector3D>;

    function drawBatch(node:Node2D, camera:Camera2D)
    {
        var renderList = new GenericStack<Node2D>();

        var subNodes = new GenericStack<Node2D>();

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

                if (c.numChildren > 0 || s == null)
                {
                    //trace("to subnode");
                    subNodes.add(c);
                    continue;
                }

                mpos[idx] = s.drawTransform;
                cTrans[idx] = s.worldColorTransform;
                regions[idx] = s.textureFrame != null ? s.textureFrame.region : textureFrame.region;

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
            drawBatch(s, camera);
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

        mpos = null;
        cTrans = null;
        regions = null;
    }
}