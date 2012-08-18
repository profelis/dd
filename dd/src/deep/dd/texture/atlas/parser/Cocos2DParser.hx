package deep.dd.texture.atlas.parser;

import deep.dd.texture.Texture2D;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.geom.Point;
import deep.dd.texture.atlas.AtlasTexture2D;

/**
* Parser for texture atlases in Starling format
**/
class Cocos2DParser implements IAtlasParser
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

    var size:Point;

    public function parse(a:AtlasTexture2D):Array<Frame>
    {
		var frames:Array<Frame> = [];
		
		for (node in data.elements())
		{
			if (node.nodeName == "plist")
			{
				for (nodeChild in node.elements())
				{
					if (nodeChild.nodeName == "dict")
					{
						#if debug
						findMetadata(nodeChild);
						#end
						
						frames = findFrames(a, nodeChild);
					}
				}
			}
		}
		
		var kx = 1 / a.textureWidth;
        var ky = 1 / a.textureHeight;
		
		/*for (node in data.elements())
		{
			if (node.nodeName == "TextureAtlas")
			{
				for (nodeChild in node.elements())
				{
					if (nodeChild.nodeName == "SubTexture")
					{
						var name:String = nodeChild.get("name");
						var x:Int = q(nodeChild.get("x"));
						var y:Int = q(nodeChild.get("y"));
						var width:Int = q(nodeChild.get("width"));
						var height:Int = q(nodeChild.get("height"));
						var frameWidth:Int = q(nodeChild.get("frameWidth"));
						var frameHeight:Int = q(nodeChild.get("frameHeight"));
						var border:Rectangle = null;
						
						if (width != frameWidth || height != frameHeight)
						{
                            var frameX:Int = -q(nodeChild.get("frameX"));
                            var frameY:Int = -q(nodeChild.get("frameY"));
							border = new Rectangle(frameX, frameY, frameWidth, frameHeight);
						}
						frames.push(new Frame(width, height, new Vector3D(x * kx, y * ky, width * kx, height * ky), border, name));
					}
				}
			}
		}*/
		
		#if debug
		if (frames.length == 0) throw "There is no frames in texture atlas";
		#end
		
		var f = frames[0];
        size = new Point(f.width, f.height);
		
        return frames;
    }
	
	private function findFrames(a:AtlasTexture2D, xml:Xml):Array<Frame>
	{
		var frames:Array<Frame> = [];
		
		var kx:Float = 1 / a.textureWidth;
        var ky:Float = 1 / a.textureHeight;
		
		var framesFound:Bool = false;
		
		for (node in xml.elements())
		{
			if (!framesFound)
			{
				if (node.nodeName == "key" && node.firstChild().toString() == "frames")
				{
					framesFound = true;
				}
			}
			else
			{
				var formatFound:Bool = false;
				for (nodeChild in node.elements())
				{
					if (!formatFound)
					{
						if (nodeChild.nodeName == "key" && nodeChild.firstChild().toString() == "format")
						{
							formatFound = true;
						}
					}
					else
					{
						if (nodeChild.nodeName == "integer")
						{
							var version:Int = q(nodeChild.firstChild().toString());
							
							if (version == 1 || version == 2) 
							{
							//	return;
							}
							else
							{
								throw "Unsupported version of Cocos2D texture atlas format";
							}
						}
					}
				}
				
				break;
			}
		}
		
		return frames;
	}
	
	private function findMetadata(xml:Xml) 
	{
		var metaDataFound:Bool = false;
		
		for (node in xml.elements())
		{
			if (!metaDataFound)
			{
				if (node.nodeName == "key" && node.firstChild().toString() == "metadata")
				{
					metaDataFound = true;
				}
			}
			else
			{
				var formatFound:Bool = false;
				for (nodeChild in node.elements())
				{
					if (!formatFound)
					{
						if (nodeChild.nodeName == "key" && nodeChild.firstChild().toString() == "format")
						{
							formatFound = true;
						}
					}
					else
					{
						if (nodeChild.nodeName == "integer")
						{
							var version:Int = q(nodeChild.firstChild().toString());
							
							if (version == 1 || version == 2) 
							{
								return;
							}
							else
							{
								throw "Unsupported version of Cocos2D texture atlas format";
							}
						}
					}
				}
				
				break;
			}
		}
		
		throw "Unrecognised XML Format";
	}
	
	private function getDict(name:String, xml:Xml):Xml
	{
		return null;
	}

    public function getPreferredSize():Point
    {
        return size;
    }
}
