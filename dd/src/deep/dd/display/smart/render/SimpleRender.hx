package deep.dd.display.smart.render;

import deep.dd.display.smart.SmartSprite2D;
import deep.dd.camera.Camera2D;
import deep.dd.geometry.Geometry;
import deep.dd.material.Material;
import deep.dd.material.Sprite2DMaterial;
import hxsl.Shader;

class SimpleRender extends RenderBase<Sprite2DShader>
{
	public function new(renderRoot:Bool = true, material:Material<Sprite2DShader> = null)
	{
        this.renderRoot = renderRoot;
		this.material = material != null ? material : new Sprite2DMaterial();

		geometry = Geometry.createTextured();
	}

	override public function copy():RenderBase<Sprite2DShader>
	{
		return new SimpleRender(renderRoot, material);
	}

    public var renderRoot:Bool;

    override public function updateStep()
    {
        smartSprite.nativeUpdateStep();
    }

    override public function drawStep(camera:Camera2D):Void
	{
		if (renderRoot) material.draw(smartSprite, camera);

        for (i in smartSprite.children) if (i.visible) i.drawStep(camera);
	}
}