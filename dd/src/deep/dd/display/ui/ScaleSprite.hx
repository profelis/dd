package deep.dd.display.ui;

import deep.dd.display.smart.render.RenderBase;
import deep.dd.display.smart.SmartSprite2D;
import deep.dd.display.Sprite2D;
import deep.dd.texture.atlas.AtlasTexture2D;
import deep.dd.texture.SubTexture2D;
import deep.dd.texture.Texture2D;
import deep.dd.utils.Frame;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import hxsl.Shader;
import mt.m3d.Color;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class ScaleSprite<T:Shader> extends SmartSprite2D<T>
{

	public var rect(default, set):Rectangle;

	var needUpdate = true;
	var needUpdateTexture = true;
	var items:Array<Sprite2D>;
	var textures:Array<SubTexture2D>;
	
	public var stepX(default, set):Int = 3;
	public var stepY(default, set):Int = 3;
	
	public function new(render:RenderBase<T> = null) 
	{
		super(render);
	}
	
	function set_stepX(v) {
		if (v != 1 && v != 3) throw "support only 1 or 3";
		needUpdateTexture = true;
		return stepX = v;
	}
	
	function set_stepY(v) {
		if (v != 1 && v != 3) throw "support only 1 or 3";
		needUpdateTexture = true;
		return stepY = v;
	}
	
	function set_rect(r) {
		needUpdateTexture = true;
		return rect = r;
	}
	
	override function set_texture(tex:Texture2D):Texture2D 
	{
		if (tex != texture) needUpdateTexture = true;
		return super.set_texture(tex);
	}
	
	function updateTexture() {
		if (textures != null) {
			for (t in textures) {
				t.dispose();
			}
			textures = null;
		}
		if (texture != null && rect != null) {
			
			var n = stepX * stepY;
			if (items == null || items.length != n) {
				if (items == null) items = [];
				while (items.length > n) items.pop().dispose();
				while (items.length < n) {
					var s = new Sprite2D();
					addChild(s);
					items.push(s);
				}
			}
			var tw = texture.width;
			var th = texture.height;
			var ftw = texture.textureWidth;
			var fth = texture.textureHeight;
			var ws = stepX == 1 ? [tw] : [rect.x, rect.width, tw - rect.right];
			var hs = stepY == 1 ? [th] : [rect.y, rect.height, th - rect.bottom];
			var ox = [0.0, rect.x, rect.right];
			var oy = [0.0, rect.y, rect.bottom];
			textures = [];
			for (i in 0...n) {
				var x = Std.int(i / stepY);
				var y = i % stepY;
				var t = new SubTexture2D(texture);
				textures.push(t);
				var r = new Vector3D(ox[x] / ftw, oy[y] / fth, ws[x] / ftw, hs[y] / fth);
				t.frame = new Frame(ws[x], hs[y], r);
				items[i].texture = t;
			}
			needUpdateTexture = false;
			needUpdate = true;
		}
	}
	
	override public function updateStep() 
	{
		if (needUpdateTexture) updateTexture();
		if (needUpdate && textures != null) {
			var w = displayWidth;
			var h = displayHeight;
			var tw = texture.width;
			var th = texture.height;
			
			var ox = stepX == 1 ? [0.0] : [0.0, rect.x, w - tw + rect.right];
			var oy = stepY == 1 ? [0.0] : [0.0, rect.y, h - th + rect.bottom];
			var sx = (w - tw + rect.width) / rect.width;
			var sy = (h - th + rect.height) / rect.height;
			var sxi = stepX == 1 ? 0 : 1;
			var syi = stepY == 1 ? 0 : 1;
			var n = stepX * stepY;
			for (i in 0...n) {
				var x = Std.int(i / stepY);
				var y = i % stepY;
				var s = items[i];
				s.x = ox[x];
				s.y = oy[y];
				if (x == sxi) s.scaleX = sx;
				if (y == syi) s.scaleY = sy;
			}
			needUpdate = false;
		}
		super.updateStep();
	}
	
	override function set_displayWidth(w) {
		invalidateDisplayBounds = true;
		return _displayWidth = w;
	}
	
	override function set_displayHeight(h) {
		invalidateDisplayBounds = true;
		return _displayHeight = h;
	}
	
	override public function dispose() {
		if (textures != null) {
			for (t in textures) {
				t.dispose();
			}
		}
		super.dispose();
		textures = null;
		items = null;
	}
}