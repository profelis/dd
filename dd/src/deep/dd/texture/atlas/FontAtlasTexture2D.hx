package deep.dd.texture.atlas;

/**
*  @author Zaphod
*/

import deep.dd.utils.Frame;
import deep.dd.texture.Texture2D;
import deep.dd.texture.atlas.AtlasTexture2D;

/**
* Атлас, для хранения символов шрифта
* @lang ru
**/
class FontAtlasTexture2D extends AtlasTexture2D
{
    /**
    * Ширина символа пробела
    * @lang ru
    **/
	public var spaceWidth(default, null):Int = 0;

    /**
    * Высота символов шрифта
    * @lang ru
    **/
	public var fontHeight(default, null):Int = 0;

    /**
    * Задан ли символ пробела, как отдельный фрейм
    * @lang ru
    **/
	public var hasSpaceGlyph(default, null):Bool = false;

    /**
    * Набор символов
    * @lang ru
    **/
	public var glyphs(default, null):Hash<Frame>;

    public function new(texture:Texture2D, parser:IFontAtlasParser)
    {
        super(texture, parser);

        spaceWidth = parser.spaceWidth;
        fontHeight = parser.fontHeight;
        hasSpaceGlyph = parser.hasSpaceGlyph;

		glyphs = new Hash<Frame>();
		for (f in frames)
		{
			glyphs.set(f.name, f);
		}
    }

    /**
    * Возвращает фрейм символа
    * @param name буква, кадр которой надо получить
    * @lang ru
    **/
	public function getFrameByName(name:String):Frame
	{
		return glyphs.get(name);
	}

    /**
    * Возвращает субтекстуру символа
    * @param name буква, кадр которой надо получить
    * @lang ru
    **/
	override public function getTextureByName(name:String):Texture2D 
	{
		var f:Frame = glyphs.get(name);
		if (f != null) return getTextureByFrame(f);
		return null;
	}

    /**
    * Возвращает ширину текста с учетом пробела между символами и шириной пробела
    * @lang ru
    **/
	public function getTextWidth(text:String, spacing:Int = 0, numSpacesInTab:Int = 4):Float
	{
		var w:Float = 0;
		
		var textLength:Int = text.length;
		for (i in 0...(textLength))
		{
			var char:String = text.charAt(i);
			var glyph:Frame = glyphs.get(char);
			if (glyph != null)
			{
				w += glyph.width;
			}
			else if (char == " ")
			{
				w += spaceWidth;
			}
			else if (char == "\t")
			{
				w += spaceWidth * numSpacesInTab;
			}
		}
		
		if (textLength > 1) w += (textLength - 1) * spacing;
		
		return w;
	}
	
	override public function dispose():Void 
	{
		glyphs = null;
		super.dispose();
	}

}

/**
* Парсер атласа шрифтов
* @lang ru
**/
interface IFontAtlasParser implements IAtlasParser
{
    var fontHeight(default, null):Int;
    var spaceWidth(default, null):Int;
    var hasSpaceGlyph(default, null):Bool;
}