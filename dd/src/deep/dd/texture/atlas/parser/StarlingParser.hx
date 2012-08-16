package deep.dd.texture.atlas.parser;

import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.geom.Point;
import deep.dd.texture.atlas.AtlasTexture2D;

/**
* Parser for https://github.com/scriptum/Cheetah-Texture-Packer
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
        return Std.int(Math.abs(Std.parseInt(v)));
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
						var frameX:Int = q(nodeChild.get("frameX"));
						var frameY:Int = q(nodeChild.get("frameY"));
						var frameWidth:Int = q(nodeChild.get("frameWidth"));
						var frameHeight:Int = q(nodeChild.get("frameHeight"));
						var border:Rectangle = null;
						
						if (width != frameWidth || height != frameHeight)
						{
							border = new Rectangle(frameX, frameY, frameWidth, frameHeight);
						}
						
						frames.push(new Frame(width, height, new Vector3D(x * kx, y * ky, width * kx, height * ky), border, name));
					}
				}
			}
		}

        /*
        for (l in ls)
        {
            var d = l.split("\t");
            if (d.length < 9) continue;

            var x = q(d[1]);
            var y = q(d[2]);
            var iw = q(d[3]);
            var ih = q(d[4]);
            var bw = q(d[7]);
            var bh = q(d[8]);
            var bx:Int;
            var by:Int;
            var border:Rectangle = null;
            if (bw != iw || bh != ih)
            {
                bx = q(d[5]);
                by = q(d[6]);
                border = new Rectangle(bx, by, bw, bh);
            }
            frames.push(new Frame(iw, ih, new Vector3D(x*kx, y*ky, iw*kx, ih*ky), border, d[0]));
        }

        */

		var f = frames[0];
        size = new Point(f.width, f.height);

        return frames;
    }

    public function getPreferredSize():Point
    {
        return size;
    }
}
