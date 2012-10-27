package tests;
import deep.dd.display.Sprite2D;
import flash.geom.Vector3D;
import deep.dd.display.render.BatchRender;
import mt.m3d.Color;
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
	var text:BitmapFont2D;

	var text2:BitmapFont2D;
	
	public function new(wrld:World2D) 
	{
		super(wrld);

		var font:FontAtlasTexture2D = new FontAtlasTexture2D(world.cache.getTexture(NavTitleImage), new AngelCodeFontParser(Xml.parse(Std.string(new NavTitleData())), 0.5));
		text = new BitmapFont2D(new BatchRender());
		text.font = font;
		text.text = " Haxe Rules the Flash!!! ";
		wrld.scene.addChild(text);
		
		var radius = ((wrld.width > wrld.height) ? wrld.height : wrld.width) * 0.35;
		text.x = wrld.width * 0.5;
		text.y = wrld.height * 0.5;

		var font2:FontAtlasTexture2D = new FontAtlasTexture2D(world.cache.getTexture(KnightHawks), new FontSheetParser(31, 25, FontSheetParser.TEXT_SET2, 10, 0.5, 1));
		text2 = new BitmapFont2D(new CloudRender(20));
		text2.font = font2;
		text2.fieldWidth = world.width;
		text2.align = TextFormatAlign.CENTER;
		text2.y = 5;
		wrld.scene.addChild(text2);

        text.validateNow();

        var angleStep = 2 * Math.PI / text.text.length;
        var currAngle = -angleStep;
        var currPos:Int = -1;

        for (c in text.text.split(""))
        {
            currAngle += angleStep;

            if (c == " ") continue;
            currPos++;

            var ch:Sprite2D = cast text.getChildAt(currPos);
            ch.x = Math.cos(currAngle) * radius;
            ch.y = Math.sin(currAngle) * radius;
        }
	}
	
	override public function updateStep():Void
	{
		var currAngle = -time * 10;

        text.rotationZ = currAngle;

		for (c in text) { c.rotationX = -currAngle*5; c.rotationY = -currAngle*5; }

		text2.text = Std.string(Lib.getTimer());

        super.updateStep();
	}
	
	override public function dispose():Void 
	{
		super.dispose();
		text = null;
		text2 = null;
	}
	
}