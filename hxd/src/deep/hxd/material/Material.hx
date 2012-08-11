package deep.hxd.material;

import deep.hxd.display.DisplayNode2D;
import deep.hxd.camera.Camera2D;
import deep.hxd.geometry.Geometry;
import format.hxsl.Shader;
import flash.display3D.Context3D;

class Material
{
    var shaderRef:Class<Shader>;

    var useShaderCache:Bool;

    public function new(shaderRef:Class<Shader>, useShaderCache:Bool = true)
    {
        this.shaderRef = shaderRef;
        this.useShaderCache = useShaderCache;
    }

    var shader:Shader;
    var ctx:Context3D;

    static var shaderCache:Hash<Shader> = new Hash();

    public function init(ctx:Context3D)
    {
        this.ctx = ctx;
        var key = Type.getClassName(shaderRef);
        if (useShaderCache)
        {
            shader = shaderCache.get(key);
        }
        if (shader == null)
        {
            shaderCache.set(key, shader = Type.createInstance(shaderRef, [ctx]));
        }
    }

    public function draw(sprite:DisplayNode2D, camera:Camera2D)
    {
        ctx.setBlendFactors(sprite.blendMode.src, sprite.blendMode.dst);

        shader.draw(sprite.geometry.vbuf, sprite.geometry.ibuf);
    }
}
