package deep.dd.texture;

import deep.dd.texture.Texture2D;
import flash.geom.Vector3D;
import deep.dd.utils.Frame;
import flash.display.BitmapData;
import flash.display3D.Context3D;
import deep.dd.texture.Texture2D.Texture2DOptions;
import flash.display.DisplayObject;

class FlashTexture2D extends BitmapTexture2D
{
    var displayObject:DisplayObject;

    public var autoSize:Bool;

    public var displayObjectWidth:Int;
    public var displayObjectHeight:Int;

    public var autoUpdate:Bool;

    public function new(d:DisplayObject, autoUpdate = false, width:UInt = 0, height:UInt = 0, options:UInt = Texture2DOptions.QUALITY_ULTRA)
    {
        displayObject = d;
        this.autoUpdate = autoUpdate;
        autoSize = width == 0 || height == 0;
        displayObjectWidth = width;
        displayObjectHeight = height;

        update();

        super(bitmapData, options);
    }


    override public function init(ctx:Context3D)
    {
        if (this.ctx == ctx) return;

        unloadTexture();

        this.ctx = ctx;

        if (bitmapData == null) needUpdate = true;
        else if (!needUpdate) uploadBitmapTexture();
    }

    override public function update()
    {
        unloadTexture();

        var f = false;
        if (autoSize && (bitmapData == null || (bitmapData.width != displayObject.width || bitmapData.height != displayObject.height)))
        {
            if (bitmapData != null) bitmapData.dispose();
            var w = Math.ceil(displayObject.width);
            var h = Math.ceil(displayObject.height);
            bitmapData = new BitmapData(w, h, true, 0x00000000);
            bitmapData.lock();
            f = true;
        }
        else if (bitmapData == null)
        {
            bitmapData = new BitmapData(displayObjectWidth, displayObjectHeight, true, 0x00000000);
            bitmapData.lock();
            f = true;
        }
        else
        {
            bitmapData.fillRect(bitmapData.rect, 0x00000000);
        }

        if (f)
        {
            bitmapWidth = bitmapData.width;
            bitmapHeight = bitmapData.height;
            textureWidth = Texture2D.getNextPowerOfTwo(bitmapWidth);
            textureHeight = Texture2D.getNextPowerOfTwo(bitmapHeight);

            frame = new Frame(bitmapWidth, bitmapHeight, new Vector3D(0, 0, bitmapWidth/textureWidth, bitmapHeight/textureHeight));
        }

        bitmapData.draw(displayObject, null, null, null, null, true);

        if (ctx != null) uploadBitmapTexture();

        needUpdate = autoUpdate;
    }

    override public function dispose():Void
    {
        super.dispose();
        displayObject = null;
    }

    override public function toString()
    {
        return Std.format("{FlashTexture2D: displayObject:$displayObject}");
    }

}
