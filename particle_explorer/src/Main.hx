package;
import com.bit101.components.HSlider;
import com.bit101.components.HUISlider;
import com.bit101.components.Label;
import com.bit101.components.Panel;
import com.bit101.components.Style;
import com.bit101.components.VRangeSlider;
import com.bit101.components.VSlider;
import com.bit101.components.Window;
import deep.dd.display.Scene2D;
import deep.dd.particle.render.ParticleRenderBase;
import deep.dd.utils.Stats;
import deep.dd.World2D;
import deep.dd.particle.ParticleSystem2D;
import deep.dd.particle.preset.GravityParticlePreset;
import deep.dd.particle.render.GravityParticleRender;
import deep.dd.particle.ParticleSystem2D;
import deep.dd.particle.render.GravityParticleRender.GPUGravityParticleRender;
import deep.dd.particle.render.GravityParticleRender;
import deep.dd.particle.preset.ParticlePresetBase;
import deep.dd.particle.preset.ParticlePresetBase.Bounds;
import deep.dd.utils.BlendMode;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.StageScaleMode;
import flash.display.StageAlign;
import flash.display3D.Context3DRenderMode;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import mt.m3d.Color;

@:bitmap("deep.png") class Image extends BitmapData {}

class Main
{
	
	var world:World2D;
    var scene:Scene2D;

    var gravityPreset:GravityParticlePreset;
    var ps:ParticleSystem2D;
	var xPositionMin:HUISlider;
	var xPositionMax:HUISlider;
	var yPositionMin:HUISlider;
	var yPositionMax:HUISlider;
	var zPositionMin:HUISlider;
	var zPositionMax:HUISlider;
	private var window:Window;
	
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
		
		gravityPreset = new GravityParticlePreset();
        gravityPreset.particleNum = 15000;
        gravityPreset.spawnNum = 100;
        gravityPreset.spawnStep = 0.03;
        gravityPreset.life = new Bounds<Float>(2, 3);
        gravityPreset.startPosition = new Bounds<Vector3D>(new Vector3D(500, 500, 500), new Vector3D(500, 500, 500));
        gravityPreset.velocity = new Bounds<Vector3D>(new Vector3D(30, 0, 0), new Vector3D(40, 10, 0));
        gravityPreset.startColor = new Bounds<Color>(new Color(1, 1, 1, 0.6));
        gravityPreset.endColor = new Bounds<Color>(new Color(0, 0, 0, 0.01), new Color(1, 1, 1, 0.01));
        gravityPreset.gravity = new Vector3D(0, 100, 0);
        gravityPreset.startScale = new Bounds<Float>(0.5);
        gravityPreset.endScale = new Bounds<Float>(0.05);
        gravityPreset.startRotation = new Bounds<Vector3D>(new Vector3D(0, 0, 0), new Vector3D(0, 0, 360));

		ps = new ParticleSystem2D(GravityParticleRenderBuilder.gpuRender(gravityPreset));
        ps.x = 50;
        ps.y = 50;
        ps.blendMode = BlendMode.ADD_A;
        ps.texture = texture;
        scene.addChild(ps);
		
		Style.embedFonts = false;
        Style.fontSize = 10;
		Style.fontName = "arial";
        Style.setStyle(Style.LIGHT);
		
		window = new Window(s);
		window.setSize(230, 200);
		window.draggable = false;
		window.hasMinimizeButton = true;
		
		var startPositionLabel:Label = new Label(window, 0, 4, "Start Position");
		startPositionLabel.x = (window.width - startPositionLabel.width) * 0.5;
		
		var label:Label = new Label(window, 5, 20, "Min X");
		xPositionMin = new HUISlider(window, 35, 20, onMinXChange);
		xPositionMin.setSliderParams(0, 1000, 500);
		
		label = new Label(window, 5, 35, "Max X");
		xPositionMax = new HUISlider(window, 35, 35, onMaxXChange);
		xPositionMax.setSliderParams(0, 1000, 500);
		
		label = new Label(window, 5, 50, "Min Y");
		yPositionMin = new HUISlider(window, 35, 50, onMinYChange);
		yPositionMin.setSliderParams(0, 1000, 500);
		
		label = new Label(window, 5, 65, "Max Y");
		yPositionMax = new HUISlider(window, 35, 65, onMaxYChange);
		yPositionMax.setSliderParams(0, 1000, 500);
		
		label = new Label(window, 5, 80, "Min Z");
		zPositionMin = new HUISlider(window, 35, 80, onMinZChange);
		zPositionMin.setSliderParams(0, 1000, 500);
		
		label = new Label(window, 5, 95, "Max Z");
		zPositionMax = new HUISlider(window, 35, 95, onMaxZChange);
		zPositionMax.setSliderParams(0, 1000, 500);
		
		var startVelocityLabel:Label = new Label(window, 0, 115, "Start Velocity");
		startVelocityLabel.x = (window.width - startVelocityLabel.width) * 0.5;
		
		
    }
	
	function onMinXChange(param1:Dynamic)
	{
		gravityPreset.startPosition.min.x = xPositionMin.value;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onMaxXChange(param1:Dynamic)
	{
		gravityPreset.startPosition.max.x = xPositionMax.value;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onMinYChange(param1:Dynamic)
	{
		gravityPreset.startPosition.min.y = yPositionMin.value;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onMaxYChange(param1:Dynamic)
	{
		gravityPreset.startPosition.max.y = yPositionMax.value;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onMinZChange(param1:Dynamic)
	{
		gravityPreset.startPosition.min.z = zPositionMin.value;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onMaxZChange(param1:Dynamic)
	{
		gravityPreset.startPosition.max.z = zPositionMax.value;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}

    static function main()
    {
        new Main();
    }
}