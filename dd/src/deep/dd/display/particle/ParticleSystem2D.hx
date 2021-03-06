package deep.dd.display.particle;

import deep.dd.display.particle.render.ParticleRenderBase;
import deep.dd.display.smart.SmartSprite2D;

class ParticleSystem2D extends SmartSprite2D
{
    var particleRender:ParticleRenderBase;

    public function new(render:ParticleRenderBase)
    {
        super(particleRender = render);
    }
}
