package deep.dd.particle.preset;

import flash.geom.Point;
import mt.m3d.Color;
import flash.geom.Vector3D;
import deep.dd.particle.preset.ParticlePresetBase;
import deep.dd.particle.preset.ParticlePresetBase.Bounds;

class GravityParticlePreset extends ParticlePresetBase
{
    public var startPosition:Bounds<Vector3D>;
    public var startRotation:Bounds<Float>;

    public var velocity:Bounds<Vector3D>;

    public var startScale:Bounds<Float>;
    public var endScale:Bounds<Float>;

    public var startColor:Bounds<Color>;
    public var endColor:Bounds<Color>;

    public var gravity:Point;

    public function new() {}

    inline public function createParticle():GravityParticle
    {
        var res:GravityParticle = new GravityParticle();

        res.life = BoundsTools.randomFloat(life);

        var p = BoundsTools.randomVector(startPosition);
        res.x = p.x;
        res.y = p.y;

        p = BoundsTools.randomVector(velocity);
        res.vx = p.x;
        res.vy = p.y;

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

        res.startRotation = BoundsTools.randomFloat(startRotation);

        return res;
    }
}

class GravityParticle extends ParticleBase
{
    public var x:Float;
    public var y:Float;

    public var vx:Float;
    public var vy:Float;

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

    public var startRotation:Float;

    public function new() {}
}