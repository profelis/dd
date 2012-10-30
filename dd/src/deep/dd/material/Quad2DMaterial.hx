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

    override public function draw(node:DisplayNode2D, camera:Camera2D)
    {
        untyped shader.init({ mpos : node.worldTransform, mproj : camera.proj }, {cTrans:node.worldColorTransform});

        super.draw(node, camera);
    }
}

class QuadShader extends Shader
{
    static var SRC = {
        var input : {
            pos : Float2,
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
