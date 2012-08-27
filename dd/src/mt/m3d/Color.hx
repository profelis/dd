package mt.m3d;

import flash.geom.Vector3D;

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

    inline static public function clamp(x:Float)
    {
        return x > 1 ? 1 : (x < 0) ? 0 : x;
    }

    inline public function fromUInt(c:UInt)
    {
        a = clamp(((c >> 24) & 0xFF) / 0xFF);
        r = clamp(((c >> 16) & 0xFF) / 0xFF);
        g = clamp(((c >> 8) & 0xFF) / 0xFF);
        b = clamp((c & 0xFF) / 0xFF);
    }

    inline public function fromInt(c:Int, alpha:Float = 1)
    {
        r = clamp(((c >> 16) & 0xFF) / 0xFF);
        g = clamp(((c >> 8) & 0xFF) / 0xFF);
        b = clamp((c & 0xFF) / 0xFF);
        a = alpha;
    }

    inline public function fromColor(c:Color)
    {
        a = c.a;
        r = c.r;
        g = c.g;
        b = c.b;
    }

    inline public function fromVector(v:Vector3D)
    {
        a = v.w;
        r = v.x;
        g = v.y;
        b = v.z;
    }

    public inline function concat(c:Color)
    {
        a *= c.a;
        r *= c.r;
        g *= c.g;
        b *= c.b;
    }

    inline public function copy():Color
    {
        return new Color(r, g, b, a);
    }

    inline public function equals(c:Color)
    {
        return c.a == a && c.r == r && c.g == g && c.b == b;
    }

    public function toString() {
        return "{Color "+Std.int(a * 0xFF)+","+Std.int(r * 0xFF)+","+Std.int(g * 0xFF)+","+Std.int(b * 0xFF)+"}";
    }

}
