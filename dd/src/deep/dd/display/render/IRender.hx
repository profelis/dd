package deep.dd.display.render;

import deep.dd.camera.Camera2D;
import deep.dd.display.SmartSprite2D;
import deep.dd.geometry.Geometry;
import deep.dd.material.Material;

interface IRender
{
	//var smartSprite:SmartSprite2D;

	var geometry(default, null):Geometry;

	var material(default, null):Material;

	var ignoreInBatch(default, null):Bool;

	function drawStep(s:SmartSprite2D, camera:Camera2D, invalidateTexture:Bool):Void;
}