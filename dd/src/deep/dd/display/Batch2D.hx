package deep.dd.display;

import deep.dd.display.render.BatchRender;

class Batch2D extends SmartSprite2D
{
    public function new()
    {
        super(batchRender = new BatchRender());
    }

    public var batchRender(default, null):BatchRender;
}
