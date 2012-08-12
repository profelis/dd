package deep.hxd.display;

import deep.hxd.World2D;

class Scene2D extends Node2D
{
    public function new()
    {
        super();

        scene = this;
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
