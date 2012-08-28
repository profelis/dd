
package deep.dd.particle.render;

import deep.dd.particle.render.ParticleRenderBase;
import deep.dd.material.gravityParticle2D.GravityParticle2DMaterial;
import deep.dd.particle.preset.GravityParticlePreset;
import flash.geom.Matrix3D;
import deep.dd.display.SmartSprite2D;
import deep.dd.display.Sprite2D;
import deep.dd.utils.FastHaxe;
import deep.dd.camera.Camera2D;
import deep.dd.display.render.RenderBase;
import deep.dd.geometry.CloudGeometry;
import deep.dd.geometry.Geometry;
import deep.dd.particle.preset.ParticlePresetBase;
import deep.dd.particle.preset.ParticlePresetBase.Bounds;
import mt.m3d.Color;
import flash.geom.Vector3D;

class GravityParticleRenderBuilder
{
    static public function gpuRender(preset:GravityParticlePreset)
    {
        return new GPUGravityParticleRender(preset);
    }

    static public function cpuCloudRender(preset:GravityParticlePreset)
    {
        return new GravityParticleRender(preset, new deep.dd.display.render.CloudRender());
    }

    static public function cpuBatchRender(preset:GravityParticlePreset)
    {
        return new GravityParticleRender(preset, new deep.dd.display.render.BatchRender());
    }
}

class GravityParticleRender extends CPUParticleRenderBase
{
    public function new(preset:GravityParticlePreset, render:RenderBase)
    {
        particles = new flash.Vector<Particle>();

        super(preset, render);
    }

    var gravityPreset:GravityParticlePreset;

    var particles:flash.Vector<Particle>;

    override function set_preset(p:ParticlePresetBase):ParticlePresetBase
    {
        #if debug
        if (!FastHaxe.is(p, GravityParticlePreset)) throw "preset must be GravityParticlePreset";
        #end

        gravityPreset = flash.Lib.as(p, GravityParticlePreset);
        super.set_preset(gravityPreset);

        particles.fixed = false;
        particles.length = gravityPreset.particleNum;
        particles.fixed = true;

        return p;
    }

    var lastSpawn:Float = 0;

    override public function drawStep(camera:Camera2D, invalidateTexture:Bool):Void
    {
        var time = smartSprite.scene.time;

        if (size < gravityPreset.particleNum)
        {
            if (size == 0 || (time - lastSpawn) > gravityPreset.spawnStep)
            {
                var spawn = Std.int(Math.min(gravityPreset.particleNum - size, gravityPreset.spawnNum));

                for (i in 0...spawn)
                {
                    var idx = size + i;
                    var p:Particle = gravityPreset.createParticle();
                    p.startTime = time;
                    particles[idx] = p;

                    var s = sprites[idx];
                    if (s == null) sprites[idx] = s = new Sprite2D();
                    smartSprite.addChild(s);
                    s.rotationX = p.startRotation.x;
                    s.rotationY = p.startRotation.y;
                    s.rotationZ = p.startRotation.z;
                }
                size += spawn;
                lastSpawn = time;
            }
        }

        var gravity = gravityPreset.gravity;
        for (i in 0...size)
        {
            var p:Particle = particles[i];
            var s:Sprite2D = sprites[i];

            var k = (time - p.startTime) / p.life;
            k -= Std.int(k);
            var t = k * p.life;

            s.x = p.x + (p.vx + (gravity.x * t)) * t;
            s.y = p.y + (p.vy + (gravity.y * t)) * t;
            s.z = p.z + (p.vz + (gravity.z * t)) * t;

            var scale = p.scale + p.dScale * k;
            s.scaleX = scale;
            s.scaleY = scale;
            s.scaleZ = scale;

            var c = s.colorTransform;
            c.a = p.a + p.da * k;
            c.r = p.r + p.dr * k;
            c.g = p.g + p.dg * k;
            c.b = p.b + p.db * k;
            s.colorTransform = c;
        }

        render.drawStep(camera, invalidateTexture);
    }

    override public function copy():RenderBase
    {
        return new GravityParticleRender(gravityPreset, render.copy());
    }

