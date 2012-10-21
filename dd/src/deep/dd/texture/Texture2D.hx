package deep.dd.texture;

import flash.utils.ByteArray;
import flash.geom.Vector3D;
import deep.dd.utils.Frame;
import flash.geom.Matrix3D;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import deep.dd.utils.Cache;
import flash.geom.Point;
import flash.display3D.Context3DTextureFormat;
import flash.display.BitmapData;
import flash.display3D.Context3D;
import flash.display3D.textures.Texture;

#if dd_stat
import deep.dd.utils.GlobalStatistics;
#end


class BitmapTexture2D extends Texture2D
{
    var bitmapData:BitmapData;
    var bitmapRef:Class<BitmapData>;

    public var bitmapWidth(default, null):Int;
    public var bitmapHeight(default, null):Int;

    public function new(bmp:BitmapData, options:UInt = Texture2DOptions.QUALITY_ULTRA)
    {
        bitmapData = bmp;
        bitmapWidth = bmp.width;
        bitmapHeight = bmp.height;
        textureWidth = Texture2D.getNextPowerOfTwo(bitmapWidth);
        textureHeight = Texture2D.getNextPowerOfTwo(bitmapHeight);

        super(options);

        frame = new Frame(bitmapWidth, bitmapHeight,
            new Vector3D(0, 0, bitmapWidth/textureWidth, bitmapHeight/textureHeight));
    }

    override public function dispose()
    {
        super.dispose();

        if (releaseRawData && bitmapData != null) bitmapData.dispose();

        bitmapRef = null;
        bitmapData = null;
    }

    override public function init(ctx:Context3D)
    {
        if (this.ctx == ctx) return;
        super.init(ctx);

        uploadBitmapTexture();
    }

    function uploadBitmapTexture()
    {
        memory = 0;

        texture = ctx.createTexture(textureWidth, textureHeight, Context3DTextureFormat.BGRA, false);

        if (bitmapRef != null)
        {
            try
            {
                bitmapData.getPixel(0, 0);
            }
            catch (e:Dynamic)
            {
                bitmapData = cache != null ? cache.getBitmap(bitmapRef) : Type.createInstance(bitmapRef, [0, 0]);
            }
        }
        var b = bitmapData;
        var rescale = textureWidth != bitmapWidth || textureHeight != bitmapHeight;
        if (rescale)
        {
            b = new BitmapData(textureWidth, textureHeight, true, 0x00000000);
            b.copyPixels(bitmapData, bitmapData.rect, new Point());
        }

        memory += b.width * b.height * 4;
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

                memory += w * h * 4;

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
        else if (releaseRawData)
        {
            bitmapData.dispose();
            bitmapData = null;
        }

        #if dd_stat
        GlobalStatistics.addTexture(ctx, this);
        #end
    }
}

//---------------------------

class ATFTexture2D extends Texture2D
{
    var atfData:ByteArray;

    public function new(data:ByteArray, options:UInt = Texture2DOptions.QUALITY_ULTRA)
    {
        #if debug
        if (String.fromCharCode(data[0]) + String.fromCharCode(data[1]) + String.fromCharCode(data[2]) != "ATF")
            throw "error AF signature";
        #end

        width = textureWidth = Std.int(Math.pow(2, data[7]));
        height = textureHeight = Std.int(Math.pow(2, data[8]));

        super(options);
    }

    override public function dispose():Void
    {
        super.dispose();
        atfData = null;
    }

    override public function init(ctx:Context3D)
    {
        if (this.ctx == ctx) return;
        super.init(ctx);

        uploadAtfTexture();
    }

    function uploadAtfTexture()
    {
        var w = textureWidth;
        var h = textureWidth;
        memory = 0;
        var n = atfData[9];
        while (n > 0)
        {
            memory += w * h * 4;
            w >>= 1;
            h >>= 1;
            n--;
        }

        var format = switch (atfData[6])
        {
            case 0, 1: Context3DTextureFormat.BGRA;
            case 2, 3: Context3DTextureFormat.COMPRESSED;
            case 4, 5: Context3DTextureFormat.COMPRESSED_ALPHA;
            default: throw "unknown atf format";
        }

        texture = ctx.createTexture(textureWidth, textureHeight, format, false);

        texture.uploadCompressedTextureFromByteArray(atfData, 0);

        if (releaseRawData) atfData = null;

        #if dd_stat
        GlobalStatistics.addTexture(ctx, this);
        #end
    }
}

//---------------------------

class EmptyTexture extends Texture2D
{
    public function new(width:Int, height:Int, options:UInt = Texture2DOptions.QUALITY_ULTRA)
    {
        textureWidth = Texture2D.getNextPowerOfTwo(width);
        textureHeight = Texture2D.getNextPowerOfTwo(height);

        super(options);

        frame = new Frame(textureWidth, textureHeight, new Vector3D(0, 0, 1, 1));
    }

    override public function init(ctx:Context3D)
    {
        if (this.ctx == ctx) return;
        super.init(ctx);
        uploadEmptyTexture();
    }

    function uploadEmptyTexture()
    {
        texture = ctx.createTexture(textureWidth, textureHeight, Context3DTextureFormat.BGRA, true);
        memory = textureWidth * textureHeight * 4;

        #if dd_stat
        GlobalStatistics.addTexture(ctx, this);
        #end
    }
}

//---------------------------

class Texture2D
{
    public var options(default, null):UInt;

    // preferred size
    public var width(default, null):Float;
    public var height(default, null):Float;

    // texture size 2^n
    public var textureWidth(default, null):Int;
    public var textureHeight(default, null):Int;

    public var frame(default, set_frame):Frame;

    public var texture(default, null):Texture;

    var ctx:Context3D;

    static var uid:Int = 0;

    public var name:String;

    function new(options:UInt = Texture2DOptions.QUALITY_ULTRA)
    {
        this.options = options;
        name = "texture_" + uid++;
    }

    public var useCount(default, null):Int = 0;
    public var cache(default, null):Cache;

    public var releaseRawData(default, #if debug set_releaseBitmap #else default #end):Bool = false;

    #if debug
    function set_releaseBitmap(v)
    {
        if (cache != null) throw "releaseBitmap conflict with cache";
        return releaseRawData = v;
    }
    #end

    function set_frame(f:Frame):Frame
    {
        #if debug
        if (f == null) throw "frame is null";
        #end

        frame = f;
        width = frame.width;
        height = frame.height;

        return frame = f;
    }

    public var needUpdate:Bool = false;

    public function update()
    {
    }

    public var memory(default, null):UInt = 0;

    public function init(ctx:Context3D)
    {
        if (this.ctx == ctx) return;
        unloadTexture();
        this.ctx = ctx;
    }

    function unloadTexture()
    {
        if (texture != null)
        {
            #if dd_stat
            if (this.ctx != null) GlobalStatistics.removeTexture(this.ctx, this);
            #end
            texture.dispose();
            texture = null;
        }
    }
	
	public function dispose():Void
	{
        if (useCount > 0) return;

        unloadTexture();

        if (cache == null)
        {
            Reflect.setField(this, "frame", null);
        }
        ctx = null;
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

    public function toString()
    {
        var ref = Type.getClassName(Type.getClass(this)).split(".").pop();

        return Std.format("{$ref: $name, $width x $height}");
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
