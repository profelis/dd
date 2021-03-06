package tests;
import flash.geom.Point;
import deep.dd.camera.Camera2D;
import deep.dd.display.Sprite2D;
import flash.geom.Vector3D;
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
	var text:TextField2D;

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
		
		var fieldWidth = field.width;
		var fieldHeight = field.height;
		
		text = new TextField2D(field);
		text.pivot = new Point(fieldWidth * 0.5, fieldHeight * 0.5);

        text.x = (world.width - fieldWidth) * 0.5;
        text.y = (world.height - fieldHeight) * 0.5;
		
		wrld.scene.addChild(text);
	}

	override public function updateStep():Void
	{
		text.rotation += 2;
		text.scaleX = text.scaleY = sin0_1(time);

        super.updateStep();
	}
	
	override public function dispose():Void 
	{
		super.dispose();
		text = null;
	}
	
	function sin0_1(t:Float):Float 
	{
		return 0.5 + Math.sin(t) * 0.5;
	}
	
}