package deep.dd.display.render;

import deep.dd.camera.Camera2D;
import deep.dd.display.SmartSprite2D;
import deep.dd.geometry.Geometry;
import deep.dd.material.Material;

class RenderBase
{
	public var geometry(default, null):Geometry;

	public var material(default, null):Material;

	public var ignoreInBatch(default, null):Bool = false;

	public var smartSprite(default, set_smartSprite):SmartSprite2D;

	function set_smartSprite(s)
	{
		#if debug
		if (smartSprite != null) "render using. Use render.copy()";
		#end

		return smartSprite = s;
	}

	public function drawStep(s:SmartSprite2D, camera:Camera2D, invalidateTexture:Bool):Void
	{
		throw "override me";
	}

	public function copy():RenderBase
	{
		throw "not implemented";
		return null;
	}

	public function dispose()
	{
		material.dispose();
		material = null;
		geometry.dispose();
		geometry = null;
		Reflect.setField(this, "smartSprite", null);
	}
}