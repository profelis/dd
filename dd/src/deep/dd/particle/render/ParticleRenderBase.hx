package deep.dd.particle.render;

import deep.dd.display.render.RenderBase;
import deep.dd.particle.utils.ParticlePresetBase;

class ParticleRenderBase extends RenderBase
{
	var preset:ParticlePresetBase;

	public function new(preset:ParticlePresetBase)
	{
		this.preset = preset;
	}
}