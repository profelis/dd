package ;

import deep.dd.display.render.BatchRender;
import deep.dd.particle.render.GravityParticleRender;
import deep.dd.display.render.SimpleRender;
import deep.dd.display.render.CloudRender;
import deep.dd.display.SmartSprite2D;
import deep.dd.particle.ParticleSystem2D;
import deep.dd.particle.render.GravityParticleRender.GPUGravityParticleRender;
import deep.dd.particle.render.GravityParticleRender.GravityParticlePreset;
import deep.dd.particle.render.GravityParticleRender;
import deep.dd.particle.utils.ParticlePresetBase;
import deep.dd.particle.utils.ParticlePresetBase.Bounds;
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
        preset.particleNum = 1000;
        preset.spawnNum = 1;
        preset.spawnStep = 0.03;
        preset.life = new Bounds<Float>(2, 3);
        preset.startPosition = new Bounds<Vector3D>(new Vector3D(0, 0, 0), new Vector3D(400, 0, 0));
        preset.velocity = new Bounds<Vector3D>(new Vector3D(30, 0, 0), new Vector3D(40, 10, 0));
        preset.startColor = new Bounds<Color>(new Color(1, 1, 1, 0.6));
        preset.endColor = new Bounds<Color>(new Color(0, 0, 0, 0.01), new Color(1, 1, 1, 0.01));
        preset.gravity = new Vector3D(0, 100, 0);
        preset.startScale = new Bounds<Float>(0.5);
        preset.endScale = new Bounds<Float>(0.05);
        preset.startRotation = new Bounds<Vector3D>(new Vector3D(0, 0, 45));


        //var ps = new ParticleSystem2D(new GravityParticleRender(preset, new CloudRender()));
        ps = new ParticleSystem2D(new GPUGravityParticleRender(preset));
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
        ps.render = new GravityParticleRender(preset, new CloudRender());
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