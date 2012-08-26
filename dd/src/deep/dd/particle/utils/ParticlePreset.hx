package deep.dd.particle.utils;

import flash.geom.Vector3D;
import haxe.rtti.Generic;
import mt.m3d.Color;

class Bounds<T> implements Generic
{
	public var min:T;
	public var max:T;

	public function new(min:T, max:T = null)
	{
		this.min = min;
		this.max = max == null ? min : max;
	}
}

class ParticlePresetBase<T> implements Generic
{
	public var count:Bounds<UInt>;

	public var life:Bounds<Float>;

	public var startPosition:Bounds<Vector3D>;
}
