package deep.dd.utils;

import deep.dd.texture.Texture2D;
import deep.dd.World2D;
import flash.utils.TypedDictionary;
import flash.display.BitmapData;

class Cache
{
    public function new(w:World2D)
    {
        this.w = w;

        bmpCache = new TypedDictionary();
        bmpUseCount = new TypedDictionary(true);
        bmpTextureCache = new TypedDictionary();
    }

    public function dispose(disposeBitmaps:Bool = true, disposeTextures:Bool = true)
    {
        w = null;
        if (disposeBitmaps)
        {
            for (k in bmpCache)
            {
                bmpCache.get(k).dispose();
            }
            bmpCache = null;
            bmpUseCount = null;
        }

        if (disposeTextures)
        {
            for (k in bmpTextureCache)
            {
                var h = bmpTextureCache.get(k);
                for (i in h)
                {
                    i.dispose();
                }
            }
        }
    }

    /**
    * if true then all bitmapDatas will be deleted, can't be restored after context loss
    **/
    public var autoDisposeBitmaps:Bool = false;

    var w:World2D;

    var bmpCache:TypedDictionary<Class<BitmapData>, BitmapData>;
    var bmpUseCount:TypedDictionary<BitmapData, Int>;

    public function releaseBitmap(bmp:BitmapData)
    {
        if (!bmpUseCount.exists(bmp)) return;

        var count = bmpUseCount.get(bmp);
        if (count <= 1)
        {
            if (autoDisposeBitmaps)
            {
                bmpUseCount.delete(bmp);
                bmpCache.delete(Type.getClass(bmp));
                bmp.dispose();
            }
            else
            {
                bmpUseCount.set(bmp, 0);
            }
        }
        else
        {
            bmpUseCount.set(bmp, count - 1);
        }
    }

    public function getBitmap(ref:Class<BitmapData>):BitmapData
    {
        var res = bmpCache.get(ref);
        if (res != null) return res;

        res = Type.createInstance(ref, [0, 0]);
        bmpCache.set(ref, res);
        if (!bmpUseCount.exists(res))
		{
			bmpUseCount.set(res, 0);
		}
        return res;
    }

    public function removeBitmap(ref:Class<BitmapData>, disposeBitmap:Bool = true):Void
    {
        if (disposeBitmap)
        {
            var res = bmpCache.get(ref);
            if (res != null) res.dispose();
        }
        bmpCache.delete(ref);
    }

    var bmpTextureCache:TypedDictionary<BitmapData, Hash<Texture2D>>;
	
	public function reinitBitmapTextureCache():Void
	{
		bmpTextureCache = new TypedDictionary();
		for (key in bmpUseCount.keys())
		{
			bmpUseCount.set(key, 0);
		}
	}

    public function getTexture(ref:Class<BitmapData>, options:UInt = Texture2DOptions.QUALITY_ULTRA):Texture2D
    {
        return getBitmapTexture(getBitmap(ref), options);
    }

    public function getBitmapTexture(bmp:BitmapData, options:UInt = Texture2DOptions.QUALITY_ULTRA):Texture2D
    {
        var h = bmpTextureCache.get(bmp);
        var res:Texture2D;
        if (h != null)
        {
            res = h.get(key(options));
            if (res != null) return res;
        }
        else
        {
            bmpTextureCache.set(bmp, h = new Hash());
        }

        if (bmpUseCount.exists(bmp))
        {
			bmpUseCount.set(bmp, bmpUseCount.get(bmp) + 1);
		}

        res = Texture2D.fromBitmap(bmp, options);
        res.cache = this;
        h.set(key(options), res);

        return res;
    }

    inline function key(options:UInt)
    {
        return Std.string(options);
    }

    public function removeBitmapTexture(bmp:BitmapData, disposeTexture:Bool = true):Void
    {
        if (disposeTexture)
        {
            var res = bmpTextureCache.get(bmp);
            if (res != null)
            {
                for (i in res) i.dispose();
            }
        }
        bmpTextureCache.delete(bmp);
    }
}
