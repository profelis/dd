package deep.dd.texture;

import deep.dd.texture.Texture2D;
import flash.geom.Vector3D;
import flash.display.BitmapData;
import deep.dd.texture.Texture2D;

class SpriteSheetTexture2D extends Texture2D
{
    public function new(options:UInt)
    {
        super(options);
        needUpdate = true;
    }

    var frames:Array<Vector3D>;

    var fps = 5;

    public static function fromBitmap(bmp:BitmapData, itemWidth:Float, itemHeight:Float, options:UInt = Texture2DOptions.QUALITY_ULTRA):Texture2D
    {
        /*#if debug
        if (iw < 0 || ih < 0) throw "item size < 0";
        #end */

        var res = new SpriteSheetTexture2D(options);
        res.bitmapData = bmp;
        res.bw = bmp.width;
        res.bh = bmp.height;
        res.tw = Texture2D.getNextPowerOfTwo(res.bw);
        res.th = Texture2D.getNextPowerOfTwo(res.bh);

        res.width = itemWidth;
        res.height = itemHeight;

        res.parse();

        return res;
    }

    function parse()
    {
        var x = 0.0;
        var y = 0.0;
        var w = width / tw;
        var h = height / th;

        frames = new Array();
        while (x < bw)
        {
            y = 0.0;
            while (y < bh)
            {
                trace(x + " " + y);
                frames.push(new Vector3D(x / tw, y / th, w, h));
                y += height;
            }
            x += width;
        }

        region = frames[0];
    }

    var frameTime:Float = 0;
    var frame:Int = -1;

    var prevTime:Float = 0;

    override public function update(time:Float)
    {
        trace(time + " " + prevTime);
        frameTime += fps * (time - prevTime);
        prevTime = time;
        if (frameTime > 1)
        {
            frameTime = 0;
            frame++;
            region = frames[frame % frames.length];
        }
    }


}

