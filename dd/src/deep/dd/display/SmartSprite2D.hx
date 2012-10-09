package deep.dd.display;

import deep.dd.display.render.RenderBase;
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
        super(batchRender = new deep.dd.display.render.BatchRender());
    }

    public var batchRender(default, null):deep.dd.display.render.BatchRender;
}

class Cloud2D extends SmartSprite2D
{

    public function new(startSize:UInt = 20, incSize:UInt = 20)
    {
        super(cloudRender = new deep.dd.display.render.CloudRender(startSize, incSize));
    }

    public var cloudRender(default, null):deep.dd.display.render.CloudRender;

}

class SmartSprite2D extends Sprite2D
{
    public function new(render:RenderBase = null)
    {
        super();

        this.render = render;
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
            _width = geometry.width;
            _height = geometry.height;	
        }

    	return r;
    }

    override public function drawStep(camera:Camera2D):Void
    {
        if (render == null) return;

    	if (geometry.needUpdate) geometry.update();

        var hasTexture = texture != null;
    	var invalidateTexture = false;
        if (hasTexture)
        {
            if (texture.needUpdate) texture.update();

            var f = texture.frame;
            if (animator != null)
            {
                animator.draw(scene.time);
                f = animator.textureFrame;
            }

            if (textureFrame != f)
            {
            	invalidateTexture = true;
                invalidateDrawTransform = true;
                textureFrame = f;
                _width = textureFrame.width;
                _height = textureFrame.height;
            }    
        }

        if (invalidateWorldTransform || invalidateTransform) invalidateDrawTransform = true;

        if (invalidateTransform) updateTransform();
        if (invalidateWorldTransform) updateWorldTransform();
        if (invalidateColorTransform) updateWorldColor();

        if (hasTexture && invalidateDrawTransform) updateDrawTransform();
        
    	render.drawStep(camera, invalidateTexture);
    }  
}