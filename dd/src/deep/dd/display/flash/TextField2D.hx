package deep.dd.display.flash;

/**
* @author Zaphod
* @author Dima Granetchi <system.grand@gmail.com>, <deep@e-citrus.ru>
*/

import deep.dd.camera.Camera2D;
import deep.dd.display.Sprite2D;
import deep.dd.texture.FlashTexture2D;
import deep.dd.texture.Texture2D;
import flash.filters.BitmapFilter;
import flash.text.AntiAliasType;
import flash.text.GridFitType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

/**
* Текстовое поле, базируется на рендере стандартного TextField на битмапу,
* что позволяет использовать все возможности текстовых полей
*
* @see flash.text.TextField
* @lang ru
**/
class TextField2D extends Sprite2D
{
	var flashField:TextField;
	
	var needRedraw:Bool;
	
	public function new(field:TextField = null) 
	{
		super();
		flashField = (field != null) ? field : new TextField();
		textFormat = flashField.defaultTextFormat;
		text = flashField.text;
		autoSize = flashField.autoSize;
		textWidth = Std.int(flashField.width);
		textHeight = Std.int(flashField.height);
		border = flashField.border;
		borderColor = flashField.borderColor;
		background = flashField.background;
		backgroundColor = flashField.backgroundColor;
		wordWrap = flashField.wordWrap;
		embedFonts = flashField.embedFonts;
		condenseWhite = flashField.condenseWhite;
		multiline = flashField.multiline;
		thickness = flashField.thickness;
		sharpness = flashField.sharpness;
		gridFitType = flashField.gridFitType;
		antiAliasType = flashField.antiAliasType;
		
		Reflect.setField(this, "texture", new FlashTexture2D(flashField));

		needRedraw = true;
    }

    /**
    * Кол-во символов в текстовом поле
    * @lang ru
    **/
	public var length(get_length, null):Int;
	
	function get_length():Int
	{
		return text.length;
	}

    /**
    * Формат текстового поля
    * @lang ru
    **/
	public var textFormat(default, set_textFormat):TextFormat;
	
	function set_textFormat(v:TextFormat):TextFormat
	{
		textFormat = v;
		needRedraw = true;
		return textFormat;
	}

    /**
    * Выравнивание текстового поля (по левому, правому краю или по центру)
    * @lang ru
    **/
	public var autoSize(default, set_autoSize):TextFieldAutoSize;
	
	function set_autoSize(v:TextFieldAutoSize):TextFieldAutoSize
	{
		if (autoSize != v)
		{
			autoSize = v;
			needRedraw = true;
		}
		return v;
	}

    /**
    * Текст отображаемый в текстовом поле
    * @lang ru
    **/
	public var text(default, set_text):String;
	
	function set_text(v:String):String
	{
		if (text != v)
		{
			text = v;
			needRedraw = true;
		}
		return v;
	}

    /**
    * Цвет текста
    * @lang ru
    **/
	public var textColor(get_textColor, set_textColor):UInt;
	
	function get_textColor():UInt
	{
		return textFormat.color;
	}
	
	function set_textColor(v:UInt):UInt
	{
		if (textFormat.color != v)
		{
			textFormat.color = v;
			needRedraw = true;
		}
		return v;
	}

    /**
    * Ширина текстового поля
    * @lang ru
    **/
	public var textWidth(default, set_textWidth):Int;
	
	function set_textWidth(v:Int):Int
	{
		if (textWidth != v)
		{
			textWidth = (v > 0) ? v : 0;
			needRedraw = true;
		}
		return v;
	}

    /**
    * Высота текстового поля
    * @lang ru
    **/
	public var textHeight(default, set_textHeight):Int;
	
	function set_textHeight(v:Int):Int
	{
		if (textHeight != v)
		{
			textHeight = (v > 0) ? v : 0;
			needRedraw = true;
		}
		return v;
	}

    /**
    * Показывать рамку вокруг текстового поля
    * @lang ru
    **/
	public var border(default, set_border):Bool;
	
	function set_border(v:Bool):Bool
	{
		if (border != v)
		{
			border = v;
			needRedraw = true;
		}
		return v;
	}

    /**
    * Цвет рамки вокруг текстового поля
    * @lang ru
    **/
	public var borderColor(default, set_borderColor):UInt;
	
	function set_borderColor(v:UInt):UInt
	{
		if (borderColor != v)
		{
			borderColor = v;
			needRedraw = true;
		}
		return v;
	}

    /**
    * Показывать одноцветный фон у текстового поля или нет
    * @lang ru
    **/
	public var background(default, set_background):Bool;
	
	function set_background(v:Bool):Bool
	{
		if (background != v)
		{
			background = v;
			needRedraw = true;
		}
		return v;
	}

    /**
    * Цвет фона текстового поля
    * @lang ru
    **/
	public var backgroundColor(default, set_backgroundColor):UInt;
	
	function set_backgroundColor(v:UInt):UInt
	{
		if (backgroundColor != v)
		{
			backgroundColor = v;
			needRedraw = true;
		}
		return v;
	}

    /**
    * Переносить слова на новую строку
    * @lang ru
    **/
	public var wordWrap(default, set_wordWrap):Bool;
	
	function set_wordWrap(v:Bool):Bool
	{
		if (wordWrap != v)
		{
			wordWrap = v;
			needRedraw = true;
		}
		return v;
	}

    /**
    * Использовать встоенные шрифты для отображения текста
    * @lang ru
    **/
	public var embedFonts(default, set_embedFonts):Bool;
	
	function set_embedFonts(v:Bool):Bool
	{
		if (embedFonts != v)
		{
			embedFonts = v;
			needRedraw = true;
		}
		return v;
	}

