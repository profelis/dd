package deep.hxd.utils;
class Color
{
    public var a:Float;
    public var r:Float;
    public var g:Float;
    public var b:Float;

    public function new(r:Float, g:Float, b:Float, a:Float = 1)
    {
        this.a = clamp(a);
        this.r = clamp(r);
        this.g = clamp(g);
        this.b = clamp(b);
    }

    inline function clamp(x:Float)
    {
        //return x;
        return x > 1 ? 1 : (x < 0) ? 0 : x;
    }

    public static function fromUint(c:UInt):Color
    {
        return new Color(((c >> 16) & 0xFF) / 0xFF, ((c >> 8) & 0xFF) / 0xFF, (c & 0xFF) / 0xFF, ((c >> 24) & 0xFF) / 0xFF);
    }

    public function clone():Color
    {
        return new Color(r, g, b, a);
    }
}
