package deep.dd.display;
import deep.dd.animation.Animator;
import deep.dd.camera.Camera2D;
import deep.dd.texture.atlas.FontAtlasTexture2D;
import deep.dd.utils.Frame;
import flash.text.TextFormatAlign;

/**
 * ...
 * @author Zaphod
 */

class BitmapFont2D extends Node2D
{
	var textContainer:Sprite2D;
	var needUpdate:Bool = true;
	var spriteStorage:Array<Sprite2D>;
	
	public function new(cont:Sprite2D, fieldWidth:Int = 100) 
	{
		super();
		#if debug
		if (!Std.is(cont, Cloud2D) && !Std.is(cont, Batch2D))
		{
			throw "cont should be Cloud2D or Batch2D. Instances of other classes not supported";
		}
		#end
		
		spriteStorage = [];
		textContainer = cont;
		textContainer.animator = new Animator(60);
		this.addChild(cont);
		this.fieldWidth = fieldWidth;
		this.align = TextFormatAlign.LEFT;
	}
	
	public var font(get_font, set_font):FontAtlasTexture2D;
	
	function get_font():FontAtlasTexture2D
	{
		if (textContainer.texture != null)
		{
			return cast(textContainer.texture, FontAtlasTexture2D);
		}
		return null;
	}
	
	function set_font(f:FontAtlasTexture2D):FontAtlasTexture2D
	{
		if (textContainer.texture != f)
		{
			textContainer.texture = f;
			needUpdate = true;
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
		}
		
		return t;
	}
	
	public var align(default, set_align):TextFormatAlign;
	
	function set_align(v:TextFormatAlign):TextFormatAlign
	{
		if (align != v)
		{
			align = v;
			needUpdate = true;
		}
		return v;
	}
	
	public var padding(default, set_padding):Int = 0;
	
	function set_padding(pad:Int):Int
	{
		if (padding != pad)
		{
			padding = pad;
			needUpdate = true;
		}
		return pad;
	}
	
	public var lineSpacing(default, set_lineSpacing):Int = 0;
	
	function set_lineSpacing(spacing:Int):Int
	{
		if (lineSpacing != spacing)
		{
			lineSpacing = spacing;
			needUpdate = true;
		}
		return spacing;
	}
	
	public var letterSpacing(default, set_letterSpacing):Int = 0;
	
	function set_letterSpacing(spacing:Int):Int
	{
		if (letterSpacing != spacing)
		{
			letterSpacing = spacing;
			needUpdate = true;
		}
		return spacing;
	}
	
	public var fontScale(default, set_fontScale):Float = 1.0;
	
	function set_fontScale(scale:Float):Float
	{
		if (fontScale != scale)
		{
			fontScale = scale;
			needUpdate = true;
		}
		return scale;
	}
	
	public var autoUpperCase(default, set_autoUpperCase):Bool = false;
	
	function set_autoUpperCase(toUpper:Bool):Bool
	{
		if (autoUpperCase != toUpper)
		{
			autoUpperCase = toUpper;
			needUpdate = true;
		}
		return toUpper;
	}
	
	public var wordWrap(default, set_wordWrap):Bool = false;
	
	function set_wordWrap(wrap:Bool):Bool
	{
		if (wordWrap != wrap)
		{
			wordWrap = wrap;
			needUpdate = true;
		}
		return wrap;
	}
	
	public var fixedWidth(default, set_fixedWidth):Bool = true;
	
	function set_fixedWidth(fixed:Bool):Bool
	{
		if (fixedWidth != fixed)
		{
			fixedWidth = fixed;
			needUpdate = true;
		}
		return fixed;
	}
	
	public var multiLine(default, set_multiLine):Bool = false;
	
	function set_multiLine(multi:Bool):Bool
	{
		if (multiLine != multi)
		{
			multiLine = multi;
			needUpdate = true;
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
		}
		return w;
	}
	
	public var numSpacesInTab(default, set_numSpacesInTab):Int = 4;
	
	var tabSpaces:String = "    ";
	
