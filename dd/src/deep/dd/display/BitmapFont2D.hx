package deep.dd.display;
import deep.dd.animation.Animator;
import deep.dd.texture.atlas.FontAtlasTexture2D;
import flash.text.TextFormatAlign;

/**
 * ...
 * @author Zaphod
 */

class BitmapFont2D extends Node2D
{
	var textContainer:Sprite2D;
	var needUpdate:Bool = true;
	
	public function new(cont:Sprite2D) 
	{
		super();
		#if debug
		if (!Std.is(cont, Cloud2D) && !Std.is(cont, Batch2D))
		{
			throw "cont should be Cloud2D or Batch2D. Instances of other classes not supported";
		}
		#end
		
		textContainer = cont;
		textContainer.animator = new Animator(1);
		this.addChild(cont);
	}
	
	public var font(get_font, set_font):FontAtlasTexture2D;
	
	function get_font():FontAtlasTexture2D
	{
		return cast(textContainer, FontAtlasTexture2D);
	}
	
	function set_font(f:FontAtlasTexture2D):FontAtlasTexture2D
	{
		if (textContainer.texture != f)
		{
			textContainer.texture = f;
			needUpdate = true;
			updateField();
		}
		
		return f;
	}
	
	public var text(default, set_text):String = "";
	
	function set_text(t:String):String
	{
		if (text != t)
		{
			text = t;
			needUpdate = true;
			updateField();
		}
		
		return t;
	}
	
	public var align(default, set_align):String;
	
	function set_align(v:String):String
	{
		if (align != v)
		{
			align = v;
			needUpdate = true;
			updateField();
		}
		return v;
	}
	
	public var padding(default, set_padding):Int;
	
	function set_padding(pad:Int):Int
	{
		if (padding != pad)
		{
			padding = pad;
			needUpdate = true;
			updateField();
		}
		return pad;
	}
	
	public var lineSpacing(default, set_lineSpacing):Int;
	
	function set_lineSpacing(spacing:Int):Int
	{
		if (lineSpacing != spacing)
		{
			lineSpacing = spacing;
			needUpdate = true;
			updateField();
		}
		return spacing;
	}
	
	public var letterSpacing(default, set_letterSpacing):Int;
	
	function set_letterSpacing(spacing:Int):Int
	{
		if (letterSpacing != spacing)
		{
			letterSpacing = spacing;
			needUpdate = true;
			updateField();
		}
		return spacing;
	}
	
	public var fontScale(default, set_fontScale):Float;
	
	function set_fontScale(scale:Float):Float
	{
		if (fontScale != scale)
		{
			fontScale = scale;
			needUpdate = true;
			updateField();
		}
		return scale;
	}
	
	public var autoUpperCase(default, set_autoUpperCase):Bool;
	
	function set_autoUpperCase(toUpper:Bool):Bool
	{
		if (autoUpperCase != toUpper)
		{
			autoUpperCase = toUpper;
			needUpdate = true;
			updateField();
		}
		return toUpper;
	}
	
	public var wordWrap(default, set_wordWrap):Bool;
	
	function set_wordWrap(wrap:Bool):Bool
	{
		if (wordWrap != wrap)
		{
			wordWrap = wrap;
			needUpdate = true;
			updateField();
		}
		return wrap;
	}
	
	public var fixedWidth(default, set_fixedWidth):Bool;
	
	function set_fixedWidth(fixed:Bool):Bool
	{
		if (fixedWidth != fixed)
		{
			fixedWidth = fixed;
			needUpdate = true;
			updateField();
		}
		return fixed;
	}
	
	public var multiLine(default, set_multiLine):Bool;
	
	function set_multiLine(multi:Bool):Bool
	{
		if (multiLine != multi)
		{
			multiLine = multi;
			needUpdate = true;
			updateField();
		}
		return multi;
	}
	
	public var fieldWidth(default, set_fieldWidth):Int;
	
	function set_fieldWidth(w:Int):Int
	{
		if (fieldWidth != w)
		{
			fieldWidth = w;
			needUpdate = true;
			updateField();
		}
		return w;
	}
	
	/**
	 * Get symbol sprite
	 * @param	pos
	 * @return
	 */
	/*public function getGlyphAt(pos:Int):Sprite2D
	{
		
	}*/
	
	function updateField():Void
	{
		if (needUpdate)
		{
			/*if (text == "") return;
			var c:Sprite2D = new Sprite2D();
			var an:Animator = cast textContainer.animator.copy();
			c.animator = an;
			an.gotoFrame(text.charAt(0));
			textContainer.addChild(c);*/
		}
		
		needUpdate = false;
	}
	
	override public function dispose():Void 
	{
		super.dispose();
		textContainer = null;
		
		
	}
	
}