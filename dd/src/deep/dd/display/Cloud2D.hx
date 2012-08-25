package deep.dd.display;

import deep.dd.display.render.CloudRender;

class Cloud2D extends SmartSprite2D
{

    public function new(startSize:UInt = 20, incSize:UInt = 20)
    {
        super(cloudRender = new CloudRender(startSize, incSize));
    }

    public var cloudRender(default, null):CloudRender;

}
