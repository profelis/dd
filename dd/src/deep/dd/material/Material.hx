package deep.dd.material;

import flash.display3D.Context3D;
import deep.dd.display.DisplayNode2D;
import deep.dd.camera.Camera2D;
import deep.dd.geometry.Geometry;
import hxsl.Shader;
import flash.display3D.Context3D;

class Material<T:hxsl.Shader>
{
    public var useCount(default, default):Int = 0;

    var shader:T;

    var ctx:Context3D;

    public function new(shader:T)
    {
        this.shader = shader;
    }

    public function init(ctx:Context3D)
    {
        if (this.ctx == ctx) return;

        this.ctx = ctx;
    }

    public function draw(node:DisplayNode2D<T>, camera:Camera2D)
    {
        #if dd_stat
        node.world.statistics.drawCalls ++;
        node.world.statistics.triangles += node.geometry.triangles;
        #end

        ctx.setBlendFactors(node.blendMode.src, node.blendMode.dst);

        shader.bind(ctx, node.geometry.vbuf);
        ctx.drawTriangles(node.geometry.ibuf);
        shader.unbind(ctx);
    }
	
	public function dispose():Void
	{
        if (useCount > 0) return;

		shader = null;
		ctx = null;
	}
}