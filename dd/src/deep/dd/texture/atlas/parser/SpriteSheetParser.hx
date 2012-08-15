package deep.dd.texture.atlas.parser;

import flash.geom.Rectangle;
import flash.geom.Point;
import deep.dd.texture.atlas.AtlasTexture2D;
import flash.geom.Vector3D;

class SpriteSheetParser implements IAtlasParser
{
    var iw:Float;
    var ih:Float;
    var border:Float;

    public function new(itemWidth:Float, itemHeight:Float, ignoreBorder = 0.0)
    {
        iw = itemWidth;
        ih = itemHeight;
        border = ignoreBorder;
    }

    public function parse(a:AtlasTexture2D):Array<Frame>
    {
        var frames:Array<Frame> = [];

        var x = 0.0;
        var y = 0.0;

        var kx = 1 / a.textureWidth;
        var ky = 1 / a.textureHeight;

        var w = (iw - border * 2) * kx;
        var h = (ih - border * 2) * ky;

        frames = new Array();
        var bw = a.bitmapWidth;
        var bh = a.bitmapHeight;

        while (x < bw)
        {
            y = 0.0;
            while (y < bh)
            {
                frames.push(new Frame(new Vector3D((x+border) * kx, (y+border) * ky, w, h), new Rectangle(0, 40, iw, ih)));
                y += ih;
            }
            x += iw;
        }

        return frames;
    }
}
