package deep.dd.utils;

import deep.dd.World2D;

class Statistics
{
    public var drawCalls:UInt;

    public var triangles:UInt;

    var w:World2D;

    public function new(wrld:World2D)
    {
        w = wrld;
    }

    public function reset()
    {
        drawCalls = 0;
        triangles = 0;
    }

    public function dispose()
    {
        w = null;
    }

    public function toString()
    {
        return '{Statistics triangles: $triangles, drawCalls: $drawCalls}';
    }
}
