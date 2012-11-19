package deep.dd.display;

import flash.geom.Vector3D;
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

    public function update()
    {
        time = flash.Lib.getTimer() * 0.001 * timeScale;
        updateStep();
    }

    override function displayMouseStep(p:Vector3D)
    {
        p = globalToLocal(p);
        if (p.x >= 0 && p.x <= world.width && p.y >= 0 && p.y <= world.height)
        {
            mouseX = p.x;
            mouseY = p.y;
            return true;
        }
        mouseX = Math.NaN;
        mouseY = Math.NaN;
        return false;
    }

    override public function dispose():Void
	{
		super.dispose();
		world = null;
        scene = null;
	}
}
