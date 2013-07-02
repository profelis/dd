package deep.dd.material;

import deep.dd.camera.Camera2D;
import deep.dd.display.DisplayNode2D;
import deep.dd.display.smart.SmartSprite2D;
import deep.dd.material.Material;
import deep.dd.texture.Texture2D;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import hxsl.Shader;

class Batch2DMaterial extends Material<Batch2DShader>
{
    public function new()
    {
        super(new Batch2DShader());
    }

    public function startBatch(node:SmartSprite2D<Batch2DShader>, tex:Texture2D)
    {
        this.node = node;

        ctx.setBlendFactors(node.blendMode.src, node.blendMode.dst);

	    shader.tex = tex.texture;
		shader.pFilter = tex.filter;
		shader.pWrap = tex.wrap;
		shader.pMipmap = tex.mipmap;

        shader.bind(ctx, node.geometry.vbuf);
    }

    var node:SmartSprite2D<Batch2DShader>;

    public function stopBatch()
    {
        shader.unbind(ctx);
        node = null;
    }

    public function drawBatch(camera:Camera2D, size:Int, mpos:Array<Matrix3D>, cTrans:Array<Vector3D>, regions:Array<Vector3D>)
    {
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

    override public function draw(node:DisplayNode2D<Batch2DShader>, camera:Camera2D)
    {
        throw "use drawBatch";
    }
}

class Batch2DShader extends Shader
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
		
		function vertex(mproj:M44, mpos:M44<20>, cTransArr:Float4<20>, regions:Float4<20>)
		{
			out = input.pos.xyzw * mpos[input.index.x * 4] * mproj;
			
			var region = regions[input.index];
			tuv = input.uv * region.zw + region.xy;
			cTrans = cTransArr[input.index];
		}

		function fragment(tex:Texture)
		{
			out = tex.get(tuv, wrap=pWrap, filter=pFilter, mipmap=pMipmap) * cTrans;
		}
	};
}

