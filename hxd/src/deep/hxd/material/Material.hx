package deep.hxd.material;

import flash.utils.TypedDictionary;
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

    /**
     * @private
    **/
    public var useCount:Int = 0;

    var shader:Shader;
    var ctx:Context3D;

    static var shaderCache:TypedDictionary<Context3D, Hash<Shader>> = new TypedDictionary();

    public function init(ctx:Context3D)
    {
        this.ctx = ctx;
        if (!shaderCache.exists(ctx)) shaderCache.set(ctx, new Hash());
        var key = Type.getClassName(shaderRef);

        if (useShaderCache)
        {
            shader = shaderCache.get(ctx).get(key);
            if (shader != null) trace("shader from cache " + shader);
        }
        if (shader == null)
        {
            shaderCache.get(ctx).set(key, shader = Type.createInstance(shaderRef, [ctx]));
            trace("create new shader " + shader);
        }
    }

    public function draw(sprite:DisplayNode2D, camera:Camera2D)
    {
        ctx.setBlendFactors(sprite.blendMode.src, sprite.blendMode.dst);

        shader.draw(sprite.geometry.vbuf, sprite.geometry.ibuf);
    }
	
	public function dispose():Void
	{
        if (useCount > 0) return;

		if (!useShaderCache && shader != null) shader.dispose();
		shader = null;
		ctx = null;
	}
}
