package deep.dd.texture.atlas.parser;

import deep.dd.utils.Frame;
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

        var kx = 1.0 / a.textureWidth;
        var ky = 1.0 / a.textureHeight;

        var w = Math.ceil(iw - padding * 2);
        var h = Math.ceil(ih - padding * 2);

        var rw = w * kx;
        var rh = h * ky;

        frames = new Array();
        var bw = a.bitmapWidth;
        var bh = a.bitmapHeight;

        var border:Rectangle = padding > 0 ? new Rectangle(padding, padding, iw, ih) : null;
        while (y < bh)
        {
            x = 0.0;
            while (x < bw)
            {
                frames.push(new Frame(w, h, new Vector3D((x+padding) * kx, (y+padding) * ky, rw, rh), border));
                x += iw;
            }
            y += ih;
        }

        return frames;
    }
}
