
package deep.dd.particle.render;

import deep.dd.particle.render.ParticleRenderBase;
import deep.dd.particle.preset.RadialParticlePreset;
import flash.geom.Matrix3D;
import deep.dd.display.smart.SmartSprite2D;
import deep.dd.display.Sprite2D;
import deep.dd.utils.FastHaxe;
import deep.dd.camera.Camera2D;
import deep.dd.display.render.RenderBase;
import deep.dd.geometry.CloudGeometry;
import deep.dd.geometry.Geometry;
import deep.dd.material.radialParticle2D.RadialParticle2DMaterial;
import deep.dd.particle.preset.ParticlePresetBase;
import deep.dd.particle.preset.ParticlePresetBase.Bounds;
import mt.m3d.Color;
import flash.geom.Vector3D;

class RadialParticleRenderBuilder
{
    static public function gpuRender(preset:RadialParticlePreset)
    {
        return new GPURadialParticleRender(preset);
    }

    static public function cpuCloudRender(preset:RadialParticlePreset, startSize:UInt = 20, incSize:UInt = 20)
    {
        return new RadialParticleRender(
            preset,
            new deep.dd.display.render.CloudRender(
                startSize,
                incSize,
                CloudGeometry.createTexturedCloud(startSize, deep.dd.display.render.CloudRender.PER_VERTEX, 1, 1, -0.5, -0.5)
            )
        );
    }

    static public function cpuBatchRender(preset:RadialParticlePreset)
    {
        return new RadialParticleRender(
            preset,
            new deep.dd.display.render.BatchRender(
                deep.dd.geometry.BatchGeometry.createTexturedBatch(deep.dd.display.render.BatchRender.MAX_SIZE, 1, 1, -0.5, -0.5)
            )
        );
    }
}

//------------------

class RadialParticleRender extends CPUParticleRenderBase
{
    public function new(preset:RadialParticlePreset, render:RenderBase)
    {
        particles = new flash.Vector<RadialParticle>();

        super(preset, render);
    }

    var radialPreset:RadialParticlePreset;

    var particles:flash.Vector<RadialParticle>;

    override function set_preset(p:ParticlePresetBase):ParticlePresetBase
    {
        #if debug
        if (!FastHaxe.is(p, RadialParticlePreset)) throw "preset must be RadialParticlePreset";
        #end

        radialPreset = flash.Lib.as(p, RadialParticlePreset);
        super.set_preset(radialPreset);

        particles.fixed = false;
        particles.length = radialPreset.particleNum;
        particles.fixed = true;

        return p;
    }

    var lastSpawn:Float = 0;

    override public function updateStep()
    {
        var time = smartSprite.scene.time;

        if (size < radialPreset.particleNum)
        {
            if (size == 0 || (time - lastSpawn) > radialPreset.spawnStep)
            {
                var spawn = Std.int(Math.min(radialPreset.particleNum - size, radialPreset.spawnNum));

                var texture = smartSprite.texture;

                for (i in 0...spawn)
                {
                    var idx = size + i;
                    var p:RadialParticle = radialPreset.createParticle();
                    p.startTime = time;
                    particles[idx] = p;

                    var s = sprites[idx];
                    if (s == null)
                    {
                        sprites[idx] = s = new CenteredSprite2D();
                        s.texture = texture;
                    }
                    smartSprite.addChild(s);
                    s.rotation = p.startRotation;
                }
                size += spawn;
                lastSpawn = time;
            }
        }

        for (i in 0...size)
        {
            var p:RadialParticle = particles[i];
            var s:Sprite2D = sprites[i];

            var k = (time - p.startTime) / p.life;
            k -= Std.int(k);
            var t = k * p.life;

            var a = p.angle + p.angleSpeed * t;
            var r = p.radius + p.dRadius * k;
            s.x = r * Math.cos(a);
            s.y = r * Math.sin(a);

            var scale = p.scale + p.dScale * k;
            s.scaleX = scale;
            s.scaleY = scale;

            var c = s.colorTransform;
            c.a = p.a + p.da * k;
            c.r = p.r + p.dr * k;
            c.g = p.g + p.dg * k;
            c.b = p.b + p.db * k;
            s.colorTransform = c;
        }

        render.updateStep();
    }

