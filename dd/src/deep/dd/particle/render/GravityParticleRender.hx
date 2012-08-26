package deep.dd.display.render;

import deep.dd.particle.utils.ParticlePreset;


class GPUGravityParticleRender extends ParticleRenderBase
{
	public function new()
	{
		
	}
}

class GravityParticlePreset extends ParticlePreset<Particle>
{
	public var startPosition:Bounds<Vector3D>;
	public var startRotation:Bounds<Vector3D>;
	
	public var speed:Bounds<Vector3D>;

	public var startScale:Bounds<Float>;
	public var endScale:Bounds<Float>;

	public var startColor:Bounds<Color>;
	public var endColor:Bounds<Color>;

	public var gravity:Vector3D;

	public function new()
	{

	}
}

class Particle
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

	public var startTime:Float;
	public var life:Float;

	public var new()
	{
		
	}
}