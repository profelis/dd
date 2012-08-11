package deep.hxd.utils;
import flash.display3D.Context3DBlendFactor;
class BlendMode
{
    public static var BLEND:BlendMode = new BlendMode(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

    public static var FILTER:BlendMode = new BlendMode(Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ZERO);

    public static var MODULATE:BlendMode = new BlendMode(Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ZERO);

    public static var NORMAL_PREMULTIPLIED_ALPHA:BlendMode = new BlendMode(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

    public static var NORMAL_NO_PREMULTIPLIED_ALPHA:BlendMode = new BlendMode(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

    public static var ADD_NO_PREMULTIPLIED_ALPHA:BlendMode = new BlendMode(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);

    public static var ADD_PREMULTIPLIED_ALPHA:BlendMode = new BlendMode(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE);

    public var src:Context3DBlendFactor;
    public var dst:Context3DBlendFactor;

    public function new(s, d)
    {
        src = s;
        dst = d;
    }
}
