package deep.dd.particle.render;

import deep.dd.display.render.RenderBase;
import deep.dd.particle.utils.ParticlePresetBase;

class ParticleRenderBase extends RenderBase
{
	public var preset(default, set_preset):ParticlePresetBase;

    function set_preset(p:ParticlePresetBase):ParticlePresetBase
    {
        #if debug
        if (p == null) throw "preset can't be null";
        #end
        return preset = p;
    }

	public function new(preset:ParticlePresetBase)
	{
		this.preset = preset;
        ignoreInBatch = true;
	}
}