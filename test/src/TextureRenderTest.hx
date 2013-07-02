package ;

import deep.dd.texture.Texture2D;
import deep.dd.display.TextureRenderer;
import deep.dd.display.Scene2D;
import deep.dd.display.Sprite2D;
import deep.dd.utils.Stats;
import deep.dd.World2D;

import flash.display3D.Context3DRenderMode;
import mt.m3d.Color;

@:bitmap("deep.png") class Image extends flash.display.BitmapData {}

class TextureRenderTest
{
	var world:World2D;
	var scene:Scene2D;

	var s:Sprite2D;

    var ts:TextureRenderer;

	function new()
	{

		world = new deep.dd.World2D(flash.Lib.current.stage, Context3DRenderMode.AUTO, 2);
		world.bgColor = new Color(1, 1, 1);
		scene = world.scene = new Scene2D();

		flash.Lib.current.stage.addChild(new Stats(world, true));

		s = new Sprite2D();
        //s.x = 100;
		s.texture = world.cache.getTexture(Image);

        ts = new TextureRenderer(new EmptyTexture(512, 256));
        ts.rotation = 10;
        ts.bgColor = new Color(1, 0, 0, 0.5);
        //ts.colorTransform = new Color(0, 1, 0, 1);
        ts.addChild(s);
        ts.x = 100;
        ts.y = 30;
        scene.addChild(ts);

        var s2 = new Sprite2D();
        s2.texture = s.texture;
        //scene.addChild(s2);

		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, onRender);
	}

	function onRender(_)
	{
        s.x += 0.3;
        //ts.x += 1;
        //ts.z -= 1;
        ts.rotation += 0.1;
	}

	static function main()
	{
		new TextureRenderTest();
	}
}