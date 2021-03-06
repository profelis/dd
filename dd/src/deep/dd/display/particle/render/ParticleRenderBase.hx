package deep.dd.display.particle.render;

import deep.dd.display.smart.SmartSprite2D;
import deep.dd.display.Sprite2D;
import deep.dd.display.smart.render.RenderBase;
import deep.dd.display.particle.preset.ParticlePresetBase;

class CPUParticleRenderBase extends ParticleRenderBase
{
    function new(preset:ParticlePresetBase, render:RenderBase)
    {
        #if debug
        if (deep.dd.utils.FastHaxe.is(render, ParticleRenderBase)) throw "render must be simple render (CloudRender, BatchRender)";
        if (render.smartSprite != null) throw "render in use";
        #end

        sprites = new flash.Vector<Sprite2D>();

        super(preset);

        this.render = render;

        geometry = render.geometry;
        material = render.material;
        ignoreInBatch = render.ignoreInBatch;
    }

    var render:RenderBase;

    var sprites:flash.Vector<Sprite2D>;

    var size:UInt = 0;

    override function set_preset(p:ParticlePresetBase):ParticlePresetBase
    {
        super.set_preset(p);

        /*
        if (size > p.particleNum)
        {
            if (smartSprite != null)
            {

                for (i in p.particleNum...size)
                {
                    var s = sprites[i];
                    if (smartSprite.contains(s)) smartSprite.removeChild(s);
                }
            }
            size = p.particleNum;
        }
         */
        size = 0;

        sprites.fixed = false;
        sprites.length = p.particleNum;
        sprites.fixed = true;

        if (smartSprite != null)
        {
            for (s in sprites)
                if (smartSprite.contains(s)) smartSprite.removeChild(s);
        }

        return p;
    }

    override function set_smartSprite(v:SmartSprite2D):SmartSprite2D
    {
        if (smartSprite != null)
        {
            for (s in sprites)
                if (smartSprite.contains(s)) smartSprite.removeChild(s);
        }

        render.smartSprite = v;

        for (i in 0...size) v.addChild(sprites[i]);

        return super.set_smartSprite(v);
    }

    override public function dispose(deep = true)
    {
        super.dispose(deep);

        render.dispose(false);
        render = null;

        for (s in sprites) if (s != null) s.dispose();
        sprites = null;
    }

}

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

    override public function updateStep()
    {
        smartSprite.nativeUpdateStep();
    }

    function new(preset:ParticlePresetBase)
	{
		this.preset = preset;
        ignoreInBatch = true;
	}

    override public function dispose(deep = true)
    {
        super.dispose();
        Reflect.setField(this, "preset", null);
    }

}