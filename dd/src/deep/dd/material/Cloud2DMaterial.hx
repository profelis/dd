package deep.dd.material;

import deep.dd.display.smart.SmartSprite2D;
import deep.dd.display.DisplayNode2D;
import deep.dd.texture.Texture2D;
import deep.dd.material.Material;
import deep.dd.camera.Camera2D;
import deep.dd.utils.FastHaxe;
import hxsl.Shader;

class Cloud2DMaterial extends Material<Cloud2DShader>
{
    public function new()
    {
        super(null);
    }

    public function drawCloud(node:SmartSprite2D<Cloud2DShader>, camera:Camera2D, renderSize:UInt)
    {
        var tex = node.texture;
		
		shader.mproj = camera.proj;
		shader.tex = tex.texture;
		shader.pFilter = tex.filter;
		shader.pWrap = tex.wrap;
		shader.pMipmap = tex.mipmap;

        #if dd_stat
        node.world.statistics.drawCalls ++;
        node.world.statistics.triangles += renderSize * 2;
        #end

        ctx.setBlendFactors(node.blendMode.src, node.blendMode.dst);

        shader.bind(ctx, node.geometry.vbuf);
        ctx.drawTriangles(node.geometry.ibuf, 0, renderSize * 2);
        shader.unbind(ctx);
    }

    override public function draw(node:DisplayNode2D<Cloud2DShader>, camera:Camera2D)
    {
        throw "use drawCloud";
    }
}

class Cloud2DShader extends Shader
{
    static var SRC = {
		var input : {
			pos : Float2,
			uv: Float2,
			color:Float4
		};

		var tuv:Float2;
		var cTrans:Float4;
		var pWrap:Param<Bool>;
		var pFilter:Param<Bool>;
		var pMipmap:Param<Bool>;

		function vertex(mproj:Matrix)
		{
			out = input.pos.xyzw * mproj;
			tuv = input.uv;
			cTrans = input.color;
		}

		function fragment(tex:Texture)
		{
			out = tex.get(tuv, wrap=pWrap, filter=pFilter, mipmap=pMipmap) * cTrans;
		}
	};
}

