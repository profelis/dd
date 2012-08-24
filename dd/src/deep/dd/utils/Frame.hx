package deep.dd.utils;

import flash.geom.Vector3D;
import flash.geom.Rectangle;
import flash.geom.Matrix3D;

class Frame
{
    public var name(default, null):String;

    // clean size
    public var frameWidth(default, null):Float;
    public var frameHeight(default, null):Float;

    // preferred size
    public var width(default, null):Float;
    public var height(default, null):Float;

    // uvOffset & uvScale
    public var region(default, null):Vector3D;

    // offset + border size
    public var border(default, null):Rectangle;

    public function new (width, height, region, ?border, ?name)
    {
        this.frameWidth = width;
        this.frameHeight = height;
        this.region = region;
        this.name = name;

        setBorder(border);
    }

    function setBorder(b:Rectangle)
    {
        border = b;

        if (border != null)
        {
            width = border.width;
            height = border.height;
        }
        else
        {
            width = frameWidth;
            height = frameHeight;
        }
    }

    inline public function applyFrame(m:Matrix3D)
    {
        m.prependScale(frameWidth, frameHeight, 1);

        if (border != null)
        {
            m.prependTranslation(border.x, border.y, 0);
        }
    }


    public function toString()
    {
        return Std.format("{Frame: $width, $height, $region${border != null ? ', ' + border : ''}${name != null ? ' ~ ' + name : ''}}");
    }
}