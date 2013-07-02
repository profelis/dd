package deep.dd.display.smart;

import deep.dd.display.Node2D;
import deep.dd.display.smart.render.RenderBase;
import deep.dd.display.Sprite2D;
import deep.dd.texture.atlas.AtlasTexture2D;
import deep.dd.utils.Frame;
import deep.dd.material.Material;
import deep.dd.animation.AnimatorBase;
import flash.geom.Matrix3D;
import deep.dd.camera.Camera2D;
import flash.display3D.Context3D;
import deep.dd.texture.Texture2D;
import deep.dd.material.Sprite2DMaterial;
import deep.dd.geometry.Geometry;
import deep.dd.utils.FastHaxe;
import hxsl.Shader;
/*
class Batch2D extends SmartSprite2D<deep.dd.material.Batch2DMaterial.Batch2DShader>
{
    public function new()
    {
        super(batchRender = new deep.dd.display.smart.render.BatchRender());
    }

    public var batchRender(default, null):deep.dd.display.smart.render.BatchRender;
}
*/
class Cloud2D extends SmartSprite2D<deep.dd.material.Cloud2DMaterial.Cloud2DShader>
{

    public function new(startSize:UInt = 20, incSize:UInt = 20)
    {
        super(cloudRender = new deep.dd.display.smart.render.CloudRender(startSize, incSize));
    }

    public var cloudRender(default, null):deep.dd.display.smart.render.CloudRender;

}

class SmartSprite2D<T:Shader> extends BaseSprite2D<T>
{
    public function new(render:RenderBase<T> = null)
    {
        super();

        this.render = render;

        mouseChildren = false;
    }

    override function createGeometry()
    {
    }

    override public function dispose():Void
    {
        super.dispose();

        if (render != null)
        {
            render.dispose(false);
            Reflect.setField(this, "render", null);
        }
    }

    public var render(default, set):RenderBase<T>;

    function set_render(r:RenderBase<T>):RenderBase<T>
    {
    	if (r == render) return render;

    	render = r;
        render.smartSprite = this;
    	
		ignoreInBatch = render.ignoreInBatch;

		geometry = render.geometry;
		material = render.material;

        if (texture == null)
        {
            _displayWidth = geometry.width;
            _displayHeight = geometry.height;
        }

    	return r;
    }

    override public function updateStep()
    {
        if (render != null) render.updateStep();
    }

    /**
    * @private
    **/
    public function nativeUpdateStep()
    {
        super.updateStep();
    }

    override public function drawStep(camera:Camera2D):Void
    {
        if (render != null) render.drawStep(camera);
    }

    override public function addChildAt(c:Node2D, pos:UInt):Void
    {
        super.addChildAt(c, pos);

        var s:Sprite2D = flash.Lib.as(c, Sprite2D);
        if (s != null && s.texture == null) s.texture = texture;
    }

    override function set_texture(tex:Texture2D):Texture2D
    {
        var old = texture;
        var res = super.set_texture(tex);

        if (children != null)
            for (c in children)
            {
                var s = flash.Lib.as(c, Sprite2D);
                if (s != null && s.texture == old) s.texture = res;
            }

        return res;
    }
}