    /**
    * Учитывать пробелы при отображении html текста
    * @lang ru
    **/
	public var condenseWhite(default, set_condenseWhite):Bool;
	
	function set_condenseWhite(v:Bool):Bool
	{
		if (condenseWhite != v)
		{
			condenseWhite = v;
			needRedraw = true;
		}
		return v;
	}

    /**
    * Название шрифта
    * @lang ru
    **/
	public var font(get_font, set_font):String;
	
	function get_font():String
	{
		return textFormat.font;
	}
	
	function set_font(v:String):String
	{
		if (textFormat.font != v)
		{
			textFormat.font = v;
			needRedraw = true;
		}
		return v;
	}

    /**
    * Размер текста
    * @lang ru
    **/
	public var size(get_size, set_size):Float;
	
	function get_size():Float 
	{
		return textFormat.size;
	}

	function set_size(v:Float):Float 
	{
		if (textFormat.size != v)
		{
			textFormat.size = v;
			needRedraw = true;
		}
		return v;
	}

    /**
    * Выравнивание текста в текстовом поле
    * @lang ru
    **/
	public var align(get_align, set_align):TextFormatAlign;

	function get_align():TextFormatAlign 
	{
		return textFormat.align;
	}

	function set_align(v:TextFormatAlign):TextFormatAlign 
	{
		if (textFormat.align != align)
		{
			textFormat.align = v;
			needRedraw = true;
		}
		return v;
	}

    /**
    * Отображать текст жирным
    * @lang ru
    **/
	public var bold(get_bold, set_bold):Bool;

	function get_bold():Bool
	{
		return textFormat.bold;
	}

	function set_bold(v:Bool):Bool 
	{
		if (textFormat.bold != v)
		{
			textFormat.bold = v;
			needRedraw = true;
		}
		return v;
	}

    /**
    * Отображать текст курсивом
    * @lang ru
    **/
	public var italic(get_italic, set_italic):Bool;
	
	function get_italic():Bool 
	{
		return textFormat.italic;
	}

	function set_italic(v:Bool):Bool 
	{
		if (textFormat.italic != v)
		{
			textFormat.italic = v;
			needRedraw = true;
		}
		return v;
	}

    /**
    * Отображать текст с подчеркиванием
    * @lang ru
    **/
	public var underline(get_underline, set_underline):Bool;
	
	function get_underline():Bool 
	{
		return textFormat.underline;
	}

	function set_underline(v:Bool):Bool 
	{
		if (textFormat.underline != v)
		{
			textFormat.underline = v;
			needRedraw = true;
		}
		return v;
	}

    /**
    * Если задать true текстовое поле будет выводить текст в несколько строк
    * @lang ru
    **/
	public var multiline(default, set_multiline):Bool;
	
	function set_multiline(v:Bool):Bool 
	{
		if (multiline != v)
		{
			multiline = v;
			needRedraw = true;
		}
		return v;
	}

    /**
    * Толщина линий букв. Значение может быть от -200 до 200
    * @lang ru
    **/
	public var thickness(default, set_thickness):Float;
	
	function set_thickness(v:Float):Float
	{
		if (thickness != v)
		{
			thickness = v;
			needRedraw = true;
		}
		return v;
	}

    /**
    * Четкость линий букв. Значение может быть от -400 до 400
    * @lang ru
    **/
	public var sharpness(default, set_sharpness):Float;
	
	function set_sharpness(v:Float):Float
	{
		if (sharpness != v)
		{
			sharpness = v;
			needRedraw = true;
		}
		return v;
	}

    /**
    * Выравнивание по сетке, работает только если включен ADVANCED антиалиасинг
    * @lang ru
    **/
	public var gridFitType(default, set_gridFitType):GridFitType;
	
	function set_gridFitType(v:GridFitType):GridFitType
	{
		if (gridFitType != v)
		{
			gridFitType = v;
			needRedraw = true;
		}
		return v;
	}

    /**
    * Тип антиалиасинга
    * @lang ru
    **/
	public var antiAliasType(default, set_antiAliasType):AntiAliasType;
	
	function set_antiAliasType(v:AntiAliasType):AntiAliasType
	{
		if (antiAliasType != v)
		{
			antiAliasType = v;
			needRedraw = true;
		}
		return v;
	}

    override public function updateStep()
    {
        if (needRedraw) validateNow();
        super.updateStep();
    }

	override public function dispose():Void 
	{
		super.dispose();
		flashField = null;
		Reflect.setField(this, "textFormat", null);
	}

    /**
    * Тип антиалиасинга
    * @lang ru
    **/
	public function validateNow():Void
	{
		flashField.defaultTextFormat = textFormat;
		flashField.multiline = multiline;
		flashField.thickness = thickness;
		flashField.sharpness = sharpness;
		flashField.gridFitType = gridFitType;
		flashField.antiAliasType = antiAliasType;
		flashField.htmlText = text;
		flashField.border = border;
		flashField.borderColor = borderColor;
		flashField.background = background;
		flashField.backgroundColor = backgroundColor;
		
		flashField.autoSize = autoSize;
		flashField.wordWrap = wordWrap;
		flashField.embedFonts = embedFonts;
		flashField.condenseWhite = condenseWhite;
		
		flashField.width = (textWidth > 0) ? textWidth : flashField.textWidth;
		flashField.height = (textHeight > 0) ? textHeight : flashField.textHeight;
		
		texture.needUpdate = true;
		needRedraw = false;
	}
	
	override private function set_texture(tex:Texture2D):Texture2D 
	{
		#if debug
		throw "assert";
		#end
		return tex;
	}
	
}
