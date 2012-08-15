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
    }

    override public function dispose():Void
    {
        super.dispose();

        frames = null;
    }

    var ignoreBorder:Float;
    var frames:Array<Vector3D>;

    public var fps:UInt = 30;

    var frameTime:Float = 0;
    var currentFrame:Int = -1;

    var prevTime:Float = 0;

    public static function fromBitmap(bmp:BitmapData, itemWidth:Float, itemHeight:Float, ignoreBorder = 0.0, options:UInt = Texture2DOptions.QUALITY_ULTRA):SpriteSheetTexture2D
    {
        #if debug
        if (itemWidth < 0 || itemHeight < 0) throw "item size < 0";
        if (ignoreBorder < 0) throw "ignoreBorder < 0";
        #end

        var res = new SpriteSheetTexture2D(options);
        res.bitmapData = bmp;
        res.bitmapWidth = bmp.width;
        res.bitmapHeight = bmp.height;
        res.textureWidth = Texture2D.getNextPowerOfTwo(res.bitmapWidth);
        res.textureHeight = Texture2D.getNextPowerOfTwo(res.bitmapHeight);

        res.width = itemWidth;
        res.height = itemHeight;

        res.ignoreBorder = ignoreBorder;
        res.parse();

        return res;
    }

    function parse()
    {
        var x = 0.0;
        var y = 0.0;

        var kx = 1 / textureWidth;
        var ky = 1 / textureHeight;

        var w = (width - ignoreBorder * 2) * kx;
        var h = (height - ignoreBorder * 2) * ky;

        frames = new Array();
        while (x < bitmapWidth)
        {
            y = 0.0;
            while (y < bitmapHeight)
            {
                trace(x + " " + y);
                frames.push(new Vector3D((x+ignoreBorder) * kx, (y+ignoreBorder) * ky, w, h));
                y += height;
            }
            x += width;
        }
    }
    /*
    override public function update(time:Float)
    {
        trace(time + " " + prevTime);
        frameTime += fps * (time - prevTime);
        prevTime = time;
        if (frameTime > 1)
        {
            frameTime = 0;
            currentFrame++;
            region = frames[currentFrame % frames.length];
        }
    } */


}

