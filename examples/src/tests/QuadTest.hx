package tests;
import deep.dd.display.Quad2D;
import deep.dd.geometry.Geometry;
import deep.dd.World2D;
import flash.Lib;

/**
 * ...
 * @author Zaphod
 */

class QuadTest extends Test
{
	var quad:Quad2D;
	
	public function new(wrld:World2D) 
	{
		super(wrld);
		quad = new Quad2D(Geometry.createSolid(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight));
		quad.geometry.setColor(0xffffff);
		addChild(quad);
	}
	
	override public function update():Void 
	{
		super.update();
		var time:Float = Lib.getTimer() / 1000;
		quad.geometry.setVertexColor(0, mixColors(0xFF0000, 0x00FF00, sin0_1(time * 2.2)), 	sin0_1(time * 2.3));
		quad.geometry.setVertexColor(1, mixColors(0x00FF00, 0x0000FF, sin0_1(time * 2.4)), 	sin0_1(time * 2.5));
		quad.geometry.setVertexColor(2, mixColors(0xFF00FF, 0xFFFF00, sin0_1(time * 2.6)), 	sin0_1(time * 2.7));
		quad.geometry.setVertexColor(3, mixColors(0x00FF99, 0x9900FF, sin0_1(time * 2.8)), 	sin0_1(time * 2.9));
	}
	
	override public function dispose():Void 
	{
		super.dispose();
		quad = null;
	}
	
	function sin0_1(t:Float):Float 
	{
		return 0.5 + Math.sin(t) * 0.5;
	}
	
	function mixColors(color1:Int, color2:Int, ratio:Float):Int
	{
		ratio = Math.max(0, ratio);
        ratio = Math.min(1, ratio);

		var col1:RGB = hex2rgb(color1);
        var col2:RGB = hex2rgb(color2);

        return rgb2hex(Std.int(col1.r * (1 - ratio) + col2.r * ratio), Std.int(col1.g * (1 - ratio) + col2.g * ratio), Std.int(col1.b * (1 - ratio) + col2.b * ratio));
	}
	
	function rgb2hex(r:Int, g:Int, b:Int):Int 
	{
		return (r << 16 | g << 8 | b);
	}
	
	function hex2rgb(h:Int):RGB 
	{
		return {r:h >> 16, g:h >> 8 & 255, b:h & 255};
	}
	
}

typedef RGB = {
	r:Int,
	g:Int,
	b:Int
}