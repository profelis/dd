package deep.dd.utils;

import deep.dd.texture.Texture2D;
import deep.dd.World2D;
import flash.display.BitmapData;
import haxe.ds.ObjectMap;

class Cache
{
    public function new(w:World2D)
    {
        this.w = w;

        bmpCache = new ObjectMap();
        bmpUseCount = new ObjectMap();
        bmpTextureCache = new Map();
    }

    public function dispose(disposeBitmaps:Bool = true, disposeTextures:Bool = true)
    {
        w = null;
        if (disposeBitmaps)
        {
            for (k in bmpCache.keys()) bmpCache.get(k).dispose();
            bmpCache = null;
            bmpUseCount = null;
        }

        if (disposeTextures)
        {
            for (t in bmpTextureCache)
            {
                t.dispose();
            }
        }
    }

    public function reinitBitmapTextureCache():Void
    {
        bmpTextureCache = new Map();
        for (key in bmpUseCount.keys())
        {
            bmpUseCount.set(key, 0);
        }
    }

    /**
    * if true then all bitmapDatas without class references will be deleted, can't be restored after context loss
    **/
    public var autoDisposeBitmaps:Bool = false;

    var w:World2D;

    var bmpCache:Map<Dynamic, BitmapData>;
    var bmpUseCount:Map<BitmapData, Int>;

    public function releaseBitmap(bmp:BitmapData)
    {
        if (!bmpUseCount.exists(bmp)) return;

        var count = bmpUseCount.get(bmp);
        if (count <= 1)
        {
            if (autoDisposeBitmaps)
            {
                bmpUseCount.remove(bmp);
                bmpCache.remove(Type.getClass(bmp));
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
        bmpCache.remove(ref);
    }

    var bmpTextureCache:Map<BitmapData, Texture2D>;
	
    public function getTexture(ref:Class<BitmapData>):Texture2D
    {
        var res = getBitmapTexture(getBitmap(ref));
        Reflect.setField(res, "bitmapRef", ref);
        return res;
    }

    public function getBitmapTexture(bmp:BitmapData):Texture2D
    {
        var h = bmpTextureCache.get(bmp);
        if (h != null)
        {
            return h;
        }

        if (bmpUseCount.exists(bmp))
        {
			bmpUseCount.set(bmp, bmpUseCount.get(bmp) + 1);
		}

        var res = new BitmapTexture2D(bmp);
        Reflect.setField(res, "cache", this);
        bmpTextureCache.set(bmp, res);

        return res;
    }

    public function removeBitmapTexture(bmp:BitmapData, disposeTexture:Bool = true):Void
    {
        if (disposeTexture)
        {
            var res = bmpTextureCache.get(bmp);
            res.dispose();
        }
        bmpTextureCache.remove(bmp);
    }

    public function toString()
    {
        return "{Cache}";
    }
}
