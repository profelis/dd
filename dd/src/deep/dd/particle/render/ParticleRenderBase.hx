package deep.dd.display.render;

import deep.dd.display.render.RenderBase;

class ParticleRenderBase<ParticlePreset> extends RenderBase
{
	var preset:ParticlePreset;

	public function new(preset:ParticlePreset)
	{
		this.preset = preset;
	}
}