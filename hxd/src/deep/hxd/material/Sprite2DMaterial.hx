package deep.hxd.material;

import deep.hxd.display.Sprite2D;
import deep.hxd.camera.Camera2D;
import deep.hxd.display.DisplayNode2D;
import deep.hxd.material.Quad2DMaterial;
import flash.display3D.Context3D;
import format.hxsl.Shader;

class Sprite2DMaterial extends Material
{
    public function new()
    {
        super(SpriteShader);
    }

    override public function init(ctx:Context3D)
    {
        super.init(ctx);
        spriteShader = cast(shader, SpriteShader);
    }

    var spriteShader:SpriteShader;

    override public function draw(sprite:DisplayNode2D, camera:Camera2D)
    {
        var tex = cast(sprite, Sprite2D).texture;
        spriteShader.init({mpos:sprite.worldTransform, mproj:camera.proj}, {tex:tex.texture, region:tex.region});

        super.draw(sprite, camera);
    }
	
	override public function dispose():Void 
	{
		super.dispose();
		spriteShader = null;
	}

}

class SpriteShader extends Shader
{
    static var SRC = {
        var input : {
            pos : Float3,
            uv: Float2
        };
        var tuv:Float2;
        function vertex(mpos:M44, mproj:M44)
        {
            out = pos.xyzw * mpos * mproj;
            tuv = uv;
        }

        function fragment(tex:Texture, region:Float4)
        {
            var t = tuv;
            t.xy *= region.zw;
            t.xy += region.xy;
            out = tex.get(t);
        }
    };
}

