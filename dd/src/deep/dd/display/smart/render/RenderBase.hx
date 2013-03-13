package deep.dd.display.smart.render;

import deep.dd.camera.Camera2D;
import deep.dd.display.smart.SmartSprite2D;
import deep.dd.geometry.Geometry;
import deep.dd.material.Material;

class RenderBase
{
	public var geometry(default, null):Geometry;

	public var material(default, null):Material;

	public var ignoreInBatch(default, null):Bool = false;

	public var smartSprite(default, set):SmartSprite2D;

	function set_smartSprite(s)
	{
		#if debug
		if (smartSprite != null) "can't reasing render. Use render.copy()";
		#end

		return smartSprite = s;
	}

    public function updateStep()
    {
        throw "override me";
    }

	public function drawStep(camera:Camera2D):Void
	{
		throw "override me";
	}

	public function copy():RenderBase
	{
		throw "not implemented";
		return null;
	}

	public function dispose(deep = true)
	{
		if (deep)
        {
            material.dispose();
            geometry.dispose();
        }

		material = null;
		geometry = null;
		Reflect.setField(this, "smartSprite", null);
	}
}