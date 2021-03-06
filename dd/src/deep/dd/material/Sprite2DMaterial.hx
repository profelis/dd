package deep.dd.material;

import flash.geom.Matrix3D;
import deep.dd.material.Sprite2DMaterial;
import deep.dd.texture.Texture2D;
import deep.dd.material.Material;
import deep.dd.display.Sprite2D;
import deep.dd.camera.Camera2D;
import deep.dd.display.DisplayNode2D;
import deep.dd.material.Quad2DMaterial;
import deep.dd.utils.FastHaxe;
import flash.display3D.Context3D;
import hxsl.Shader;
import flash.Lib;

class Sprite2DMaterial extends Material<Sprite2DShader>
{
    public function new()
    {
        super(new Sprite2DShader());
    }
	
	var sp:Sprite2D;

    override public function draw(node:DisplayNode2D<Sprite2DShader>, camera:Camera2D)
    {
        #if debug
        if (!FastHaxe.is(node, Sprite2D)) throw "Sprite2DMaterial can't draw " + node;
        #end

        sp = cast(node);
        var tex = sp.texture;

        if (tex == null) throw "error"; // TODO:

		shader.pFilter = tex.filter;
		shader.pWrap = tex.wrap;
		shader.pMipmap = tex.mipmap;
		
	    shader.mpos = sp.drawTransform;
	    shader.mproj = camera.proj;
	    shader.region = sp.textureFrame.region;
	    shader.tex = tex.texture;
	    shader.cTrans = node.worldColorTransform;

        super.draw(node, camera);
    }
}

class Sprite2DShader extends Shader
{
    static var SRC = {
	    var input : {
		    pos : Float2,
		    uv: Float2
	    };

		var tuv:Float2;
		var pWrap:Param<Bool>;
		var pFilter:Param<Bool>;
		var pMipmap:Param<Bool>;

		function vertex(mpos:M44, mproj:M44, region:Float4)
		{
			out = input.pos.xyzw * mpos * mproj;
			tuv = input.uv * region.zw + region.xy;
		}

		function fragment(tex:Texture, cTrans:Float4)
		{
			out = tex.get(tuv, wrap=pWrap, filter=pFilter, mipmap=pMipmap) * cTrans;
		}
    };
}
