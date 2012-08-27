package tests;
import deep.dd.camera.Camera2D;
import deep.dd.display.Sprite2D;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import mt.m3d.Camera;
import deep.dd.display.flash.TextField2D;
import deep.dd.geometry.Geometry;
import deep.dd.World2D;
import flash.Lib;

/**
 * ...
 * @author Zaphod
 */

class TextFieldTest extends Test
{
	var textWrapper:Sprite2D;
	
	public function new(wrld:World2D) 
	{
		super(wrld);
		
		var field:TextField = new TextField();
		var format:TextFormat = new TextFormat("helvetica", 100, 0xffffff);
		format.align = TextFormatAlign.CENTER;
		field.defaultTextFormat = format;
		field.multiline = true;
		field.text = "This is TextField2D instance!\nAnd it's multiline";
		field.width = field.textWidth;
		field.height = field.textHeight * 2;
		
		var text:TextField2D = new TextField2D(field);
		
		textWrapper = new Sprite2D();
		textWrapper.addChild(text);
		text.x = -field.width * 0.5;
		text.y = -field.height * 0.5;
		
		wrld.scene.addChild(textWrapper);
	}
	
	override public function drawStep(camera:Camera2D):Void
	{
		var time:Float = Lib.getTimer() / 1000;
		textWrapper.x = world.width * 0.5;
		textWrapper.y = world.height * 0.5;
		textWrapper.rotationZ += 2;
		textWrapper.rotationX += 1;
		textWrapper.scaleX = textWrapper.scaleY = sin0_1(time);

        super.drawStep(camera);
	}
	
	override public function dispose():Void 
	{
		super.dispose();
		textWrapper = null;
	}
	
	function sin0_1(t:Float):Float 
	{
		return 0.5 + Math.sin(t) * 0.5;
	}
	
}