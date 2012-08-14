package deep.dd.material.sprite2d;

import deep.dd.display.Sprite2D;
import deep.dd.camera.Camera2D;
import deep.dd.display.DisplayNode2D;
import deep.dd.material.Quad2DMaterial;
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
        #if debug
        if (!Std.is(sprite, Sprite2D)) throw "can't draw " + sprite;
        #end
        var sp:Sprite2D = cast sprite;
        var tex = sp.texture;
        spriteShader.init({mpos:sprite.worldTransform, mproj:camera.proj, region:tex.region}, {tex:tex.texture});

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

        include("./deep/dd/material/sprite2d/Sprite2DShader.hxsl");

        function texture(t:Texture, uv:Float2)
        {
            return t.get(uv, wrap, linear, mm_linear);
        }
    };
}

