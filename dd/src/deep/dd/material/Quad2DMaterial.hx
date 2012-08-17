package deep.dd.material;

import flash.display3D.Context3D;
import hxsl.Shader;
import deep.dd.display.DisplayNode2D;
import deep.dd.camera.Camera2D;

class Quad2DMaterial extends Material
{
    public function new()
    {
        super(QuadShader);
    }

    override public function init(ctx:Context3D)
    {
        if (this.ctx == ctx) return;
        super.init(ctx);
        quadShader = cast(shader, QuadShader);
    }

    var quadShader:QuadShader;

    override public function draw(node:DisplayNode2D, camera:Camera2D)
    {
        quadShader.init({ mpos : node.worldTransform, mproj : camera.proj }, {cTrans:node.worldColorTransform});

        super.draw(node, camera);
    }
	
	override public function dispose():Void 
	{
		super.dispose();
		quadShader = null;
	}

}

class QuadShader extends Shader
{
    static var SRC = {
        var input : {
            pos : Float3,
            color: Float4
        };
        var c:Float4;
        function vertex(mpos:M44, mproj:M44)
        {
            out = pos.xyzw * mpos * mproj;
            c = color;
        }

        function fragment(cTrans:Float4)
        {
            out = c * cTrans;
        }
    };
}
