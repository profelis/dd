package deep.hxd.material;
import deep.hxd.display.DisplayNode2D;
import deep.hxd.camera.Camera2D;
import deep.hxd.geometry.Geometry;
import format.hxsl.Shader;
import flash.display3D.Context3D;

class Material
{
    var shaderRef:Class<Shader>;

    public function new(shaderRef:Class<Shader>)
    {
        this.shaderRef = shaderRef;
    }

    var shader:Shader;
    var ctx:Context3D;

    public function init(ctx:Context3D)
    {
        this.ctx = ctx;
        if (shader == null) shader = Type.createInstance(shaderRef, [ctx]);
    }

    public function draw(sprite:DisplayNode2D, camera:Camera2D)
    {
        ctx.setBlendFactors(sprite.blendMode.src, sprite.blendMode.dst);

        shader.draw(sprite.geometry.vbuf, sprite.geometry.ibuf);
    }
}
