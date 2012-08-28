package deep.dd.particle.preset;

import flash.geom.Matrix3D;
import mt.m3d.Color;
import flash.geom.Vector3D;
import deep.dd.particle.preset.ParticlePresetBase;
import deep.dd.particle.preset.ParticlePresetBase.Bounds;

class RadialParticlePreset extends ParticlePresetBase
{
    public var startRotation:Bounds<Vector3D>;

    public var startScale:Bounds<Float>;
    public var endScale:Bounds<Float>;

    public var startColor:Bounds<Color>;
    public var endColor:Bounds<Color>;

    public var startRadius:Bounds<Float>;
    public var endRadius:Bounds<Float>;

    public var startAngle:Bounds<Float>;
    public var angleSpeed:Bounds<Float>;

    public var startDepth:Bounds<Float>;
    public var depthSpeed:Bounds<Float>;


    public function new() {}

    inline public function createParticle():Particle
    {
        var res:Particle = new Particle();

        res.life = BoundsTools.randomFloat(life);

        res.z = BoundsTools.randomFloat(startDepth);
        res.vz = BoundsTools.randomFloat(depthSpeed);

        res.angle = BoundsTools.randomFloat(startAngle);
        res.angleSpeed = BoundsTools.randomFloat(angleSpeed);

        res.radius = BoundsTools.randomFloat(startRadius);
        res.dRadius = BoundsTools.randomFloat(endRadius) - res.radius;
        trace(res.dRadius);

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

        res.startRotation = BoundsTools.randomVector(startRotation);

        return res;
    }
}

class Particle extends ParticleBase
{
    public var z:Float;
    public var vz:Float;

    public var angle:Float;
    public var angleSpeed:Float;

    public var radius:Float;
    public var dRadius:Float;

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

    public var startRotation:Vector3D;

    public function new() {}
}