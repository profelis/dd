package tests;
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
	var quad2:Quad2D;
	
	var bounds:Rectangle;
	
	public function new(wrld:World2D) 
	{
		super(wrld);
		
		boundQuad = new Quad2D();
		boundQuad.color = 0xff0000ff;
		boundQuad.width = 200;
        boundQuad.height = 100;
		addChild(boundQuad);
		
		container = new Node2D();
		container.x = Lib.current.stage.stageWidth / 2;
		container.y = Lib.current.stage.stageHeight / 2;
		addChild(container);
		
		quad1 = new Quad2D();
        quad1.width = 200;
        quad1.height = 100;
		quad1.x = 10;
		quad1.y = 20;
		quad1.geometry.setColor(0xff0000);
		container.addChild(quad1);
		
		quad2 = new Quad2D();
        quad2.width = 50;
        quad2.height = 150;
		quad2.rotation = 30;
		quad2.x = -10;
		quad2.y = 10;
		quad2.geometry.setColor(0x00ff00);
		container.addChild(quad2);
	}
	
	override public function updateStep():Void
	{
		quad1.rotation += 2;
		quad2.rotation -= 1;
		
		container.rotation += 0.5;
		
		bounds = container.getBounds(bounds);
		
		boundQuad.x = bounds.x;
		boundQuad.y = bounds.y;
		boundQuad.width = bounds.width;
		boundQuad.height = bounds.height;

        super.updateStep();
	}
	
	override public function dispose():Void 
	{
		super.dispose();
		quad1 = null;
		quad2 = null;
		container = null;
		boundQuad = null;
		
		bounds = null;
	}
	
}