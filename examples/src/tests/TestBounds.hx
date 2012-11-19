package tests;
import deep.dd.texture.Texture2D.BitmapTexture2D;
import flash.display.BitmapData;
import deep.dd.display.Sprite2D;
import flash.geom.Vector3D;
import deep.dd.camera.Camera2D;
import flash.geom.Rectangle;
import mt.m3d.Camera;
import deep.dd.display.Quad2D;
import deep.dd.display.Node2D;
import deep.dd.geometry.Geometry;
import deep.dd.World2D;
import flash.Lib;

/**
 * ...
 * @author Zaphod
 */

class TestBounds extends Test
{
	var container:Node2D;
	var boundQuad:Quad2D;
	
	var quad1:Quad2D;
	var quad2:Sprite2D;
	
	var b:Rectangle;
	
	public function new(wrld:World2D) 
	{
		super(wrld);
        rotation = 10;
		
		boundQuad = new Quad2D();
		boundQuad.color = 0xff0000ff;
		boundQuad.displayWidth = 200;
        boundQuad.displayHeight = 100;
		addChild(boundQuad);
		
		container = new Node2D();
		container.x = Lib.current.stage.stageWidth / 2;
		container.y = Lib.current.stage.stageHeight / 2;
		addChild(container);
		
		quad1 = new Quad2D();
        quad1.displayWidth = 200;
        quad1.displayHeight = 100;
		quad1.x = 10;
		quad1.y = 20;
		quad1.geometry.setColor(0xff0000);
		container.addChild(quad1);
        quad1.mouseEnabled = true;
        quad1.onMouseOver.add(function (_,_) quad1.color = 0xFFFF00);
        quad1.onMouseOut.add(function (_,_) quad1.color = 0xFFFFFF);

		quad2 = new Sprite2D();
        var b = new BitmapData(64, 64, false, 0x00ff00);
        quad2.texture = new BitmapTexture2D(b);
		//quad2.rotation = 30;
		quad2.x = -10;
		quad2.y = 10;
        quad2.pivot = new Vector3D(2, 1);
		container.addChild(quad2);
	}
	
	override public function updateStep():Void
	{
		quad1.rotation += 2;
		quad2.rotation -= 1;
		
		container.rotation -= 0.2;
		if (container.scaleY < 2) container.scaleY += 0.002;
		//container.y -= 0.02;

		b = container.getBounds(this, b);


		boundQuad.x = b.x;
		boundQuad.y = b.y;
		boundQuad.displayWidth = b.width;
		boundQuad.displayHeight = b.height;

        super.updateStep();
	}
	
	override public function dispose():Void 
	{
		super.dispose();
		quad1 = null;
		quad2 = null;
		container = null;
		boundQuad = null;
		
		b = null;
	}
	
}