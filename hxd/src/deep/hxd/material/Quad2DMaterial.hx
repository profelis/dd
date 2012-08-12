package deep.hxd.material;

import flash.display3D.Context3D;
import format.hxsl.Shader;
import deep.hxd.display.DisplayNode2D;
import deep.hxd.camera.Camera2D;

class Quad2DMaterial extends Material
{
    public function new()
    {
        super(QuadShader);
    }

    override public function init(ctx:Context3D)
    {
        super.init(ctx);
        quadShader = cast(shader, QuadShader);
    }

    var quadShader:QuadShader;

    override public function draw(sprite:DisplayNode2D, camera:Camera2D)
    {
        quadShader.init({ mpos : sprite.worldTransform, mproj : camera.proj }, {});

        super.draw(sprite, camera);
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

        function fragment()
        {
            out = c;
        }
    };
}
