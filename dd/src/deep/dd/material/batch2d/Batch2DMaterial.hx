package deep.dd.material.batch2d;

import deep.dd.utils.Frame;
import flash.Vector;
import deep.dd.display.DisplayNode2D;
import flash.geom.Vector3D;
import flash.geom.Matrix3D;
import deep.dd.texture.Texture2D;
import deep.dd.material.Material;
import deep.dd.display.Sprite2D;
import deep.dd.camera.Camera2D;
import deep.dd.display.DisplayNode2D;
import flash.display3D.Context3D;
import hxsl.Shader;

class Batch2DMaterial extends Material<BatchShader>
{
    public function new()
    {
        super(null);
    }

    public function startBatch(node:Sprite2D, tex:Texture2D)
    {
        this.node = node;

        ctx.setBlendFactors(node.blendMode.src, node.blendMode.dst);

	    shader.tex = tex.texture;

        shader.bind(ctx, node.geometry.vbuf);
    }

    var node:Sprite2D;

    public function stopBatch()
    {
        shader.unbind(ctx);
        node = null;
    }

    public function drawBatch(camera:Camera2D, size:Int, mpos:Vector<Matrix3D>, cTrans:Vector<Vector3D>, regions:Vector<Vector3D>)
    {
        //untyped shader.init({mpos:mpos, mproj:camera.proj, cTransArr:cTrans, regions:regions}, {tex:tex.texture});
        //shader.send(true, untyped shader.getVertexConstants({mpos:mpos, mproj:camera.proj, cTransArr:cTrans, regions:regions}));
		shader.mpos = mpos;
		shader.mproj = camera.proj;
		shader.cTransArr = cTrans;
		shader.regions = regions;

        #if dd_stat
        node.world.statistics.drawCalls ++;
        node.world.statistics.triangles += size * 2;
        #end

        ctx.drawTriangles(node.geometry.ibuf, 0, size * 2);
    }

    override public function draw(node:DisplayNode2D, camera:Camera2D)
    {
        throw "use drawBatch";
    }
	
	public var wrap(get, set):Null<Bool>;
	
	function get_wrap() {
		return shader.pWrap;
	}
	
	function set_wrap(v) {
		return shader.pWrap = v;
	}
	
	public var filter(get, set):Null<Bool>;
	
	function get_filter() {
		return shader.pFilter;
	}
	
	function set_filter(v) {
		return shader.pFilter = v;
	}
	
	public var mipmap(get, set):Null<Bool>;
	
	function get_mipmap() {
		return shader.pMipmap;
	}
	
	function set_mipmap(v) {
		return shader.pMipmap = v;
	}
}

class Sprite2DShader extends Shader
{
    static var SRC = {
		var input : {
			pos : Float2,
			uv: Float2,
			index:Float
		};

		var tuv:Float2;
		var cTrans:Float4;
		var pWrap:Param<Bool>;
		var pFilter:Param<Bool>;
		var pMipmap:Param<Bool>;

		function vertex(mpos:M44<20>, mproj:Matrix, cTransArr:Float4<20>, regions:Float4<20>)
		{
			// http://code.google.com/p/hxformat/issues/detail?id=28#c8
			var i = input.pos.xyzw;
			i.x = input.index.x * 4;
			out = input.pos.xyzw * mpos[i.x] * mproj;

			var region = regions[input.index];
			tuv = input.uv * region.zw + region.xy;
			cTrans = cTransArr[index];
		}

		function fragment(tex:Texture)
		{
			out = tex.get(tuv, wrap=pWrap, filter=pFilter, mipmap=pMipmap) * cTrans;
		}
	};
}

