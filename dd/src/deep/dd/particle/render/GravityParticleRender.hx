
package deep.dd.particle.render;

import deep.dd.display.SmartSprite2D;
import deep.dd.display.Sprite2D;
import deep.dd.utils.FastHaxe;
import deep.dd.camera.Camera2D;
import deep.dd.display.render.RenderBase;
import deep.dd.geometry.CloudGeometry;
import deep.dd.geometry.Geometry;
import deep.dd.material.gravityParticle2D.GravityParticle2DMaterial;
import deep.dd.particle.utils.ParticlePresetBase;
import deep.dd.particle.utils.ParticlePresetBase.Bounds;
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

class GravityParticleRender extends ParticleRenderBase
{
    public function new(preset:GravityParticlePreset, render:RenderBase)
    {
        #if debug
        if (FastHaxe.is(render, ParticleRenderBase)) throw "render must be simple render (CloudRender, BatchRender)";
        if (render.smartSprite != null) throw "render in use";
        #end

        this.render = render;

        geometry = render.geometry;
        material = render.material;
        ignoreInBatch = render.ignoreInBatch;

        sprites = new flash.Vector<Sprite2D>();
        particles = new flash.Vector<Particle>();

        super(preset);
    }

    var gravityPreset:GravityParticlePreset;

    var render:RenderBase;

    var particles:flash.Vector<Particle>;
    var sprites:flash.Vector<Sprite2D>;

    override function set_preset(p:ParticlePresetBase):ParticlePresetBase
    {
        #if debug
        if (!FastHaxe.is(p, GravityParticlePreset)) throw "preset must be GravityParticlePreset";
        #end

        gravityPreset = flash.Lib.as(p, GravityParticlePreset);
        super.set_preset(p);

        size = 0;

        particles.fixed = false;
        sprites.fixed = false;

        particles.length = gravityPreset.particleNum;
        sprites.length = gravityPreset.particleNum;

        particles.fixed = true;
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

    var size:UInt = 0;
    var lastSpawn:Float = 0;

    override public function drawStep(camera:Camera2D, invalidateTexture:Bool):Void
    {
        var time = smartSprite.scene.time;

        if (size < gravityPreset.particleNum)
        {
            if (size == 0 || (time - lastSpawn) > gravityPreset.spawnStep)
            {
                var spawn:Int = Std.int(Math.min(gravityPreset.particleNum - size, gravityPreset.spawnNum));

                for (i in 0...spawn)
                {
                    var idx = size + i;
                    var p:Particle = gravityPreset.createParticle();
                    p.startTime = time;
                    particles[idx] = p;

                    if (sprites[idx] == null) sprites[idx] = new Sprite2D();
                    smartSprite.addChild(sprites[idx]);
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

        render.dispose(false);
        render = null;

        gravityPreset = null;

        particles = null;
        for (s in sprites) s.dispose();
        sprites = null;
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
        super.set_preset(p);
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
                var spawn:Int = Std.int(Math.min(gravityPreset.particleNum - size, gravityPreset.spawnNum));

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
		var p:Particle = gravityPreset.createParticle();
		p.startTime = time;

		var buf = gravityGeometry.rawVBuf;

		var i = pos * PER_VERTEX * 4;
		for (idx in 0...4)
		{
			var v = poly.points[idx];
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

class GravityParticlePreset extends ParticlePresetBase
{
	public var startPosition:Bounds<Vector3D>;

	public var velocity:Bounds<Vector3D>;

	public var startScale:Bounds<Float>;
	public var endScale:Bounds<Float>;

	public var startColor:Bounds<Color>;
	public var endColor:Bounds<Color>;

	public var gravity:Vector3D;

	public function new() {}

	inline public function createParticle():Particle
	{
		var res:Particle = new Particle();

		res.life = BoundsTools.randomFloat(life);

		var p = BoundsTools.randomVector(startPosition);
		res.x = p.x;
		res.y = p.y;
		res.z = p.z;

		p = BoundsTools.randomVector(velocity);
		res.vx = p.x;
		res.vy = p.y;
		res.vz = p.z;

		res.scale = BoundsTools.randomFloat(startScale);
		res.dScale = BoundsTools.randomFloat(endScale) - res.scale;

		var c = BoundsTools.randomColor(startColor);
		res.r = c.r;
		res.g = c.g;
		res.b = c.b;
		res.a = c.a;

		var dc = BoundsTools.randomColor(endColor);
		res.dr = dc.r - c.r;
		res.dg = dc.g - c.g;
		res.db = dc.b - c.b;
		res.da = dc.a - c.a;

		return res;
	}
}

class Particle extends ParticleBase
{
	public var x:Float;
	public var y:Float;
	public var z:Float;

	public var vx:Float;
	public var vy:Float;
	public var vz:Float;

	public var r:Float;
	public var g:Float;
	public var b:Float;
	public var a:Float;

	public var dr:Float;
	public var dg:Float;
	public var db:Float;
	public var da:Float;

	public var scale:Float;
	public var dScale:Float;

	public function new() {}
}