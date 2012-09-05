package deep.dd.material.gravityParticle2D;

import deep.dd.display.SmartSprite2D;
import deep.dd.particle.ParticleSystem2D;
import deep.dd.utils.Frame;
import flash.Vector;
import deep.dd.display.DisplayNode2D;
import flash.geom.Vector3D;
import flash.geom.Matrix3D;
import deep.dd.material.sprite2d.Sprite2DMaterial;
import deep.dd.texture.Texture2D;
import deep.dd.material.Material;
import deep.dd.display.Sprite2D;
import deep.dd.camera.Camera2D;
import deep.dd.display.DisplayNode2D;
import deep.dd.material.Quad2DMaterial;
import deep.dd.utils.FastHaxe;
import flash.display3D.Context3D;
import hxsl.Shader;

class GravityParticle2DMaterial extends Material
{
    public function new()
    {
        super(null);
        texSize = new Vector3D();
        gravity = new Vector3D();
    }

    var texOpt:UInt = 0;

    inline function updateShaderRef()
    {
        shaderRef = SHADERS.get(texOpt & 0x60).get(texOpt & 0x18).get(texOpt & 0x7);
    }

    var texSize:Vector3D;
    var gravity:Vector3D;

    public function drawParticleSystem(node:SmartSprite2D, camera:Camera2D, renderSize:UInt, gravity:Vector3D)
    {
        var tex = node.texture;

        if (texOpt != tex.options)
        {
            texOpt = tex.options;
            updateShaderRef();
            attachShader();
        }

        texSize.x = tex.width;
        texSize.y = tex.height;

        this.gravity.setTo(gravity.x / texSize.x, gravity.y / texSize.y, gravity.z);

        untyped shader.init({time:node.scene.time, mproj:camera.proj, mpos:node.drawTransform, gravity:this.gravity, region:tex.frame.region, texSize:texSize, pcTrans:node.worldColorTransform}, {tex:tex.texture});

        #if dd_stat
        node.world.statistics.drawCalls ++;
        node.world.statistics.triangles += renderSize * 2;
        #end

        ctx.setBlendFactors(node.blendMode.src, node.blendMode.dst);

        shader.bind(node.geometry.vbuf);
        ctx.drawTriangles(node.geometry.ibuf, 0, renderSize * 2);
        shader.unbind();
    }

    override public function draw(node:DisplayNode2D, camera:Camera2D)
    {
        throw "use drawCloud";
    }

    public static var SHADERS(default, null):IntHash<IntHash<IntHash<Class<Shader>>>> = initSHADERS();

    static function initSHADERS()
    {
        var res = new IntHash();

        var a = new IntHash<Class<Shader>>();
        a.set(Texture2DOptions.MIPMAP_DISABLE, WrapNearestNo);
        a.set(Texture2DOptions.MIPMAP_NEAREST, WrapNearestNearest);
        a.set(Texture2DOptions.MIPMAP_LINEAR, WrapNearestLinear);

        var b = new IntHash<Class<Shader>>();
        b.set(Texture2DOptions.MIPMAP_DISABLE, WrapLinearNo);
        b.set(Texture2DOptions.MIPMAP_NEAREST, WrapLinearNearest);
        b.set(Texture2DOptions.MIPMAP_LINEAR, WrapLinearLinear);

        var ab = new IntHash();
        ab.set(Texture2DOptions.FILTERING_NEAREST, a);
        ab.set(Texture2DOptions.FILTERING_LINEAR, b);
        res.set(Texture2DOptions.REPEAT_NORMAL, ab);

        var c = new IntHash<Class<Shader>>();
        c.set(Texture2DOptions.MIPMAP_DISABLE, ClampNearestNo);
        c.set(Texture2DOptions.MIPMAP_NEAREST, ClampNearestNearest);
        c.set(Texture2DOptions.MIPMAP_LINEAR, ClampNearestLinear);

        var d = new IntHash<Class<Shader>>();
        d.set(Texture2DOptions.MIPMAP_DISABLE, ClampLinearNo);
        d.set(Texture2DOptions.MIPMAP_NEAREST, ClampLinearNearest);
        d.set(Texture2DOptions.MIPMAP_LINEAR, ClampLinearLinear);

        var cd = new IntHash();
        cd.set(Texture2DOptions.FILTERING_NEAREST, c);
        cd.set(Texture2DOptions.FILTERING_LINEAR, d);
        res.set(Texture2DOptions.REPEAT_CLAMP, cd);

        return res;
    }

}

