package deep.dd.utils;

class Color
{
    public var a:Float;
    public var r:Float;
    public var g:Float;
    public var b:Float;

    public function new(r:Float = 0, g:Float = 0, b:Float = 0, a:Float = 1)
    {
        this.a = clamp(a);
        this.r = clamp(r);
        this.g = clamp(g);
        this.b = clamp(b);
    }

    inline function clamp(x:Float)
    {
        return x > 1 ? 1 : (x < 0) ? 0 : x;
    }

    public function fromUint(c:UInt):Color
    {
        a = clamp(((c >> 24) & 0xFF) / 0xFF);
        r = clamp(((c >> 16) & 0xFF) / 0xFF);
        g = clamp(((c >> 8) & 0xFF) / 0xFF);
        b = clamp((c & 0xFF) / 0xFF);

        return this;
    }

    public function fromInt(c:Int, alpha:Float = 1):Color
    {
        r = clamp(((c >> 16) & 0xFF) / 0xFF);
        g = clamp(((c >> 8) & 0xFF) / 0xFF);
        b = clamp((c & 0xFF) / 0xFF);
        a = alpha;

        return this;
    }

    public function clone():Color
    {
        return new Color(r, g, b, a);
    }
}
