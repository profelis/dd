package deep.dd.utils;

import flash.display3D.Context3DBlendFactor;

class BlendMode
{
    public static var NONE:BlendMode = new BlendMode(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
    public static var NONE_A:BlendMode = new BlendMode(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);

    public static var NORMAL:BlendMode = new BlendMode(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
    public static var NORMAL_A:BlendMode = new BlendMode(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

    public static var ADD:BlendMode = new BlendMode(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.DESTINATION_ALPHA);
    public static var ADD_A:BlendMode = new BlendMode(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE);

    public static var MULTIPLY:BlendMode = new BlendMode(Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ZERO);
    public static var MULTIPLY_A:BlendMode = new BlendMode(Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

    public static var SCREEN:BlendMode = new BlendMode(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);
    public static var SCREEN_A:BlendMode = new BlendMode(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR);

    public static var ERASE:BlendMode = new BlendMode(Context3DBlendFactor.ZERO, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
    public static var ERASE_A:BlendMode = new BlendMode(Context3DBlendFactor.ZERO, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

    public var src:Context3DBlendFactor;
    public var dst:Context3DBlendFactor;

    public function new(s, d)
    {
        src = s;
        dst = d;
    }
}
