package deep.dd.particle.utils;

import flash.geom.Vector3D;
import haxe.rtti.Generic;

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

class ParticlePresetBase implements Generic
{
	public var count:Bounds<UInt>;

	public var life:Bounds<Float>;

    public var spawnNum:UInt;
}
