package deep.dd.texture.atlas;

import deep.dd.utils.Frame;
import deep.dd.texture.Texture2D;
import deep.dd.texture.atlas.AtlasTexture2D;

class FontAtlasTexture2D extends AtlasTexture2D
{
	public var spaceWidth(default, null):Int = 0;
	public var fontHeight(default, null):Int = 0;
	public var hasSpaceGlyph(default, null):Bool = false;
	
	var glyphs:Hash<Frame>;

    var fontParser:IFontAtlasParser;

    public function new(texture:Texture2D, parser:IFontAtlasParser)
    {
        super(texture, fontParser = parser);

        spaceWidth = fontParser.spaceWidth;
        fontHeight = fontParser.fontHeight;
        hasSpaceGlyph = fontParser.hasSpaceGlyph;

		glyphs = new Hash<Frame>();
		for (f in frames)
		{
			glyphs.set(f.name, f);
		}
    }
	
	public function getFrameByName(name:String):Frame
	{
		return glyphs.get(name);
	}
	
	override public function getTextureByName(name:String):Texture2D 
	{
		var f:Frame = glyphs.get(name);
		if (f != null)
		{
			return getTextureByFrame(f);
		}
		return null;
	}
	
	public function getTextWidth(text:String, spacing:Int = 0, scale:Float = 1.0):Float
	{
		var w:Float = 0;
		
		var textLength:Int = text.length;
		for (i in 0...(textLength))
		{
			var char:String = text.charAt(i);
			var glyph:Frame = glyphs.get(char);
			if (glyph != null)
			{
				if (glyph.border != null)
				{
					w += glyph.border.width;
				}
				else
				{
					w += glyph.width;
				}
			}
			else if (char == " ")
			{
				w += spaceWidth;
			}
		}
		
		w = w * scale;
		
		if (textLength > 1) w += (textLength - 1) * spacing;
		
		return w;
	}
	
	override public function dispose():Void 
	{
		glyphs = null;
		super.dispose();
	}

}

interface IFontAtlasParser implements IAtlasParser
{
    var fontHeight(default, null):Int;
    var spaceWidth(default, null):Int;
    var hasSpaceGlyph(default, null):Bool;
}