	function set_numSpacesInTab(num:Int):Int
	{
		if (numSpacesInTab != num)
		{
			numSpacesInTab = num;
			
			tabSpaces = "";
			for (i in 0...numSpacesInTab)
			{
				tabSpaces += " ";
			}
			
			needUpdate = true;
		}
		
		return num;
	}
	
	/**
	 * Get symbol sprite
	 * @param	pos
	 * @return
	 */
	/*public function getGlyphAt(pos:Int):Sprite2D
	{
		
	}*/
	
	override public function drawStep(camera:Camera2D):Void 
	{
		if (needUpdate) updateField();
		super.drawStep(camera);
	}
	
	function updateField():Void
	{
		if (needUpdate)
		{
			if (font == null) return;
			
			var preparedText:String = (autoUpperCase) ? text.toUpperCase() : text;
			var calcFieldWidth:Int = fieldWidth;
			var rows:Array<String> = [];
			
			// TODO: Handle tabs later in this method. This is stub
			var textWithoutTabs:String = text.split("\t").join(tabSpaces);
			
			// cut text into pices
			var lineComplete:Bool;
			
			// get words
			var lines:Array<String> = textWithoutTabs.split("\n");
			var i:Int = -1;
			var j:Int = -1;
			if (!multiLine)
			{
				lines = [lines[0]];
			}
			
			var wordLength:Int;
			var word:String;
			var tempStr:String;
			
			while (++i < lines.length) 
			{
				if (fixedWidth)
				{
					lineComplete = false;
					var words:Array<String> = lines[i].split(" ");
					
					if (words.length > 0) 
					{
						var wordPos:Int = 0;
						var txt:String = "";
						while (!lineComplete) 
						{
							word = words[wordPos];
							var currentRow:String = txt + word + " ";
							var changed:Bool = false;
							
							if (wordWrap)
							{
								if (font.getTextWidth(currentRow, letterSpacing, fontScale) > fieldWidth)
								{
									if (txt == "")
									{
										words.splice(0, 1);
									}
									else
									{
										rows.push(txt.substr(0, txt.length - 1));
									}
									
									txt = "";
									if (multiLine)
									{
										words.splice(0, wordPos);
									}
									else
									{
										words.splice(0, words.length);
									}
									wordPos = 0;
									changed = true;
								}
								else
								{
									txt += word + " ";
									wordPos++;
								}
							}
							else
							{
								if (font.getTextWidth(currentRow, letterSpacing, fontScale) > fieldWidth)
								{
									j = 0;
									tempStr = "";
									wordLength = word.length;
									while (j < wordLength)
									{
										currentRow = txt + word.charAt(j);
										if (font.getTextWidth(currentRow, letterSpacing, fontScale) > fieldWidth)
										{
											rows.push(txt.substr(0, txt.length - 1));
											txt = "";
											word = "";
											wordPos = words.length;
											j = wordLength;
											changed = true;
										}
										else
										{
											txt += word.charAt(j);
										}
										j++;
									}
								}
								else
								{
									txt += word + " ";
									wordPos++;
								}
							}
							
							if (wordPos >= words.length) 
							{
								if (!changed) 
								{
									var subText:String = txt.substr(0, txt.length - 1);
									calcFieldWidth = Math.floor(Math.max(calcFieldWidth, font.getTextWidth(subText, letterSpacing, fontScale)));
									rows.push(subText);
								}
								lineComplete = true;
							}
						}
					}
					else
					{
						rows.push("");
					}
				}
				else
				{
					calcFieldWidth = Math.floor(Math.max(calcFieldWidth, font.getTextWidth(lines[i], letterSpacing, fontScale)));
					rows.push(lines[i]);
				}
			}
			
			var finalWidth:Float = calcFieldWidth + padding * 2;
			
			var numSpaces:Int;
			var textLength:Int;
			var childsNeeded:Int = 0;
			for (t in rows) 
			{
				textLength = t.length;
				if (font.hasSpaceGlyph)
				{
					childsNeeded += textLength;
				}
				else
				{
					numSpaces = t.split(" ").length - 1;
					childsNeeded += textLength - numSpaces;
				}
			}
			
			while (Std.int(textContainer.numChildren) < childsNeeded)
			{
				var c:Sprite2D = null; 
				if (spriteStorage.length > 0)
				{
					c = spriteStorage.pop();
					if (c.texture != font)
					{
						c.texture = font;
					}
				}
				else
				{
					c = new Sprite2D();
					var an:Animator = cast textContainer.animator.copy();
					c.animator = an;
				}
				textContainer.addChild(c);
			}
			
			if (Std.int(textContainer.numChildren) > childsNeeded)
			{
				var numChildrenToRemove:Int = textContainer.numChildren - childsNeeded;
				var childrenToRemove:Array<Sprite2D> = [];
				
				for (c in textContainer.iterator())
				{
					childrenToRemove.push(cast(c, Sprite2D));
					numChildrenToRemove--;
					if (numChildrenToRemove <= 0) break;
				}
				
				for (c in childrenToRemove)
				{
					textContainer.removeChild(c);
					spriteStorage.push(c);
				}
				childrenToRemove = null;
			}
			
			var glyphInfo:Array<GlyphInfo> = [];
			
			// render text
			var row:Int = 0;
			
			for (t in rows) 
			{
				var ox:Float = 0; // LEFT
				var oy:Float = 0;
				
				if (align == TextFormatAlign.CENTER) 
				{
					if (fixedWidth)
					{
						ox = (fieldWidth - font.getTextWidth(t, letterSpacing, fontScale)) / 2;
					}
					else
					{
						ox = (finalWidth - font.getTextWidth(t, letterSpacing, fontScale)) / 2;
					}
				}
				if (align == TextFormatAlign.RIGHT) 
				{
					if (fixedWidth)
					{
						ox = fieldWidth - font.getTextWidth(t, letterSpacing, fontScale);
					}
					else
					{
						ox = finalWidth - font.getTextWidth(t, letterSpacing, fontScale) - 2 * padding;
					}
				}
				
				buildTextFromSprites(glyphInfo, t, ox + padding, oy + row * (font.fontHeight * fontScale + lineSpacing) + padding);
				row++;
			}
			
			var pos:Int = 0;
			var info:GlyphInfo;
			for (c in textContainer.iterator())
			{
				info = glyphInfo[pos];
				cast(cast(c, Sprite2D).animator).gotoFrame(info.symbol);
				c.x = info.x;
				c.y = info.y;
				c.scaleX = c.scaleY = fontScale;
				pos++;
			}
		}
		
		needUpdate = false;
	}
	
