package tests;
import deep.dd.display.Scene2D;
import deep.dd.display.Sprite2D;
import deep.dd.geometry.Geometry;
import deep.dd.World2D;
import flash.display.BitmapData;
import deep.dd.texture.Texture2D;
import flash.Lib;
import mt.m3d.Vector;

/**
 * ...
 * @author Zaphod
 */

@:bitmap("tests/image1.jpg") class Image1 extends BitmapData {}

class GeometryTest extends Test
{
	var grid:Sprite2D;
	
	var strength:Float = 0.07;
	
	public function new(wrld:World2D) 
	{
		super(wrld);
		grid = new Sprite2D(Geometry.createTextured(400, 300, 40, 30));
		var texture = world.cache.getTexture(Image1, Texture2DOptions.QUALITY_HIGH);
		world.cache.autoDisposeBitmaps = false;
		grid.texture = texture;
		trace(grid.texture.texture != null);
		grid.scaleX = world.width / grid.texture.bitmapWidth;
		grid.scaleY = world.height / grid.texture.bitmapHeight;
		addChild(grid);
	}
	
	override public function update():Void 
	{
		super.update();
		
		
	}
	
	override public function dispose():Void 
	{
		world.cache.autoDisposeBitmaps = true;
		super.dispose();
		grid = null;
	}
	
}