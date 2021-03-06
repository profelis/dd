package deep.dd.material;

import flash.display3D.Context3D;
import hxsl.Shader;
import deep.dd.display.DisplayNode2D;
import deep.dd.camera.Camera2D;

class Quad2DMaterial extends Material<Quad2DShader>
{
    public function new()
    {
        super(new Quad2DShader());
    }

    override public function draw(node:DisplayNode2D<Quad2DShader>, camera:Camera2D)
    {
	    shader.mpos = node.worldTransform;
	    shader.mproj = camera.proj;
        shader.cTrans = node.worldColorTransform;

        super.draw(node, camera);
    }
}

class Quad2DShader extends Shader
{
    static var SRC = {
        var input : {
            pos : Float2,
            color: Float4
        };
        var c:Float4;
        function vertex(mpos:M44, mproj:M44)
        {
            out = input.pos.xyzw * mpos * mproj;
            c = input.color;
        }

        function fragment(cTrans:Float4)
        {
            out = c * cTrans;
        }
    };
}
