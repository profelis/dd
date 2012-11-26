package ;

/**
 *  @author Dima Granetchi <system.grand@gmail.com>, <deep@e-citrus.ru>
 */

import hxsl.PicoShader;
class PicoTest
{
    public function new()
    {
        
    }

    static function main()
    {
        trace(123);
        var p = new Pico();

        var s = p.createInstance();
    }
}

class Pico extends PicoShader
{
    static public var SRC = {

        var input: { pos:Float3, u:Float2, c:Float4 };

        var uv:Float2;
        var color:Float4;

        function vertex(m:M44)
        {
            out = pos.xyzw * m;
            uv = u;
            color = c;
        }

        function fragment(tex:Texture)
        {
            out = tex.get(uv) * color;
        }
    }
}
