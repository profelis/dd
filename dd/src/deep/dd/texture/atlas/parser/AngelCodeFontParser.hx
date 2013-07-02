package deep.dd.texture.atlas.parser;

/**
*  @author Zaphod
*/

import deep.dd.texture.atlas.FontAtlasTexture2D;
import deep.dd.utils.Frame;
import deep.dd.texture.Texture2D;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import deep.dd.texture.atlas.AtlasTexture2D;

/**
* Parser for Bitmap fonts in AngelCode format.
* You can use following programs to create fonts in this format:
* - Bitmap Font Generator (http://www.angelcode.com/products/bmfont/) - windows only and free
* - Glyph Designer (http://glyphdesigner.71squared.com/) - mac only, about $30
* - bmGlyph (http://www.bmglyph.com/) - mac only, about $10
**/
class AngelCodeFontParser implements IFontAtlasParser
{
    var data:Xml;
	
	var padding:Float;

    public function new(data:Xml, padding = 0.0)
    {
        this.data = data;
        this.padding = padding;
    }

    inline function q(v:String)
    {
       return Std.parseInt(v);
    }

    public function parse(a:AtlasTexture2D):Array<Frame>
    {
        var frames:Array<Frame> = [];
		
		var kx = 1 / a.textureWidth;
        var ky = 1 / a.textureHeight;
		
		var maxHeight:Int = 0;
		
		var chars:Xml = null;
		for (node in data.elements())
		{
			if (node.nodeName == "font")
			{
				for (nodeChild in node.elements())
				{
					if (nodeChild.nodeName == "chars")
					{
						chars = nodeChild;
						break;
					}
				}
			}
		}
		
		if (chars != null)
		{
			for (node in chars.elements())
			{
				if (node.nodeName == "char")
				{
					var charCode:Int = q(node.get("id"));
					var name:String = String.fromCharCode(charCode);
					var x:Int = q(node.get("x"));
					var y:Int = q(node.get("y"));
					var width:Int = q(node.get("width"));
					var height:Int = q(node.get("height"));
					var xoffset:Int = q(node.get("xoffset"));
					var yoffset:Int = q(node.get("yoffset"));
					var xadvance:Int = q(node.get("xadvance"));
					
					var w = width - padding * 2;
					var h = height - padding * 2;
					var rw = w * kx;
					var rh = h * ky;

					var symbolHeight:Int = height + yoffset;
					
					var border:Rectangle = new Rectangle(xoffset + padding, yoffset + padding, xadvance, yoffset + height);
					if (name != " " || (width > 0 && height > 0))
					{
						if (w > 0 && h > 0)
						{
							frames.push(new Frame(w, h, new Vector3D((x + padding) * kx, (y + padding) * ky, rw, rh), border, name));
							if (symbolHeight > maxHeight)
							{
								maxHeight = symbolHeight;
							}
						}
					}
					if (name == " ")
					{
						spaceWidth = xadvance;
						
						if (w > 0 && h > 0)
						{
							hasSpaceGlyph = true;
							trace("hasSpaceGlyph = true");
						}
					}
				}
			}
		}
		#if debug
		else
		{
			throw "Wrong file format. This isn't AngelCode font";
		}
		#end
		
		fontHeight = maxHeight;

        return frames;
    }

    public var spaceWidth(default, null):Int = 0;
    public var fontHeight(default, null):Int = 0;
    public var hasSpaceGlyph(default, null):Bool = false;
}
