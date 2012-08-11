package deep.hxd.material;
import format.hxsl.Shader;
import deep.hxd.display.Sprite2D;
import deep.hxd.camera.Camera2D;

class Quad2DMaterial extends Material
{
    public function new()
    {
        super(QuadShader);
    }

    override public function draw(sprite:Sprite2D, camera:Camera2D)
    {
        cast(shader, QuadShader).init({ mpos : sprite.worldTransform, mproj : camera.proj }, {});

        super.draw(sprite, camera);
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
