package deep.dd.texture.atlas.parser;

import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.geom.Point;
import deep.dd.texture.atlas.AtlasTexture2D;

/**
* Parser for https://github.com/scriptum/Cheetah-Texture-Packer
**/
class CheetahParser implements IAtlasParser
{
    var data:String;

    public function new(data:String)
    {
        this.data = data;
        trace(data);
    }

    inline function q(v:String)
    {
        return Std.parseInt(v);
    }

    var size:Point;

    public function parse(a:AtlasTexture2D):Array<Frame>
    {
        var frames = [];

        var ls = data.split("\n");
        if (StringTools.startsWith(ls[0], "textures:")) ls.shift();

        var kx = 1 / a.textureWidth;
        var ky = 1 / a.textureHeight;

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

        var f = frames[0];
        size = (f.border != null) ? new Point(f.border.width, f.border.height) : new Point(f.width, f.height);

        return frames;
    }

    public function getPreferredSize():Point
    {
        return size;
    }
}
