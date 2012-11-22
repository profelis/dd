package deep.dd.display.smart;

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
import deep.dd.material.sprite2d.Sprite2DMaterial;
import deep.dd.geometry.Geometry;
import deep.dd.utils.FastHaxe;

class Batch2D extends SmartSprite2D
{
    public function new()
    {
        super(batchRender = new deep.dd.display.smart.render.BatchRender());
    }

    public var batchRender(default, null):deep.dd.display.smart.render.BatchRender;
}

class Cloud2D extends SmartSprite2D
{

    public function new(startSize:UInt = 20, incSize:UInt = 20)
    {
        super(cloudRender = new deep.dd.display.smart.render.CloudRender(startSize, incSize));
    }

    public var cloudRender(default, null):deep.dd.display.smart.render.CloudRender;

}

class SmartSprite2D extends Sprite2D
{
    public function new(render:RenderBase = null)
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

    public var render(default, setRender):RenderBase;

    function setRender(r:RenderBase):RenderBase
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
}