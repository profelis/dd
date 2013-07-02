package deep.dd.display.particle.preset;

import flash.geom.Vector3D;
import haxe.rtti.Generic;
import mt.m3d.Color;

class ParticlePresetBase
{
	public var particleNum:UInt;
    public var spawnNum:UInt;
    public var spawnStep:Float;

	public var life:Bounds<Float>;
}

class ParticleBase
{
	public var life:Float;

	public var startTime:Float;
}


class Bounds<T>
{
	public var min:T;
	public var max:T;

	public function new(min:T, max:Null<T> = null)
	{
		this.min = min;
		this.max = max == null ? min : max;
	}
}

class BoundsTools
{
	inline static public function randomFloat(b:Bounds<Float>):Float
	{
		return b.min + Math.random() * (b.max - b.min);
	}

	inline static public function randomVector(b:Bounds<Vector3D>):Vector3D
	{
		var r = b.min.clone();
		var max = b.max;
		if (!r.equals(max))
		{
			r.x += Math.random() * (max.x - r.x);
			r.y += Math.random() * (max.y - r.y);
			r.z += Math.random() * (max.z - r.z);
			r.w += Math.random() * (max.w - r.w);
		}
		return r;
	}

	inline static public function randomColor(b:Bounds<Color>):Color
	{
		var c = b.min.copy();
		var max = b.max;
		if (!c.equals(max))
		{
			c.r = c.r + Math.random() * (max.r - c.r);
			c.g = c.g + Math.random() * (max.g - c.g);
			c.b = c.b + Math.random() * (max.b - c.b);
			c.a = c.a + Math.random() * (max.a - c.a);
		}
		return c;
	}
}