    override public function dispose(deep = true)
    {
        super.dispose(deep);

        gravityPreset = null;
        particles = null;
    }
}

//---------------

class GPUGravityParticleRender extends ParticleRenderBase
{
	inline static public var PER_VERTEX:UInt = 23;

	public function new(preset:GravityParticlePreset)
	{
        geometry = gravityGeometry = CloudGeometry.createTexturedCloud(1, PER_VERTEX, 1, 1, -0.5, -0.5);

        super(gravityPreset = preset);

		material = gravityMaterial = new GravityParticle2DMaterial();

		var g = Geometry.createTextured(1, 1, 1, 1, -0.5, -0.5);
		poly = g.poly;
	}

	var poly:Poly2D;

	var gravityGeometry:CloudGeometry;
	var gravityMaterial:GravityParticle2DMaterial;
	var gravityPreset:GravityParticlePreset;

	var size:UInt = 0;
	var lastSpawn:Float = 0;

    override function set_preset(p:ParticlePresetBase):ParticlePresetBase
    {
        #if debug
        if (!FastHaxe.is(p, GravityParticlePreset)) throw "preset must be GravityParticlePreset";
        #end

        gravityPreset = flash.Lib.as(p, GravityParticlePreset);
        super.set_preset(gravityPreset);
        size = 0;
        lastSpawn = 0;

        gravityGeometry.resizeCloud(preset.particleNum);

        return p;
    }

	override public function drawStep(camera:Camera2D, invalidateTexture:Bool):Void
	{
		#if debug
		if (smartSprite.texture == null)
        {
            trace("GPUGravityParticleRender reqired texture.");
        }
        #end


		if (size < gravityPreset.particleNum)
		{
            var time = smartSprite.scene.time;
            if (size == 0 || (time - lastSpawn) > gravityPreset.spawnStep)
            {
                var spawn = Std.int(Math.min(gravityPreset.particleNum - size, gravityPreset.spawnNum));

                for (i in 0...spawn)
                {
                    fillBuffer(time, size + i);
                }
                size += spawn;

                gravityGeometry.uploadVBuf();
                lastSpawn = time;
            }
		}

		gravityMaterial.drawParticleSystem(smartSprite, camera, size, gravityPreset.gravity);

		for (i in smartSprite.children) if (i.visible) i.drawStep(camera);
	}

	inline function fillBuffer(time, pos:Int)
	{
		var p = gravityPreset.createParticle();
		p.startTime = time;
        var m = new Matrix3D();
        m.appendRotation(p.startRotation.z, Vector3D.Z_AXIS);
        m.appendRotation(p.startRotation.y, Vector3D.Y_AXIS);
        m.appendRotation(p.startRotation.x, Vector3D.X_AXIS);

		var buf = gravityGeometry.rawVBuf;

		var i = pos * PER_VERTEX * 4;
		for (idx in 0...4)
		{
			var v = poly.points[idx].toVector();
            v = m.transformVector(v);
			buf[i++] = v.x;
			buf[i++] = v.y;
			buf[i++] = v.z;

			var uv = poly.tcoords[idx];
			buf[i++] = uv.u;
			buf[i++] = uv.v;

			buf[i++] = p.x;
			buf[i++] = p.y;
			buf[i++] = p.z;

			buf[i++] = p.vx;
			buf[i++] = p.vy;
			buf[i++] = p.vz;

			buf[i++] = p.r;
			buf[i++] = p.g;
			buf[i++] = p.b;
			buf[i++] = p.a;

			buf[i++] = p.dr;
			buf[i++] = p.dg;
			buf[i++] = p.db;
			buf[i++] = p.da;

			buf[i++] = p.scale;
			buf[i++] = p.dScale;

			buf[i++] = p.startTime;
			buf[i++] = p.life;
		}
	}

	override function copy():RenderBase
	{
		return new GPUGravityParticleRender(gravityPreset);
	}

    override public function dispose(deep = true)
    {
        super.dispose(deep);
        poly.dispose();
        poly = null;

        gravityGeometry = null;
        gravityMaterial = null;
        gravityPreset = null;
    }
}