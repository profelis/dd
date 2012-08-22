package deep.dd.display;

import deep.dd.display.render.IRender;
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

class SmartSprite2D extends Sprite2D
{
    public function new(render:IRender)
    {
        drawTransform = new Matrix3D();

        super();

        ignoreInBatch = true;

        this.render = render;
    }

    override function createGeometry()
    {
    }

    public var render(default, setRender):IRender;

    function setRender(r:IRender):IRender
    {
    	#if debug
    	if (r == null) throw "render can't be null";
    	#end
    	
    	if (r == render) return render;

    	render = r;
    	
		ignoreInBatch = render.ignoreInBatch;
		geometry = render.geometry;
		material = render.material;

    	_width = geometry.width;
		_height = geometry.height;	

    	return r;
    }

    override public function drawStep(camera:Camera2D):Void
    {
    	if (geometry.needUpdate) geometry.update();

    	var invalidateTexture = false;
        if (texture != null)
        {
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
            else if (invalidateWorldTransform || invalidateTransform)
            {
                invalidateDrawTransform = true;
            }      
        }

        if (invalidateWorldTransform || invalidateTransform) invalidateDrawTransform = true;

        if (invalidateTransform) updateTransform();
        if (invalidateWorldTransform) updateWorldTransform();
        if (invalidateColorTransform) updateWorldColor();

        if (invalidateDrawTransform) updateDrawTransform();
        
    	render.drawStep(this, camera, invalidateTexture);
    }

    override public function draw(camera:Camera2D):Void
    {
    	// throw "assert";
        if (texture != null)
        {
            super.draw(camera);
        }
    }

    
}