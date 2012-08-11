package deep.hxd.texture;

import flash.geom.Vector3D;
import flash.geom.Point;
import flash.display3D.Context3DTextureFormat;
import flash.display.BitmapData;
import flash.display3D.Context3D;
import flash.display3D.textures.Texture;

class Texture2D
{
    public function new()
    {
    }

    public static function fromBitmap(bmp:BitmapData):Texture2D
    {
        var res = new Texture2D();
        res.bitmapData = bmp;
        res.bw = bmp.width;
        res.bh = bmp.height;

        return res;
    }

    var bitmapData:BitmapData;

    public var bw(default, null):Int;
    public var bh(default, null):Int;
    var tw:Int;
    var th:Int;

    public var region(get_region, null):Vector3D;

    function get_region():Vector3D
    {
        return region;
    }

    public function init(ctx:Context3D)
    {
        if (texture == null)
        {
            tw = getNextPowerOfTwo(bw);
            th = getNextPowerOfTwo(bh);

            texture = ctx.createTexture(tw, th, Context3DTextureFormat.BGRA, false);
            region = new Vector3D(0, 0, 1, 1);

            var b = bitmapData;
            if (tw != bw || th != bh)
            {
                b = new BitmapData(tw, th, true, 0x00000000);
                b.copyPixels(bitmapData, bitmapData.rect, new Point());
                region.z = bw / tw;
                region.w = bh / th;
            }

            texture.uploadFromBitmapData(b);
            // TODO: mipmaping
        }
    }

    public var texture(default, null):Texture;


    public static function getNextPowerOfTwo(number:Int):Int
    {
        if (number > 0 && (number & (number - 1)) == 0) // see: http://goo.gl/D9kPj
        {
            return number;
        }
        else
        {
            var result = 1;
            while (result < number) result <<= 1;
            return result;
        }
    }
}
