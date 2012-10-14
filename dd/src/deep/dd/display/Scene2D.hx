package deep.dd.display;

import haxe.Timer;
import deep.dd.camera.Camera2D;
import deep.dd.World2D;

class Scene2D extends Node2D
{
    public function new()
    {
        super();

        scene = this;
    }

    override function setParent(n)
    {
        throw "scene can't has parent";
    }

    public var timeScale:Float = 1;

    public var time(default, null):Float;

    override public function drawStep(camera:Camera2D):Void
    {
        if (!visible) return;

        time = flash.Lib.getTimer() * 0.001 * timeScale;

        super.drawStep(camera);
    }

    override public function dispose():Void
	{
		super.dispose();
		world = null;
        scene = null;
	}

    override function get_world():World2D
    {
        return world;
    }
}
