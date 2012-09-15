package deep.dd.material;

import flash.geom.Matrix3D;
import flash.display3D.textures.Texture;
import flash.display3D.Context3DTextureFormat;
import flash.utils.ByteArray;
import hxsl.Shader;
import flash.display3D.Context3D;
import deep.dd.display.DisplayNode2D;
import deep.dd.camera.Camera2D;
import deep.dd.material.Material;

import flash.geom.Vector3D;

class PerlinMaterial extends Material
{
    public function new()
    {
        super(PerlinShader);

        delta = new Vector3D();
    }

    public var delta(default, null):Vector3D;
    public var scale:Float = 3;

    var perlinShader:PerlinShader;

    override public function init(ctx:Context3D)
    {
        super.init(ctx);

        perlinShader = flash.Lib.as(shader, PerlinShader);
    }

    override public function draw(sprite:DisplayNode2D, camera:Camera2D)
    {
        perlinShader.perlin(delta, scale, sprite.worldTransform, camera.proj, sprite.worldColorTransform);

        super.draw(sprite, camera);
    }

    override public function dispose():Void
    {
        super.dispose();

        perlinShader = null;
        delta = null;
    }

}

/**
* http://ncannasse.fr/blog/perlin_noise_shader
**/
class PerlinShader extends Shader
{

    static var PTBL = flash.Vector.ofArray([ 151, 160, 137, 91, 90, 15,
        131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
        190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
        88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
        77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
        102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
        135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
        5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
        223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
        129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
        251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
        49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
        138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
    ]);

    static var GRAD = [
        1,1,0,
        -1,1,0,
        1,-1,0,
        -1,-1,0,
        1,0,1,
        -1,0,1,
        1,0,-1,
        -1,0,-1,
        0,1,1,
        0,-1,1,
        0,1,-1,
        0,-1,-1,
        1,1,0,
        0,-1,1,
        -1,1,0,
        0,-1,-1
    ];

    static var permutBytes:ByteArray;
    static var gradBytes:ByteArray;

    static var permut : Texture;
    static var grad : Texture;

    public function new(c) {
        super(c);
        initPermut();
        initGradient();
    }

    inline function perm( x : Int ) {
        return PTBL[x & 0xFF];
    }

    inline function initPermut()
    {
        if (permutBytes == null)
        {
            permutBytes = new flash.utils.ByteArray();
            permutBytes.length = 256 * 256 * 4;
            permutBytes.position = 0;
            for (y in 0...256)
                for (x in 0...256)
                {
                    var a = perm(x) + y;
                    var aa = perm(a);
                    var ab = perm(a + 1);
                    var b = perm(x + 1) + y;
                    var ba = perm(b);
                    var bb = perm(b + 1);
                    permutBytes.writeByte(ba); // B
                    permutBytes.writeByte(ab); // G
                    permutBytes.writeByte(aa); // R
                    permutBytes.writeByte(bb); // A
                }

            permut = c.createTexture(256, 256, Context3DTextureFormat.BGRA, false);
            permut.uploadFromByteArray(permutBytes, 0);
        }
    }

    inline function initGradient()
    {
        if (gradBytes == null)
        {
            permutBytes = new flash.utils.ByteArray();
            for( x in 0...256 ) {
                var p = (perm(x) & 15) * 3;
                var r = GRAD[p];
                var g = GRAD[p + 1];
                var b = GRAD[p + 2];
                permutBytes.writeByte(Std.int((b + 1) * 127.5));
                permutBytes.writeByte(Std.int((g + 1) * 127.5));
                permutBytes.writeByte(Std.int((r + 1) * 127.5));
                permutBytes.writeByte(255); // A
            }

            grad = c.createTexture(256, 1, Context3DTextureFormat.BGRA, false);
            grad.uploadFromByteArray(permutBytes, 0);
        }
    }

    public inline function perlin(delta:Vector3D, scale : Float, mpos:Matrix3D, mproj:Matrix3D, cTrans:Vector3D)
    {
        init({delta : delta, scale : scale, mpos:mpos, mproj:mproj}, {permut : permut, g : grad, cTrans:cTrans});
    }


    static var SRC =
    {
        var input : {
            pos : Float3
        }
        var tuv : Float3;
        var one:Float;

        function vertex(delta : Float3, scale : Float, mpos:M44, mproj:M44)
        {
            tuv = ([pos.x, -pos.y, 0] + delta) * scale;
            out = pos.xyzw * mpos * mproj;
            one = 1/256;
        }

        function gradperm(g : Texture, v : Float, pp : Float3)
        {
            return (g.get(v,single,nearest,wrap).xyz * 2 - 1).dot(pp);
        }

        function lerp( x : Float, y : Float, v : Float )
        {
            return x  + (y-x) * v;
        }

        function fade( t : Float3 ) : Float3 {
            return t * t * t * (t * (t * 6 - 15) + 10);
            //return t * t * (3 - 2 * t);
        }

        function gradient( permut : Texture, g : Texture, pos : Float3 )
        {
            var p = pos.frc();
            var i = pos - p;
            var f = fade(p);
            i *= one;
            var a = permut.get(i.xy, nearest, wrap) + i.z;
            return lerp(
                lerp(
                    lerp( gradperm(g, a.x, p), gradperm(g, a.z, p + [ -1, 0, 0] ), f.x),
                    lerp( gradperm(g, a.y, p + [0, -1, 0] ), gradperm(g, a.w, p + [ -1, -1, 0] ), f.x),
                    f.y
                ),
                lerp(
                    lerp( gradperm(g, a.x + one, p + [0, 0, -1] ), gradperm(g, a.z + one, p + [ -1, 0, -1] ), f.x),
                    lerp( gradperm(g, a.y + one, p + [0, -1, -1] ), gradperm(g, a.w + one, p + [ -1, -1, -1] ), f.x),
                    f.y
                ),
                f.z
            );
        }

        function fragment( permut : Texture, g : Texture, cTrans:Float4)
        {
            var pos = tuv;
            var tot = 0;
            var per = 1.0;
            for( k in 0...2 )
            {
                tot += gradient(permut, g, pos) * per;
                per *= 0.5;
                pos *= 2;
            }
            var n = (tot+1) * 0.5;
            out = [n, n, n, 1] * cTrans;
        }
    };

}
