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

        startTime = stepTime = flash.Lib.getTimer() * 0.001;
    }

    public var startTime(default, null):Float;
    public var stepTime(default, null):Float;

    override public function draw(camera:Camera2D):Void
    {
        if (!visible) return;

        stepTime = flash.Lib.getTimer() * 0.001 - stepTime;
        super.draw(camera);
    }

    override public function dispose():Void
	{
		super.dispose();
		world = null;
	}

    override function get_world():World2D
    {
        return world;
    }
}
