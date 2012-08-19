package ;
import deep.dd.utils.Stats;
import flash.display.Sprite;
import flash.text.TextFormat;
import mt.m3d.Color;
import flash.display.StageScaleMode;
import flash.display.StageAlign;
import flash.display.StageDisplayState;
import flash.display3D.Context3DRenderMode;
import deep.dd.World2D;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.Lib;
import flash.text.TextField;
import flash.ui.Keyboard;
import tests.QuadTest;
import tests.Test;

class Main extends Sprite
{

    var world:World2D;
	var scenes:Array<Class<Test>>;
	var activeSceneIdx:Int = 0;
	
	var currentScene:Test;
	
	var sceneText:TextField;

    public function new()
    {
        super();
		
		var s = flash.Lib.current.stage;
        s.scaleMode = StageScaleMode.NO_SCALE;
        s.align = StageAlign.TOP_LEFT;
		s.addChild(this);

        world = new World2D(Context3DRenderMode.AUTO);
		world.bgColor = new Color();
		
		var tf:TextFormat = new TextFormat("Arial", 11, 0xFFFFFF, true);
		sceneText = new TextField();
		sceneText.width = Lib.current.stage.stageWidth;
		sceneText.defaultTextFormat = tf;
		addChild(sceneText);
		
		scenes = [QuadTest];
		activeSceneIdx = 0;
		changeScene(activeSceneIdx);
		
		var stats:Stats = new Stats(world);
		addChild(stats);
		
        s.addEventListener(Event.ENTER_FRAME, onRender);
		s.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
    }
	
	function onKeyUp(e:KeyboardEvent):Void 
	{
		if (e.keyCode == Keyboard.D)
		{
			world.ctx.dispose();
		}
		else if (e.keyCode == Keyboard.SPACE || e.keyCode == Keyboard.RIGHT)
		{
			nextDemo();
		}
		else if (e.keyCode == Keyboard.LEFT)
		{
			prevDemo();
		}
	}
	
	private function prevDemo() 
	{
		changeScene(activeSceneIdx - 1);
	}
	
	private function nextDemo() 
	{
		changeScene(activeSceneIdx + 1);
	}
	
	function changeScene(sceneIndex:Int):Void
	{
		if (currentScene != null)
		{
			currentScene.dispose();
		}
		
		if (sceneIndex < 0)
		{
			activeSceneIdx = scenes.length - 1;
		}
		else if (sceneIndex >= scenes.length)
		{
			activeSceneIdx = 0;
		}
		else
		{
			activeSceneIdx = sceneIndex;
		}
		
		sceneText.text = "(" + (activeSceneIdx + 1) + "/" + scenes.length + ") " + Type.getClassName(scenes[activeSceneIdx]) + " // hit space or right = next test, left = prev test, d = device loss";
	//	world.cache.reinitBitmapTextureCache();
		currentScene = Type.createInstance(scenes[activeSceneIdx], [world]);
	}

    function onRender(_)
    {
        currentScene.update();
    }

    static function main()
    {
        new Main();
    }
}