	function buildTextFromSprites(glyphInfo:Array<GlyphInfo>, lineText:String, startX:Float, startY:Float):Void
	{
		var glyph:Frame;
		var glyphWidth:Float;
		
		var glyphX:Float = startX;
		var glyphY:Float = startY;
		var glyphWidth:Float = 0;
		var char:String;
		
		for (i in 0...lineText.length)
		{
			char = lineText.charAt(i);
			glyph = font.getFrameByName(char);
			if (glyph != null)
			{
				if (glyph.border != null)
				{
					glyphWidth = glyph.border.width;
				}
				else
				{
					glyphWidth = glyph.width;
				}
				glyphInfo.push(new GlyphInfo(glyphX, glyphY, char));
				glyphX += glyphWidth * fontScale + letterSpacing;
			}
			else if (char == " ")
			{
				glyphX += font.spaceWidth * fontScale + letterSpacing;
			}
		}
	}
	
	override public function dispose():Void 
	{
		super.dispose();
		textContainer = null;
		for (s in spriteStorage)
		{
			s.dispose();
		}
		spriteStorage = null;
	}
	
}

class GlyphInfo
{
	public var x:Float;
	public var y:Float;
	public var symbol:String;
	
	public function new(x:Float, y:Float, symbol:String)
	{
		this.x = x;
		this.y = y;
		this.symbol = symbol;
	}
}