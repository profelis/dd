package deep.dd.texture;

import flash.geom.Matrix;
import flash.geom.Rectangle;
import deep.dd.utils.Cache;
import flash.geom.Vector3D;
import flash.geom.Point;
import flash.display3D.Context3DTextureFormat;
import flash.display.BitmapData;
import flash.display3D.Context3D;
import flash.display3D.textures.Texture;

class Texture2D
{
    public var options(default, null):UInt;

	public function new(options:UInt)
    {
        this.options = options;
    }

    public static function fromBitmap(bmp:BitmapData, options:UInt = Texture2DOptions.QUALITY_ULTRA):Texture2D
    {
        var res = new Texture2D(options);
        res.bitmapData = bmp;
        res.bw = bmp.width;
        res.bh = bmp.height;

        return res;
    }

    /**
     * @private
    **/
    public var useCount:Int = 0;
    public var cache:Cache;


    public var releaseBitmap(default, #if debug set_releaseBitmap #else default #end):Bool = false;

    #if debug
    function set_releaseBitmap(v)
    {
        if (cache != null) throw "releaseBitmap conflict with cache";
        return releaseBitmap = v;
    }
    #end

    var bitmapData:BitmapData;

    public var bw(default, null):Int;
    public var bh(default, null):Int;
    var tw:Int;
    var th:Int;

    public var needUpdate:Bool = false;

    public function update()
    {
        needUpdate = false;
    }

    public var region(default, null):Vector3D;

    var ctx:Context3D;

    public function init(ctx:Context3D)
    {
        if (this.ctx == ctx) return;

        this.ctx = ctx;

		if (texture != null)
		{
			texture.dispose();
			texture = null;
		}

        tw = getNextPowerOfTwo(bw);
        th = getNextPowerOfTwo(bh);

        texture = ctx.createTexture(tw, th, Context3DTextureFormat.BGRA, false);
        region = new Vector3D(0, 0, 1, 1);

        var b = bitmapData;
        var rescale = tw != bw || th != bh;
        if (rescale)
        {
            b = new BitmapData(tw, th, true, 0x00000000);
            b.copyPixels(bitmapData, bitmapData.rect, new Point());
            region.z = bw / tw;
            region.w = bh / th;
        }

        texture.uploadFromBitmapData(b);

        if ((options & Texture2DOptions.MIPMAP_LINEAR) | (options & Texture2DOptions.MIPMAP_NEAREST) > 0)
        {
            var w:Int = tw >> 1;
            var h:Int = th >> 1;
            var l = 0;
            var r = new Rectangle();
            var t = new Matrix();

            var tmp = b.clone();

            while (w >= 1 || h >= 1)
            {
                l ++;
                r.width = w;
                r.height = h;
                t.scale(0.5, 0.5);

                tmp.fillRect(r, 0x00000000);
                tmp.draw(b, t, null, null, null, true);

                texture.uploadFromBitmapData(tmp, l);

                w >>= 1;
                h >>= 1;
            }

            tmp.dispose();
        }

        if (rescale) b.dispose();

        if (cache != null)
        {
            cache.releaseBitmap(bitmapData);
        }
        else if (releaseBitmap)
        {
            bitmapData.dispose();
        }
    }
	
	public function dispose():Void
	{
        if (useCount > 0) return;

        if (texture == null)
        {
            if (cache != null) cache.releaseBitmap(bitmapData);
        }
        else
        {
            texture.dispose();
            texture = null;
        }
		bitmapData = null;
		region = null;
        cache = null;
	}

    public var texture(default, null):Texture;

    public static function getNextPowerOfTwo(n:Int):Int
    {
        if (n > 0 && (n & (n - 1)) == 0) // see: http://goo.gl/D9kPj
        {
            return n;
        }
        else
        {
            var result = 1;
            while (result < n) result <<= 1;
            return result;
        }
    }
}

// ND2D thanks
class Texture2DOptions
{

    // defines how and if mip mapping should be used
    public static inline var MIPMAP_DISABLE = 1;
    public static inline var MIPMAP_NEAREST = 2;
    public static inline var MIPMAP_LINEAR = 4;

    // texture filtering methods
    public static inline var FILTERING_NEAREST = 8;
    public static inline var FILTERING_LINEAR = 16;

    // texture repeat
    public static inline var REPEAT_NORMAL = 32;
    public static inline var REPEAT_CLAMP = 64;

    // predefined presets
    public static inline var QUALITY_LOW = MIPMAP_DISABLE | FILTERING_NEAREST | REPEAT_NORMAL;
    public static inline var QUALITY_MEDIUM = MIPMAP_DISABLE | FILTERING_LINEAR | REPEAT_NORMAL;
    public static inline var QUALITY_HIGH = MIPMAP_NEAREST | FILTERING_LINEAR | REPEAT_NORMAL;
    public static inline var QUALITY_ULTRA = MIPMAP_LINEAR | FILTERING_LINEAR | REPEAT_NORMAL;
}