class WrapNearestNo extends Shader
{
    static var SRC = {
        include("./deep/dd/material/gravityParticle2D/GravityParticle2DShader.hxsl");

        function texture(t:Texture, uv:Float2)
            return t.get(uv, wrap, nearest, mm_no);
    };
}

class WrapNearestNearest extends Shader
{
    static var SRC = {
        include("./deep/dd/material/gravityParticle2D/GravityParticle2DShader.hxsl");

        function texture(t:Texture, uv:Float2)
            return t.get(uv, wrap, nearest, mm_near);
    };
}

class WrapNearestLinear extends Shader
{
    static var SRC = {
        include("./deep/dd/material/gravityParticle2D/GravityParticle2DShader.hxsl");

        function texture(t:Texture, uv:Float2)
            return t.get(uv, wrap, nearest, mm_linear);
    };
}

class WrapLinearNo extends Shader
{
    static var SRC = {
        include("./deep/dd/material/gravityParticle2D/GravityParticle2DShader.hxsl");

        function texture(t:Texture, uv:Float2)
            return t.get(uv, wrap, linear, mm_no);
    };
}

class WrapLinearNearest extends Shader
{
    static var SRC = {
        include("./deep/dd/material/gravityParticle2D/GravityParticle2DShader.hxsl");

        function texture(t:Texture, uv:Float2)
            return t.get(uv, wrap, linear, mm_near);
    };
}

class WrapLinearLinear extends Shader
{
    static var SRC = {
        include("./deep/dd/material/gravityParticle2D/GravityParticle2DShader.hxsl");

        function texture(t:Texture, uv:Float2)
            return t.get(uv, wrap, linear, mm_linear);
    };
}

class ClampNearestNo extends Shader
{
    static var SRC = {
        include("./deep/dd/material/gravityParticle2D/GravityParticle2DShader.hxsl");

        function texture(t:Texture, uv:Float2)
            return t.get(uv, clamp, nearest, mm_no);
    };
}

class ClampNearestNearest extends Shader
{
    static var SRC = {
        include("./deep/dd/material/gravityParticle2D/GravityParticle2DShader.hxsl");

        function texture(t:Texture, uv:Float2)
            return t.get(uv, clamp, nearest, mm_near);
    };
}

class ClampNearestLinear extends Shader
{
    static var SRC = {
        include("./deep/dd/material/gravityParticle2D/GravityParticle2DShader.hxsl");

        function texture(t:Texture, uv:Float2)
            return t.get(uv, clamp, nearest, mm_linear);
    };
}

class ClampLinearNo extends Shader
{
    static var SRC = {
        include("./deep/dd/material/gravityParticle2D/GravityParticle2DShader.hxsl");

        function texture(t:Texture, uv:Float2)
            return t.get(uv, clamp, linear, mm_no);
    };
}

class ClampLinearNearest extends Shader
{
    static var SRC = {
        include("./deep/dd/material/gravityParticle2D/GravityParticle2DShader.hxsl");

        function texture(t:Texture, uv:Float2)
            return t.get(uv, clamp, linear, mm_near);
    };
}

class ClampLinearLinear extends Shader
{
    static var SRC = {
        include("./deep/dd/material/gravityParticle2D/GravityParticle2DShader.hxsl");

        function texture(t:Texture, uv:Float2)
            return t.get(uv, clamp, linear, mm_linear);
    };
}