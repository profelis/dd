package deep.hxd.utils;

import deep.hxd.texture.Texture2D;
import deep.hxd.World2D;
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
                bmpTextureCache.get(k).dispose();
            }
        }
    }

    public var autoDisposeBitmaps:Bool = true;

    var w:World2D;

    var bmpCache:TypedDictionary<Class<BitmapData>, BitmapData>;
    var bmpUseCount:TypedDictionary<BitmapData, Int>;

    /**
    *  Auto dispose cached bitmaps
    **/
    public function releaseBitmap(bmp:BitmapData)
    {
        if (!bmpUseCount.exists(bmp)) return;

        trace("release bmp " + bmp);
        var count = bmpUseCount.get(bmp);
        if (count <= 1)
        {
            if (autoDisposeBitmaps)
            {
                trace("auto dispose bmp " + bmp);
                bmpUseCount.delete(bmp);
                bmpCache.delete(Type.getClass(bmp));
                bmp.dispose();
            }
            else
            {
                trace("keep unused bmp " + bmp);
                bmpUseCount.set(bmp, 0);
            }
        }
        else
        {
            trace("bmp use count ", count - 1);
            bmpUseCount.set(bmp, count - 1);
        }
    }

    public function getBitmap(ref:Class<BitmapData>):BitmapData
    {
        trace("get bitmap " + ref);
        var res = bmpCache.get(ref);
        if (res != null) return res;

        trace("create new bitmap " + ref);
        res = Type.createInstance(ref, [0, 0]);
        bmpCache.set(ref, res);
        bmpUseCount.set(res, 0);
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

    var bmpTextureCache:TypedDictionary<BitmapData, Texture2D>;

    public function getTexture(ref:Class<BitmapData>):Texture2D
    {
        return getBitmapTexture(getBitmap(ref));
    }

    public function getBitmapTexture(bmp:BitmapData):Texture2D
    {
        trace("get bmp texture");
        var res = bmpTextureCache.get(bmp);
        if (res != null) return res;

        trace("create new bmp texture " + bmp);
        if (bmpUseCount.exists(bmp))
            bmpUseCount.set(bmp, bmpUseCount.get(bmp) + 1);

        res = Texture2D.fromBitmap(bmp);
        res.cache = this;
        bmpTextureCache.set(bmp, res);

        return res;
    }

    public function removeBitmapTexture(bmp:BitmapData, disposeTexture:Bool = true):Void
    {
        if (disposeTexture)
        {
            var res = bmpTextureCache.get(bmp);
            if (res != null) res.dispose();
        }
        bmpTextureCache.delete(bmp);
    }
}