    override public function drawStep(camera:Camera2D):Void
    {
        render.drawStep(camera);
    }

    override public function copy():RenderBase
    {
        return new RadialParticleRender(radialPreset, render.copy());
    }

    override public function dispose(deep = true)
    {
        super.dispose(deep);

        radialPreset = null;
        particles = null;
    }
}

//---------------

class GPURadialParticleRender extends ParticleRenderBase
{
	inline static public var PER_VERTEX:UInt = 20;

	public function new(preset:RadialParticlePreset)
	{
        geometry = radialGeometry = CloudGeometry.createTexturedCloud(1, PER_VERTEX, 1, 1, -0.5, -0.5);

        super(radialPreset = preset);

		material = radialMaterial = new RadialParticle2DMaterial();

		var g = Geometry.createTextured(1, 1, 1, 1, -0.5, -0.5);
		poly = g.poly;
	}

	var poly:Poly2D;

	var radialGeometry:CloudGeometry;
	var radialMaterial:RadialParticle2DMaterial;
	var radialPreset:RadialParticlePreset;

	var size:UInt = 0;
	var lastSpawn:Float = 0;

    override function set_preset(p:ParticlePresetBase):ParticlePresetBase
    {
        #if debug
        if (!FastHaxe.is(p, RadialParticlePreset)) throw "preset must be RadialParticlePreset";
        #end

        radialPreset = flash.Lib.as(p, RadialParticlePreset);
        super.set_preset(radialPreset);
        size = 0;//size < p.particleNum ? size : p.particleNum;
        lastSpawn = 0;

        radialGeometry.resizeCloud(preset.particleNum);

        return p;
    }

	override public function drawStep(camera:Camera2D):Void
	{
		#if debug
		if (smartSprite.texture == null)
        {
            trace("GPURadialParticleRender reqired texture.");
        }
        #end


		if (size < radialPreset.particleNum)
		{
            var time = smartSprite.scene.time;
            if (size == 0 || (time - lastSpawn) > radialPreset.spawnStep)
            {
                var spawn = Std.int(Math.min(radialPreset.particleNum - size, radialPreset.spawnNum));

                for (i in 0...spawn)
                {
                    fillBuffer(time, size + i);
                }
                size += spawn;

                radialGeometry.uploadVBuf();
                lastSpawn = time;
            }
		}

		radialMaterial.drawParticleSystem(smartSprite, camera, size);

		for (i in smartSprite.children) if (i.visible) i.drawStep(camera);
	}

	inline function fillBuffer(time, pos:Int)
	{
		var p = radialPreset.createParticle();
		p.startTime = time;
        var m = new Matrix3D();
        m.appendRotation(p.startRotation, Vector3D.Z_AXIS);

		var buf = radialGeometry.rawVBuf;

		var i = pos * PER_VERTEX * 4;
		for (idx in 0...4)
		{
			var v = poly.points[idx].toVector();
            v = m.transformVector(v);
			buf[i++] = v.x;
			buf[i++] = v.y;

			var uv = poly.tcoords[idx];
			buf[i++] = uv.u;
			buf[i++] = uv.v;

			buf[i++] = p.scale;
			buf[i++] = p.dScale;

			buf[i++] = p.angle;
			buf[i++] = p.angleSpeed;
			buf[i++] = p.radius;
			buf[i++] = p.dRadius;

			buf[i++] = p.r;
			buf[i++] = p.g;
			buf[i++] = p.b;
			buf[i++] = p.a;

			buf[i++] = p.dr;
			buf[i++] = p.dg;
			buf[i++] = p.db;
			buf[i++] = p.da;

			buf[i++] = p.startTime;
			buf[i++] = p.life;
		}
	}

	override function copy():RenderBase
	{
		return new GPURadialParticleRender(radialPreset);
	}

    override public function dispose(deep = true)
    {
        super.dispose(deep);
        poly.dispose();
        poly = null;

        radialGeometry = null;
        radialMaterial = null;
        radialPreset = null;
    }
}