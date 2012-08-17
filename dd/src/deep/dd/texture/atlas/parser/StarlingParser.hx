package deep.dd.texture.atlas.parser;

import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.geom.Point;
import deep.dd.texture.atlas.AtlasTexture2D;

/**
* Parser for texture atlases in Starling format
**/
class StarlingParser implements IAtlasParser
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
		
		var kx = 1 / a.textureWidth;
        var ky = 1 / a.textureHeight;
		
		var subtextures:Xml = null;
		for (node in data.elements())
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
		}

		var f = frames[0];
        size = new Point(f.width, f.height);
        return frames;
    }

    public function getPreferredSize():Point
    {
        return size;
    }
}
