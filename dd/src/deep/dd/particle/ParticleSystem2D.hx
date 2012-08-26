package deep.dd.particle;

import deep.dd.display.render.ParticleRenderBase;
import deep.dd.display.SmartSprite2D;

class ParticleSystem2D extends SmartSprite2D
{
    var particleRender:ParticleRenderBase;

    public function new(render:ParticleRenderBase)
    {
        super(particleRender = render);
    }
}
