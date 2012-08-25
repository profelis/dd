package tests;
import deep.dd.camera.Camera2D;
import deep.dd.display.BitmapFont2D;
import deep.dd.display.render.CloudRender;
import deep.dd.texture.atlas.FontAtlasTexture2D;
import deep.dd.texture.atlas.parser.AngelCodeFontParser;
import deep.dd.texture.atlas.parser.FontSheetParser;
import flash.display.BitmapData;
import flash.utils.ByteArray;
import mt.m3d.Camera;
import deep.dd.geometry.Geometry;
import deep.dd.World2D;
import flash.Lib;
import flash.text.TextFormatAlign;

/**
 * ...
 * @author Zaphod
 */

@:bitmap("../assets/bitmapFont/NavTitle.png") class NavTitleImage extends BitmapData { }
@:file("../assets/bitmapFont/NavTitle.fnt") class NavTitleData extends ByteArray { }

@:bitmap("../assets/bitmapFont/knighthawks_font.png") class KnightHawks extends BitmapData { }

class BitmapFontTest extends Test
{
	private var text:BitmapFont2D;
	private var radius:Float;
	private var centerX:Float;
	private var centerY:Float;
	private var angle:Float;
	private var angleSpeed:Float;
	
	var text2:BitmapFont2D;
	
	public function new(wrld:World2D) 
	{
		super(wrld);
		
		var font:FontAtlasTexture2D = new FontAtlasTexture2D(world.cache.getTexture(NavTitleImage), new AngelCodeFontParser(Xml.parse(Std.string(new NavTitleData())), 0.5));
		text = new BitmapFont2D(new CloudRender(20));
		text.font = font;
		text.fieldWidth = 300;
		text.multiLine = true;
		text.fixedWidth = false;
		text.wordWrap = true;
		text.text = "Haxe Rules the Flash!!! ";
		wrld.scene.addChild(text);
		
		radius = ((wrld.width > wrld.height) ? wrld.height : wrld.width) * 0.35;
		centerX = wrld.width * 0.5;
		centerY = wrld.height * 0.5;
		angle = 0;
		angleSpeed = -0.005;
		
		var font2:FontAtlasTexture2D = new FontAtlasTexture2D(world.cache.getTexture(KnightHawks), new FontSheetParser(31, 25, FontSheetParser.TEXT_SET2, 10, 0.5, 1));
		text2 = new BitmapFont2D(new CloudRender(20));
		text2.font = font2;
		text2.fieldWidth = world.width;
		text2.align = TextFormatAlign.CENTER;
		text2.y = 5;
		wrld.scene.addChild(text2);
	}
	
	override public function drawStep(camera:Camera2D):Void
	{
		var angleStep:Float = 2 * Math.PI / text.text.length;
		var currAngle:Float = angle;
		var currChar:String;
		var currPos:Int = 0;
		for (c in text.iterator())
		{
			while ((currChar = text.text.charAt(currPos)) == " ")
			{
				currPos++;
				currAngle += angleStep;
			}
			
			c.x = centerX + Math.cos(currAngle) * radius;
			c.y = centerY + Math.sin(currAngle) * radius;
			
			currPos++;
			currAngle += angleStep;
		}
		
		angle += angleSpeed;
		
		text2.text = Std.string(Lib.getTimer());

        super.drawStep(camera);
	}
	
	override public function dispose():Void 
	{
		super.dispose();
		text = null;
		text2 = null;
	}
	
}