package deep.dd.display.flash;

import deep.dd.camera.Camera2D;
import deep.dd.display.Sprite2D;
import deep.dd.texture.FlashTexture2D;
import flash.filters.BitmapFilter;
import flash.text.AntiAliasType;
import flash.text.GridFitType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

class TextField2D extends Sprite2D
{
    
	var flashField:TextField;
	
	var autoWrap:Bool = true;
	
	private var needRedraw:Bool;
	
	public function new() 
	{
		super();
		flashField = new TextField();
		textFormat = new TextFormat();
		autoSize = TextFieldAutoSize.LEFT;
		thickness = 0;
		sharpness = 0;
		gridFitType = GridFitType.NONE;
		antiAliasType = AntiAliasType.NORMAL;
		
		needRedraw = true;
    }
	
	public var length(get_length, null):Int;
	
	function get_length():Int
	{
		return text.length;
	}
	
	public var textFormat(default, set_textFormat):TextFormat;
	
	function set_textFormat(v:TextFormat):TextFormat
	{
		textFormat = v;
		needRedraw = true;
		return textFormat;
	}
	
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
	
	public var text(default, set_text):String = "";
	
	function set_text(v:String):String
	{
		if (text != v)
		{
			text = v;
			needRedraw = true;
		}
		return v;
	}
	
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
	
	public var textWidth(default, set_textWidth):Int = 0;
	
	function set_textWidth(v:Int):Int
	{
		if (textWidth != v)
		{
			textWidth = (v > 0) ? v : 0;
			if (autoWrap)
			{
				wordWrap = textWidth > 0;
			}
			needRedraw = true;
		}
		return v;
	}
	
	public var textHeight(default, set_textHeight):Int = 0;
	
	function set_textHeight(v:Int):Int
	{
		if (textHeight != v)
		{
			textHeight = (v > 0) ? v : 0;
			needRedraw = true;
		}
		return v;
	}
	
	public var border(default, set_border):Bool = false;
	
	function set_border(v:Bool):Bool
	{
		if (border != v)
		{
			border = v;
			needRedraw = true;
		}
		return v;
	}
	
	public var borderColor(default, set_borderColor):UInt = 0xffffff;
	
	function set_borderColor(v:UInt):UInt
	{
		if (borderColor != v)
		{
			borderColor = v;
			needRedraw = true;
		}
		return v;
	}
	
	public var background(default, set_background):Bool = false;
	
	function set_background(v:Bool):Bool
	{
		if (background != v)
		{
			background = v;
			needRedraw = true;
		}
		return v;
	}
	
	public var backgroundColor(default, set_backgroundColor):UInt = 0x888888;
	
	function set_backgroundColor(v:UInt):UInt
	{
		if (backgroundColor != v)
		{
			backgroundColor = v;
			needRedraw = true;
		}
		return v;
	}
	
	public var wordWrap(default, set_wordWrap):Bool = false;
	
	function set_wordWrap(v:Bool):Bool
	{
		if (wordWrap != v)
		{
			wordWrap = v;
			needRedraw = true;
		}
		return v;
	}
	
	public var embedFonts(default, set_embedFonts):Bool = false;
	
	function set_embedFonts(v:Bool):Bool
	{
		if (embedFonts != v)
		{
			embedFonts = v;
			needRedraw = true;
		}
		return v;
	}
	
	public var condenseWhite(default, set_condenseWhite):Bool = false;
	
	function set_condenseWhite(v:Bool):Bool
	{
		if (condenseWhite != v)
		{
			condenseWhite = v;
			needRedraw = true;
		}
		return v;
	}
	
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
	
	public var multiline(get_multiline, set_multiline):Bool;
	
	function get_multiline():Bool 
	{
		return flashField.multiline;
	}
	
	function set_multiline(v:Bool):Bool 
	{
		if (flashField.multiline != v)
		{
			flashField.multiline = v;
			needRedraw = true;
		}
		return v;
	}
	
	public var thickness(get_thickness, set_thickness):Float;
	
	function get_thickness():Float
	{
		return flashField.thickness;
	}
	
	function set_thickness(v:Float):Float
	{
		if (flashField.thickness != v)
		{
			flashField.thickness = v;
			needRedraw = true;
		}
		return v;
	}
	
	public var sharpness(get_sharpness, set_sharpness):Float;
	
	function get_sharpness():Float
	{
		return flashField.sharpness;
	}
	
	function set_sharpness(v:Float):Float
	{
		if (flashField.sharpness != v)
		{
			flashField.sharpness = v;
			needRedraw = true;
		}
		return v;
	}
	
	public var gridFitType(get_gridFitType, set_gridFitType):GridFitType;
	
	function get_gridFitType():GridFitType
	{
		return flashField.gridFitType;
	}
	
	function set_gridFitType(v:GridFitType):GridFitType
	{
		if (flashField.gridFitType != v)
		{
			flashField.gridFitType = v;
			needRedraw = true;
		}
		return v;
	}
	
	public var antiAliasType(get_antiAliasType, set_antiAliasType):AntiAliasType;
	
	function get_antiAliasType():AntiAliasType
	{
		return flashField.antiAliasType;
	}
	
	function set_antiAliasType(v:AntiAliasType):AntiAliasType
	{
		if (flashField.antiAliasType != v)
		{
			flashField.antiAliasType = v;
			needRedraw = true;
		}
		return v;
	}
	
	override public function drawStep(camera:Camera2D):Void 
	{
		if (needRedraw) updateField();
		super.drawStep(camera);
	}
	
	override public function dispose():Void 
	{
		super.dispose();
		flashField = null;
		Reflect.setField(this, "textFormat", null);
	}
	
	function updateField():Void
	{
		flashField.defaultTextFormat = textFormat;
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
		
		texture = FlashTexture2D.fromDisplayObject(flashField);
		
		needRedraw = false;
	}
	
}
