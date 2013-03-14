package deep.dd.display.ui;

import deep.dd.display.smart.render.RenderBase;
import deep.dd.display.smart.SmartSprite2D;
import deep.dd.display.Sprite2D;
import deep.dd.texture.atlas.AtlasTexture2D;
import deep.dd.texture.Texture2D;
import deep.dd.utils.Frame;
import flash.geom.Rectangle;
import hxsl.Shader;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class Scale9Sprite<T:Shader> extends SmartSprite2D<T>
{

	public var rect(default, set):Rectangle;
	var needUpdate = true;
	var items:Array<Sprite2D>;
	var textures:Array<SubTexture2D>;
	
	public function new(render:RenderBase<T> = null) 
	{
		super(render);
		
		items = [];
		for (x in 0...9) {
			var i = new Sprite2D();
			items.push(i);
			addChild(i);
		}
	}
	
	function set_rect(r) {
		needUpdate = true;
		return rect = r;
	}
	
	override function set_texture(tex:Texture2D):Texture2D 
	{
		if (tex != texture) {
			if (textures != null)
				for (t in textures) {
					t.dispose();
				}
			needUpdate = true;
		}
		return super.set_texture(tex);
	}
	
	override public function updateStep():Dynamic 
	{
		if (needUpdate && texture != null) {
			var w = displayWidth;
			var h = displayHeight;
			var tw = texture.width;
			var th = texture.height;
			if (textures == null || textures[0].base
			textures = [];
			for (i in 0...9) {
				var x = Std.int(i / 3);
				var y = i % 3;
				var t = new SubTexture2D(res);
				textures.push(t);
				t.frame = new Frame(
			}
			for (i in 0...9) {
				var x = Std.int(i / 3);
				var y = i % 3;
			}
			needUpdate = false;
		}
		super.updateStep();
	}
	
}