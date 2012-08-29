package ;

import deep.dd.display.Scene2D;
import deep.dd.display.Sprite2D;
import deep.dd.utils.Stats;
import deep.dd.World2D;

import flash.display3D.Context3DRenderMode;
import mt.m3d.Color;

@:bitmap("deep.png") class Image extends flash.display.BitmapData {}

class UVTest
{
	var world:World2D;
	var scene:Scene2D;

	var s:Sprite2D;

	function new()
	{
		world = new deep.dd.World2D(Context3DRenderMode.AUTO, 2);
		world.bgColor = new Color(1, 1, 1);
		scene = world.scene = new Scene2D();

		flash.Lib.current.stage.addChild(new Stats(world, true));

		s = new Sprite2D();
		s.x = s.y = 50;
		s.scaleX = s.scaleY = 4;
		s.texture = world.cache.getTexture(Image);
		s.texture.frame.region.z *= 2;
		s.texture.frame.region.w *= 2;
		scene.addChild(s);

		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, onRender);
	}

	function onRender(_)
	{
		s.texture.frame.region.x += 0.03;
		s.texture.frame.region.y += 0.03;
	}

	static function main()
	{
		new UVTest();
	}
}