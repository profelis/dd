package deep.dd.texture;

/**
* @author Dima Granetchi <system.grand@gmail.com>, <deep@e-citrus.ru>
*/

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

/**
* Текстура отображающая битмапу
* @lang ru
**/
class BitmapTexture2D extends Texture2D
{
    /**
    * Ссылка на битмапу текстуры. Может и не существовать
    * @lang ru
    **/
    public var bitmapData(default, null):BitmapData;
    var bitmapRef:Class<BitmapData>;

    /**
    * Ширина битмапы
    * @lang ru
    **/
    public var bitmapWidth(default, null):Int;

    /**
    * Высота битмапы
    * @lang ru
    **/
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

    /**
    * Билд метод для создания битмап текстуры на основе класса битмапы
    * @lang ru
    **/
    public static function createFromRef(ref:Class<BitmapData>, options:UInt = Texture2DOptions.QUALITY_ULTRA):BitmapTexture2D
    {
        var res = new BitmapTexture2D(Type.createInstance(ref, [0, 0]));
        res.bitmapRef = ref;
        return res;
    }

    override public function dispose()
    {
        super.dispose();

        if (releaseRawData && bitmapData != null) bitmapData.dispose();

        bitmapRef = null;
        bitmapData = null;
    }

    override function uploadTexture()
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

        super.uploadTexture();
    }
}

/**
* ATF текстура.
* Пока не поддерживается
* @lang ru
**/
class ATFTexture2D extends Texture2D
{
    var atfData:ByteArray;

    function new(data:ByteArray, options:UInt = Texture2DOptions.QUALITY_ULTRA)
    {
        #if debug
        if (String.fromCharCode(data[0]) + String.fromCharCode(data[1]) + String.fromCharCode(data[2]) != "ATF")
            throw "error AF signature";
        #end

        textureWidth = Std.int(Math.pow(2, data[7]));
        textureHeight = Std.int(Math.pow(2, data[8]));

        atfData = data;

        super(options);

        frame = new Frame(textureWidth, textureHeight, new Vector3D(0, 0, 1, 1));
    }

    override public function dispose():Void
    {
        super.dispose();
        atfData = null;
    }

    override function uploadTexture()
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

        var format:Context3DTextureFormat;

        switch (atfData[6])
        {
            case 0, 1: format = Context3DTextureFormat.BGRA;
            case 2, 3: format = Context3DTextureFormat.COMPRESSED;
            #if flash11_4 case 4, 5: format = Context3DTextureFormat.COMPRESSED_ALPHA;  #end
            default: throw "unknown atf format";
        }

        texture = ctx.createTexture(textureWidth, textureHeight, format, false);

        texture.uploadCompressedTextureFromByteArray(atfData, 0);

        if (releaseRawData) atfData = null;

        super.uploadTexture();
    }
}

/**
* Пустая текстура, обычно используется для рендера на текстуру
* @lang ru
**/
class EmptyTexture extends Texture2D
{
    public function new(width:Int, height:Int, options:UInt = Texture2DOptions.QUALITY_ULTRA)
    {
        textureWidth = Texture2D.getNextPowerOfTwo(width);
        textureHeight = Texture2D.getNextPowerOfTwo(height);

        super(options);

        frame = new Frame(textureWidth, textureHeight, new Vector3D(0, 0, 1, 1));
    }

    override function uploadTexture()
    {
        texture = ctx.createTexture(textureWidth, textureHeight, Context3DTextureFormat.BGRA, true);
        memory = textureWidth * textureHeight * 4;

        super.uploadTexture();
    }
}

/**
* Базовый класс текстуры
* @lang ru
**/
class Texture2D
{
    /**
    * Свойства текстуры
    * @lang ru
    **/
    public var options(default, null):UInt;

    /**
    * Предпочтительная ширина текстуры с учетом фрейма
    * @lang ru
    **/
    public var width(default, null):Float;
    /**
    * Предпочтительная высота текстуры с учетом фрейма
    * @lang ru
    **/
    public var height(default, null):Float;

    /**
    * Ширина загруженой текстуры
    * @lang ru
    **/
    public var textureWidth(default, null):Int;

    /**
    * Высота загруженой текстуры
    * @lang ru
    **/
    public var textureHeight(default, null):Int;

    /**
    * Кадр текстуры
    * @see deep.dd.utils.Frame
    * @lang ru
    **/
    public var frame(default, set_frame):Frame;

    /**
    * Загруженная текстура в гпу
    * @lang ru
    **/
    public var texture(default, null):Texture;

    var ctx:Context3D;

    static var uid:Int = 0;

    public var name:String;

    function new(options:UInt = Texture2DOptions.QUALITY_ULTRA)
    {
        this.options = options;
        name = "texture_" + uid++;
    }

    /**
    * Счетчик использования текстуры
    * @lang ru
    **/
    public var useCount(default, null):Int = 0;

    /**
    * Ссылка на кеш, если текстура было создана через кеш
    * @lang ru
    **/
    public var cache(default, null):Cache;

    /**
    * Удалять ссылку на битмапу или атф данные.
    * Если значение true, то в случае потери контекста не удастся восстановить текстуру
    * Не
    * @lang ru
    **/
    public var releaseRawData(default, #if debug set_releaseBitmap #else default #end):Bool = false;

    #if debug
    function set_releaseBitmap(v)
    {
        if (cache != null) throw "releaseBitmap conflict with cache";
        return releaseRawData = false;
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

    /**
    * Флаг, что нужно обновить текстуру
    * @lang ru
    **/
    public var needUpdate:Bool = false;

    /**
    * Обновление текстуры
    * @lang ru
    **/
    public function update()
    {
    }

    /**
    * Размер текстуры в байтах занимаемый в памяти
    * @lang ru
    **/
    public var memory(default, null):UInt = 0;

    /**
    * Метод инициализации контекста, вызывается при создании контекста
    * @lang ru
    **/
    public function init(ctx:Context3D)
    {
        if (this.ctx == ctx) return;
        unloadTexture();
        this.ctx = ctx;
        uploadTexture();
    }

    /**
    * Выгрузка текстуры
    * @lang ru
    **/
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

    /**
    * Загрузка текстуры
    * @lang ru
    **/
    function uploadTexture()
    {
        #if dd_stat
            GlobalStatistics.addTexture(ctx, this);
        #end
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

        return '{$ref: $name, $width x $height}';
    }
}

// ND2D thanks
/**
* Свойства текстуры. Параметры мипмапинга, сглаживания и повтора текстуры
* @lang ru
**/
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
