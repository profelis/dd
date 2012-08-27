
package deep.dd.particle.render;

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

	function fillBuffer(time, pos:Int)
	{
		var p:Particle = flash.Lib.as(gravityPreset.createParticle(), Particle);
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

	public function new()
	{
	}

	override public function createParticle():Particle
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

	public function new()
	{
	}
}