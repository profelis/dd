package deep.dd.display.smart.render;

import haxe.ds.GenericStack;
import mt.m3d.UV;
import mt.m3d.Color;
import mt.m3d.Vector;
import deep.dd.display.smart.SmartSprite2D;
import deep.dd.camera.Camera2D;
import deep.dd.display.Node2D;
import deep.dd.display.Sprite2D;
import deep.dd.geometry.CloudGeometry;
import deep.dd.material.Material;
import deep.dd.material.Cloud2DMaterial;
import deep.dd.texture.Texture2D;
import deep.dd.utils.Frame;
import deep.dd.utils.FastHaxe;

class CloudRender extends RenderBase<Cloud2DShader>
{
    public var startSize(default, null):UInt;
	public var size(default, null):UInt;
	public var incSize(default, null):UInt;

    static inline public var PER_VERTEX:UInt = 8; // xyz, uv, rgba
    static inline public var MAX_SIZE:UInt = 16383; //65535 / 4;

	public function new(startSize:UInt = 20, incSize:UInt = 20, geometry:CloudGeometry = null)
	{
		#if debug
        if (startSize > MAX_SIZE) throw "size > MAX_SIZE";
        if (startSize == 0) throw "startSize can't be 0";
        if (incSize == 0) throw "incSize can't be 0";
        #end

        this.startSize = startSize;
        this.size = startSize;
        this.incSize = incSize;
        ignoreInBatch = true;

        material = mat = new Cloud2DMaterial();
        this.geometry = geom = geometry != null ? geometry : CloudGeometry.createTexturedCloud(startSize, PER_VERTEX);
	}

    var geom:CloudGeometry;

    override public function copy():RenderBase<Cloud2DShader>
    {
        var res = new CloudRender(startSize, incSize);
        return res;
    }

    var mat:Cloud2DMaterial;

    var textureFrame:Frame;

    override public function updateStep()
    {
        //var f = smartSprite.textureFrame;

        smartSprite.nativeUpdateStep();
    }

    override public function drawStep(camera:Camera2D):Void
    {
		if (smartSprite.texture == null)
        {
            #if debug
            trace("CloudRender reqired texture. Render in simple mode");
            #end
            for (i in smartSprite.children) if (i.visible) i.drawStep(camera);
            return;
        }

        renderSize = 0;
		textureFrame = smartSprite.textureFrame;

		drawBatch(smartSprite, camera);
    }

    public var renderSize(default, null):UInt;

    inline function drawBatch(node:Node2D, camera:Camera2D)
    {
        var batchList = new GenericStack<Sprite2D>();
        var renderList = new GenericStack<Node2D>();

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

        if (geom.triangles != untyped __global__["uint"](size * 2)) geom.resizeCloud(size);

        var idx:UInt = 0;
        var buf = geom.rawVBuf;

        for (s in batchList)
        {
            var sPoly = s.geometry.poly;

            var i = idx;
            var m = s.drawTransform.rawData;
            for (p in sPoly.points)
            {
                var px = p.x;
                var py = p.y;

                buf[i] = m[0] * px + m[4] * py + m[12];
                buf[i+1] = m[1] * px + m[5] * py + m[13];

                i+= PER_VERTEX;
            }

            i = idx + 2;
            var f = s.textureFrame;
            var r = f != null ? f.region : smartSprite.textureFrame.region;
            for (t in sPoly.tcoords)
            {
                buf[i] = t.u * r.z + r.x;
                buf[i+1] = t.v * r.w + r.y;

                i += PER_VERTEX;
            }

            i = idx + 4;
            var c = s.worldColorTransform;
            for (o in 0...4)
            {
                buf[i] = c.x;
                buf[i+1] = c.y;
                buf[i+2] = c.z;
                buf[i+3] = c.w;
                i+= PER_VERTEX;
            }

            idx += 4 * PER_VERTEX;
        }

        if (renderSize > 0)
        {
            if (geom.needUpdate) geom.update();
            geom.uploadVBuf();
            mat.drawCloud(smartSprite, camera, renderSize);
        }

        for (s in renderList)
        {
            s.drawStep(camera);
        }
    }

    override public function dispose(deep = true)
    {
        super.dispose(deep);
        mat = null;
        textureFrame = null;
    }
}