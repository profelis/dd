package deep.dd.texture.atlas.parser;

import deep.dd.texture.Frame;
import deep.dd.texture.Texture2D;
import flash.geom.Rectangle;
import flash.geom.Point;
import deep.dd.texture.atlas.AtlasTexture2D;
import flash.geom.Vector3D;

class SpriteSheetParser implements IAtlasParser
{
    var iw:Float;
    var ih:Float;
    var padding:Float;

    public function new(itemWidth:Float, itemHeight:Float, padding = 0.0)
    {
        iw = itemWidth;
        ih = itemHeight;
        this.padding = padding;
    }

    public function parse(a:AtlasTexture2D):Array<Frame>
    {
        var frames:Array<Frame> = [];

        var x = 0.0;
        var y = 0.0;

        var kx = 1 / a.textureWidth;
        var ky = 1 / a.textureHeight;

        var w = iw - padding * 2;
        var h = ih - padding * 2;

        var rw = w * kx;
        var rh = h * ky;

        frames = new Array();
        var bw = a.bitmapWidth;
        var bh = a.bitmapHeight;

        var border:Rectangle = padding > 0 ? new Rectangle(padding, padding, iw, ih) : null;
        while (x < bw)
        {
            y = 0.0;
            while (y < bh)
            {
                frames.push(new Frame(w, h, new Vector3D((x+padding) * kx, (y+padding) * ky, rw, rh), border));
                y += ih;
            }
            x += iw;
        }

        return frames;
    }
}
