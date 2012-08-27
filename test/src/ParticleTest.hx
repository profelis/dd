package ;

import deep.dd.display.Sprite2D;
import mt.m3d.Color;
import flash.geom.Vector3D;
import flash.display.BitmapData;
import deep.dd.particle.ParticleSystem2D;
import deep.dd.particle.preset.GravityParticlePreset;
import deep.dd.particle.render.GravityParticleRender;
import deep.dd.particle.ParticleSystem2D;
import deep.dd.particle.render.GravityParticleRender.GPUGravityParticleRender;
import deep.dd.particle.render.GravityParticleRender;
import deep.dd.particle.preset.ParticlePresetBase;
import deep.dd.particle.preset.ParticlePresetBase.Bounds;
import deep.dd.utils.BlendMode;
import deep.dd.utils.Stats;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import deep.dd.display.Scene2D;
import flash.display3D.Context3DRenderMode;
import deep.dd.World2D;
import flash.events.Event;
import flash.events.MouseEvent;

@:bitmap("deep.png") class Image extends BitmapData {}

class ParticleTest
{

    var world:World2D;
    var scene:Scene2D;

    var preset:GravityParticlePreset;
    var ps:ParticleSystem2D;

    public function new()
    {
        var s = flash.Lib.current.stage;
        s.scaleMode = StageScaleMode.NO_SCALE;
        s.align = StageAlign.TOP_LEFT;

        world = new World2D(Context3DRenderMode.AUTO);

        s.addChild(new Stats(world));

        world.scene = scene = new Scene2D();

		world.antialiasing = 2;
        world.bgColor.fromInt(0x333333);

        var texture = world.cache.getTexture(Image);

        preset = new GravityParticlePreset();
        preset.particleNum = 15000;
        preset.spawnNum = 100;
        preset.spawnStep = 0.03;
        preset.life = new Bounds<Float>(2, 3);
        preset.startPosition = new Bounds<Vector3D>(new Vector3D(0, 0, 0), new Vector3D(600, 0, 0));
        preset.velocity = new Bounds<Vector3D>(new Vector3D(30, 0, 0), new Vector3D(40, 10, 0));
        preset.startColor = new Bounds<Color>(new Color(1, 1, 1, 0.6));
        preset.endColor = new Bounds<Color>(new Color(0, 0, 0, 0.01), new Color(1, 1, 1, 0.01));
        preset.gravity = new Vector3D(0, 100, 0);
        preset.startScale = new Bounds<Float>(0.5);
        preset.endScale = new Bounds<Float>(0.05);
        preset.startRotation = new Bounds<Vector3D>(new Vector3D(0, 0, 0), new Vector3D(0, 0, 360));


        //var ps = new ParticleSystem2D(new GravityParticleRender(preset, new CloudRender()));
        ps = new ParticleSystem2D(GravityParticleRenderBuilder.gpuRender(preset));
        ps.x = 50;
        ps.y = 50;
        ps.blendMode = BlendMode.ADD_A;
        ps.texture = texture;
        scene.addChild(ps);


        var q = new Sprite2D();
        q.texture = texture;
        q.scaleX = q.scaleY = 0.4;
        //ps.addChild(q);

        s.addEventListener(Event.ENTER_FRAME, onRender);

        s.addEventListener(MouseEvent.CLICK, onClick);
    }

    function onClick(_)
    {
        ps.render.dispose();
        ps.render = GravityParticleRenderBuilder.cpuCloudRender(preset);
        //world.ctx.dispose();
		//mc.animator.playAnimation(null);
    }

    function onRender(_)
    {

        //world.camera.x = -world.stage.mouseX;
        //world.camera.y = -world.stage.mouseY;
    //    world.camera.scale += (Math.random()-0.5) * 0.003;
        //sp2.rotationY += 0.05;
    }


    static function main()
    {
        new ParticleTest();
    }
}