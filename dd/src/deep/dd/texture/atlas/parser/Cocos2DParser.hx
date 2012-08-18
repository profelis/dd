package deep.dd.texture.atlas.parser;

import deep.dd.texture.Texture2D;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.geom.Point;
import deep.dd.texture.atlas.AtlasTexture2D;

/**
* Parser for texture atlases in Cocos2D format.
* Cocos2D-original format isn't supported. So use cocos2D or cocos2D-0.99.4
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
						
						var kx:Float = 1 / a.textureWidth;
						var ky:Float = 1 / a.textureHeight;
						frames = findFrames(nodeChild, kx, ky);
						break;
					}
				}
			}
		}
		
		#if debug
		if (frames.length == 0) throw "There is no frames in texture atlas";
		#end
		
		var f = frames[0];
        size = new Point(f.width, f.height);
		
        return frames;
    }
	
	private function findFrames(xml:Xml, kx:Float, ky:Float):Array<Frame>
	{
		var frames:Array<Frame> = [];
		var framesFound:Bool = false;
		
		for (node in xml.elements())
		{
			if (node.nodeName == "key" && node.firstChild().toString() == "metadata")
			{
				framesFound = false;
				continue;
			}
			
			if (!framesFound)
			{
				if (node.nodeName == "key" && node.firstChild().toString() == "frames" && node.firstChild().toString() != "metadata")
				{
					framesFound = true;
				}
			}
			else
			{
				var keyFrameFound:Bool = false;
				var frameName:String = "";
				var frame:Frame;
				for (nodeChild in node.elements())
				{
					if (!keyFrameFound)
					{
						if (nodeChild.nodeName == "key")
						{
							keyFrameFound = true;
							frameName = nodeChild.firstChild().toString();
						}
					}
					else
					{
						keyFrameFound = false;
						frames.push(parseFrameData(nodeChild, kx, ky, frameName));
					}
				}
			}
		}
		
		return frames;
	}
	
	private function parseFrameData(xml:Xml, kx:Float, ky:Float, frameName:String):Frame
	{
		var frame:Frame;
		var key:String = "";
		var frameData:Array<Int> = [];
		var frameOffset:Array<Int> = [];
		var sourceSize:Array<Int> = [];
		
		for (node in xml.elements())
		{
			if (node.nodeName == "key")
			{
				key = node.firstChild().toString();
			}
			else if (key != "")
			{
				switch (key)
				{
					case "frame":
						frameData = getSizeData(node.firstChild().toString());
					case "offset":
						frameOffset = getSizeData(node.firstChild().toString());
					case "rotated":
						#if debug
						if (node.nodeName == "true") throw "Rotated elements not supported";
						#end
					case "sourceSize":
						sourceSize = getSizeData(node.firstChild().toString());
				}
				
				key = "";
			}
		}
		
		var x:Int = frameData[0];
		var y:Int = frameData[1];
		var width:Int = frameData[2];
		var height:Int = frameData[3];
		
		var frameWidth:Int = sourceSize[0];
		var frameHeight:Int = sourceSize[1];
		
		var border:Rectangle = null;
		
		if (width != frameWidth || height != frameHeight)
		{
			var frameX:Int = frameOffset[0];
			var frameY:Int = frameOffset[1];
			border = new Rectangle(frameX, frameY, frameWidth, frameHeight);
		}
		
		frame = new Frame(width, height, new Vector3D(x * kx, y * ky, width * kx, height * ky), border, frameName);
		return frame;
	}
	
	private function getSizeData(str:String):Array<Int>
	{
		str = StringTools.replace(str, "{", "");
		str = StringTools.replace(str, "}", "");
		var strArr:Array<String> = str.split(",");
		var intArr:Array<Int> = [];
		for (i in 0...(strArr.length))
		{
			intArr.push(q(strArr[i]));
		}
		return intArr;
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
								throw "Cocos2D-original format isn't supported";
							}
						}
					}
				}
				
				break;
			}
		}
		
		throw "Unrecognised XML Format";
	}

    public function getPreferredSize():Point
    {
        return size;
    }
}
