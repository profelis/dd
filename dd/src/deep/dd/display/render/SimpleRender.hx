package deep.dd.display.render;

import deep.dd.camera.Camera2D;
import deep.dd.geometry.Geometry;
import deep.dd.material.Material;
import deep.dd.material.sprite2d.Sprite2DMaterial;

class SimpleRender implements IRender
{
	public function new(material:Material = null)
	{
		this.material = material != null ? material : new Sprite2DMaterial();

		geometry = Geometry.createTextured();
	}

	public var material(default, null):Material;

	public var geometry(default, null):Geometry;

	public var ignoreInBatch(default, null):Bool = false;

	public function drawStep(s:SmartSprite2D, camera:Camera2D, invalidateTexture:Bool):Void
	{
		if (s.texture != null) material.draw(s, camera);

        for (i in s.iterator()) if (i.visible) i.drawStep(camera);
	}
}