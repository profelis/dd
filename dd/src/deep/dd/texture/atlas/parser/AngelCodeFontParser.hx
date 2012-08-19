package deep.dd.texture.atlas.parser;

import deep.dd.texture.Frame;
import deep.dd.texture.Texture2D;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.geom.Point;
import deep.dd.texture.atlas.AtlasTexture2D;

/**
* Parser for Bitmap fonts in AngelCode format.
* You can use following programs to create fonts in this format:
* - Bitmap Font Generator (http://www.angelcode.com/products/bmfont/) - windows only and free
* - Glyph Designer (http://glyphdesigner.71squared.com/) - mac only, about $30
* - bmGlyph (http://www.bmglyph.com/) - mac only, about $10
**/
class AngelCodeFontParser implements IAtlasParser
{
    var data:Xml;

    public function new(data:Xml)
    {
        this.data = data;
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
					var border:Rectangle = new Rectangle(xoffset, yoffset, xadvance, yoffset + height);
					if (name != " ")
					{
						frames.push(new Frame(width, height, new Vector3D(x * kx, y * ky, width * kx, height * ky), border, name));
					}
					else
					{
						// TODO: handle space symbol which can have zero width and height (causes error).
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

        return frames;
    }
}
