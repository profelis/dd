package deep.dd.material;

import flash.display3D.Context3D;
import flash.utils.TypedDictionary;
import deep.dd.display.DisplayNode2D;
import deep.dd.camera.Camera2D;
import deep.dd.geometry.Geometry;
import hxsl.Shader;
import flash.display3D.Context3D;

class Material
{
    static var shaderCache:TypedDictionary<Context3D, Hash<Shader>> = new TypedDictionary();
    static var shaderUseCount:TypedDictionary<Context3D, TypedDictionary<Shader, Int>> = new TypedDictionary();

    public var useCount(default, null):Int = 0;

    var shaderRef:Class<Shader>;
    var shader:Shader;

    var useShaderCache:Bool;

    var ctx:Context3D;

    public function new(shaderRef:Class<Shader>, useShaderCache:Bool = true)
    {
        this.shaderRef = shaderRef;
        this.useShaderCache = useShaderCache;
    }

	public static function freeContextCache(ctx:Context3D):Void
	{
        shaderCache.delete(ctx);
	}

    public function init(ctx:Context3D)
    {
        if (this.ctx == ctx) return;

        releaseShader();

        this.ctx = ctx;

        updateShader();
    }

    inline function updateShader()
    {
        if (shaderRef != null)
        {
            if (!shaderCache.exists(ctx)) shaderCache.set(ctx, new Hash());
            if (!shaderUseCount.exists(ctx)) shaderUseCount.set(ctx, new TypedDictionary());

            var useCount = shaderUseCount.get(ctx);

            var key = Type.getClassName(shaderRef);

            if (useShaderCache)
            {
                shader = shaderCache.get(ctx).get(key);
                useCount.set(shader, useCount.get(shader) + 1);
            }
            if (shader == null)
            {
                shaderCache.get(ctx).set(key, shader = Type.createInstance(shaderRef, [ctx]));
                useCount.set(shader, 1);
            }
        }
    }

    inline function releaseShader()
    {
        if (shader != null && useShaderCache)
        {
            var useCount = shaderUseCount.get(ctx);

            if (useCount != null && useCount.exists(shader))
            {
                if (useCount.get(shader) <= 1)
                {
                    useCount.delete(shader);
                    var s = shaderCache.get(ctx);
                    for (i in s.keys())
                    {
                        if (s.get(i) == shader)
                        {
                            s.remove(i);
                            break;
                        }
                    }
                    shader.dispose();
                }
                else
                {
                    useCount.set(shader, useCount.get(shader) - 1);
                }
            }
        }
    }

    public function draw(node:DisplayNode2D, camera:Camera2D)
    {
        #if dd_stat
        node.world.statistics.drawCalls ++;
        node.world.statistics.triangles += node.geometry.triangles;
        #end

        ctx.setBlendFactors(node.blendMode.src, node.blendMode.dst);

        shader.draw(node.geometry.vbuf, node.geometry.ibuf);
    }
	
	public function dispose():Void
	{
        if (useCount > 0) return;

        if (useShaderCache)
            releaseShader();
		else if (shader != null) shader.dispose();

		shader = null;
		ctx = null;
	}
}
