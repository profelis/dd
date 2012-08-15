package deep.dd.texture;

import flash.geom.Matrix3D;
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
        region = new Vector3D(0, 0, 1, 1);
    }

    public static function fromBitmap(bmp:BitmapData, options:UInt = Texture2DOptions.QUALITY_ULTRA):Texture2D
    {
        var res = new Texture2D(options);
        res.bitmapData = bmp;
        res.width = res.bitmapWidth = bmp.width;
        res.height = res.bitmapHeight = bmp.height;
        res.textureWidth = getNextPowerOfTwo(res.bitmapWidth);
        res.textureHeight = getNextPowerOfTwo(res.bitmapHeight);

        res.region.z = res.bitmapWidth / res.textureWidth;
        res.region.w = res.bitmapHeight / res.textureHeight;

        return res;
    }

    /**
     * @private
    **/
    public var useCount:Int = 0;
    public var cache(default, null):Cache;


    public var releaseBitmap(default, #if debug set_releaseBitmap #else default #end):Bool = false;

    #if debug
    function set_releaseBitmap(v)
    {
        if (cache != null) throw "releaseBitmap conflict with cache";
        return releaseBitmap = v;
    }
    #end

    var bitmapData:BitmapData;

    // preferred size
    public var width(default, null):Float;
    public var height(default, null):Float;

    // bitmap texture size
    public var bitmapWidth(default, null):Int;
    public var bitmapHeight(default, null):Int;

    // texture size 2^n
    public var textureWidth(default, null):Int;
    public var textureHeight(default, null):Int;

    // region of bitmap texture
    public var region(default, null):Vector3D;

    // transparent border (xy - px offset)
    public var border(default, null):Rectangle;
    public var borderMatrix(default, null):Matrix3D;

    public var texture(default, null):Texture;

    function updateFrameMatrix()
    {
        if (borderMatrix == null) borderMatrix = new Matrix3D();
        else borderMatrix.identity();

        borderMatrix.appendScale(width / border.width, height / border.width, 1);
        borderMatrix.appendTranslation(border.x, border.y, 0);
    }

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

        texture = ctx.createTexture(textureWidth, textureHeight, Context3DTextureFormat.BGRA, false);

        var b = bitmapData;
        var rescale = textureWidth != bitmapWidth || textureHeight != bitmapHeight;
        if (rescale)
        {
            b = new BitmapData(textureWidth, textureHeight, true, 0x00000000);
            b.copyPixels(bitmapData, bitmapData.rect, new Point());
        }

        texture.uploadFromBitmapData(b);

        if ((options & Texture2DOptions.MIPMAP_LINEAR) | (options & Texture2DOptions.MIPMAP_NEAREST) > 0)
        {
            var w:Int = textureWidth >> 1;
            var h:Int = textureHeight >> 1;
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

        if (cache == null)
        {
            bitmapData = null;
            region = null;
        }
        else
        {
            if (texture != null)
            {
                texture.dispose();
                texture = null;
            }
            ctx = null;
        }
	}

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
