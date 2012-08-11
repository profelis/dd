package deep.hxd.display;

import deep.hxd.World2D;
class Scene2D extends Node2D
{
    public function new()
    {
        super();

        scene = this;
    }

    public var world(default, null):World2D;
}
