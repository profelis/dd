package ;

import deep.dd.particle.render.RadialParticleRender;
import deep.dd.particle.preset.ParticlePresetBase;
import deep.dd.particle.preset.ParticlePresetBase.Bounds;
import deep.dd.particle.preset.RadialParticlePreset;
import deep.dd.particle.ParticleSystem2D;
import deep.dd.display.SmartSprite2D;
import deep.dd.utils.Stats;
import deep.dd.animation.Animator;
import flash.geom.Vector3D;
import deep.dd.texture.atlas.parser.SpriteSheetParser;
import deep.dd.texture.atlas.parser.StarlingParser;
import deep.dd.texture.atlas.AtlasTexture2D;
import deep.dd.display.MovieClip2D;
import deep.dd.display.Quad2D;
import deep.dd.utils.GlobalStatistics;
import mt.m3d.Color;
import deep.dd.utils.BlendMode;
import deep.dd.display.Sprite2D;
import flash.utils.ByteArray;
import deep.dd.texture.Texture2D;
import flash.display.BitmapData;
import flash.events.MouseEvent;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import deep.dd.display.Scene2D;
import flash.display3D.Context3DRenderMode;
import deep.dd.World2D;
import flash.events.Event;

@:bitmap("deep.png") class Image extends BitmapData {}

class RadialParticleTest
{

    var world:World2D;
    var scene:Scene2D;

    var preset:RadialParticlePreset;
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

        preset = new RadialParticlePreset();
        preset.particleNum = 1000;
        preset.spawnNum = 25;
        preset.spawnStep = 0.05;
        preset.life = new Bounds<Float>(2, 3);
        preset.startColor = new Bounds<Color>(new Color(1, 1, 1, 0.6));
        preset.endColor = new Bounds<Color>(new Color(0, 0, 0, 0.01), new Color(1, 1, 1, 0.01));
        preset.startScale = new Bounds<Float>(0.25);
        preset.endScale = new Bounds<Float>(0.25);
        preset.startRotation = new Bounds<Vector3D>(new Vector3D(0, 0, 0));

        preset.startRadius = new Bounds<Float>(0);
        preset.endRadius = new Bounds<Float>(300);

        preset.startDepth = new Bounds<Float>(-1000);
        preset.depthSpeed = new Bounds<Float>(500);

        preset.startAngle = new Bounds<Float>(0, 360);
        preset.angleSpeed = new Bounds<Float>(-5);


        ps = new ParticleSystem2D(RadialParticleRenderBuilder.gpuRender(preset));
        ps.x = 400;
        ps.y = 300;
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
        ps.render = RadialParticleRenderBuilder.cpuCloudRender(preset);
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
        new RadialParticleTest();
    }
}