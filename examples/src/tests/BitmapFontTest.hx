package tests;
import deep.dd.camera.Camera2D;
import deep.dd.display.BitmapFont2D;
import deep.dd.display.render.CloudRender;
import deep.dd.texture.atlas.FontAtlasTexture2D;
import deep.dd.texture.atlas.parser.AngelCodeFontParser;
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

class BitmapFontTest extends Test
{
	private var text:BitmapFont2D;
	private var radius:Float;
	private var centerX:Float;
	private var centerY:Float;
	private var angle:Float;
	private var angleSpeed:Float;
	
	public function new(wrld:World2D) 
	{
		super(wrld);
		
		var fontAtlas:FontAtlasTexture2D = new FontAtlasTexture2D(world.cache.getTexture(NavTitleImage), new AngelCodeFontParser(Xml.parse(Std.string(new NavTitleData())), 0.5));
		text = new BitmapFont2D(new CloudRender(20));
		text.font = fontAtlas;
		text.fieldWidth = 300;
		text.multiLine = true;
		text.fixedWidth = false;
		text.wordWrap = true;
		text.align = TextFormatAlign.CENTER;
		text.text = "Haxe Rules the Flash!!! ";
		wrld.scene.addChild(text);
		
		radius = ((wrld.width > wrld.height) ? wrld.height : wrld.width) * 0.35;
		centerX = wrld.width * 0.5;
		centerY = wrld.height * 0.5;
		angle = 0;
		angleSpeed = -0.005;
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

        super.drawStep(camera);
	}
	
	override public function dispose():Void 
	{
		super.dispose();
		text = null;
	}
	
}