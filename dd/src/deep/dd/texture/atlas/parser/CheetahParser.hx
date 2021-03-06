package deep.dd.texture.atlas.parser;

/**
*  @author Dima Granetchi <system.grand@gmail.com>, <deep@e-citrus.ru>
*/

import deep.dd.utils.Frame;
import deep.dd.texture.Texture2D;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.geom.Point;
import deep.dd.texture.atlas.AtlasTexture2D;

/**
* Парсер для атласного упаковщика Cheetah https://github.com/scriptum/Cheetah-Texture-Packer
* @lang ru
**/

/**
* Parser for https://github.com/scriptum/Cheetah-Texture-Packer
* @lang en
**/
class CheetahParser implements IAtlasParser
{
    var data:String;

    public function new(data:String)
    {
        this.data = data;
    }

    inline function q(v:String)
    {
        return Std.parseInt(v);
    }

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

        return frames;
    }
}
