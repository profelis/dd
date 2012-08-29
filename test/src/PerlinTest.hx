package ;

import deep.dd.display.DisplayNode2D;
import deep.dd.material.PerlinMaterial;
import deep.dd.display.Scene2D;
import deep.dd.display.Sprite2D;
import deep.dd.utils.Stats;
import deep.dd.World2D;

import flash.display3D.Context3DRenderMode;
import mt.m3d.Color;

//@:bitmap("deep.png") class Image extends flash.display.BitmapData {}

class PerlinTest
{
	var world:World2D;
	var scene:Scene2D;

	var s:DisplayNode2D;
    var perlin:PerlinMaterial;

	function new()
	{
		world = new deep.dd.World2D(Context3DRenderMode.AUTO, 2);
		world.bgColor = new Color(1, 1, 1);
		scene = world.scene = new Scene2D();

		flash.Lib.current.stage.addChild(new Stats(world, true));

		s = new DisplayNode2D(perlin = new PerlinMaterial());
		s.x = s.y = 0;
        s.width = 800;
        s.height = 600;
        s.colorTransform = new Color(0, 1, 0, 1);
		scene.addChild(s);
        s.rotationY = 0;

		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, onRender);
	}

	function onRender(_)
	{
        perlin.delta.x += 0.005;
        perlin.delta.y += 0.005;
		//s.texture.frame.region.x += 0.03;
		//s.texture.frame.region.y += 0.03;

        //s.rotationX = Math.sin(scene.time) * 45;
	}

	static function main()
	{
		new PerlinTest();
	}
}