package deep.dd.display.render;

import deep.dd.display.SmartSprite2D;
import deep.dd.camera.Camera2D;
import deep.dd.geometry.Geometry;
import deep.dd.material.Material;
import deep.dd.material.sprite2d.Sprite2DMaterial;

class SimpleRender extends RenderBase
{
	public function new(renderRoot:Bool = false, material:Material = null)
	{
        this.renderRoot = renderRoot;
		this.material = material != null ? material : new Sprite2DMaterial();

		geometry = Geometry.createTextured();
	}

	override public function copy():RenderBase
	{
		return new SimpleRender(renderRoot, material);
	}

    public var renderRoot:Bool;

	override public function drawStep(camera:Camera2D, invalidateTexture:Bool):Void
	{
		if (renderRoot && smartSprite.texture != null) material.draw(smartSprite, camera);

        for (i in smartSprite.children) if (i.visible) i.drawStep(camera);
	}
}