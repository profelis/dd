package;
import com.bit101.components.ComboBox;
import com.bit101.components.HRangeSlider;
import com.bit101.components.HSlider;
import com.bit101.components.HUISlider;
import com.bit101.components.Label;
import com.bit101.components.ListItem;
import com.bit101.components.Panel;
import com.bit101.components.PushButton;
import com.bit101.components.RadioButton;
import com.bit101.components.ScrollPane;
import com.bit101.components.Style;
import com.bit101.components.VRangeSlider;
import com.bit101.components.VSlider;
import com.bit101.components.Window;
import deep.dd.display.Scene2D;
import deep.dd.particle.render.ParticleRenderBase;
import deep.dd.texture.Texture2D;
import deep.dd.utils.Stats;
import deep.dd.World2D;
import deep.dd.particle.ParticleSystem2D;
import deep.dd.particle.preset.GravityParticlePreset;
import deep.dd.particle.render.GravityParticleRender;
import deep.dd.particle.ParticleSystem2D;
import deep.dd.particle.render.GravityParticleRender.GPUGravityParticleRender;
import deep.dd.particle.preset.ParticlePresetBase;
import deep.dd.particle.preset.ParticlePresetBase.Bounds;
import deep.dd.utils.BlendMode;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.StageScaleMode;
import flash.display.StageAlign;
import flash.display3D.Context3DRenderMode;
import flash.display3D.Context3DBlendFactor;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import mt.m3d.Color;

@:bitmap("deep.png") class Image extends BitmapData {}
@:bitmap("circle.png") class Circle extends BitmapData {}

class Main
{
	
	var world:World2D;
    var scene:Scene2D;

    var gravityPreset:GravityParticlePreset;
    var ps:ParticleSystem2D;
	
	// Particles Configuration
	var particleWindow:Window;
	
	var numParticles:HUISlider;
	var spawnNum:HUISlider;
	var spawnStep:HUISlider;
	var life:HRangeSlider;
	
	var startScale:HRangeSlider;
	var endScale:HRangeSlider;
	
	var angleX:HRangeSlider;
	var angleY:HRangeSlider;
	var angleZ:HRangeSlider;
	
	// Particles Color
	var colorWindow:Window;
	
	var startColorMin:Color;
	var startColorMax:Color;
	var endColorMin:Color;
	var endColorMax:Color;
	
	var startR:HRangeSlider;
	var startG:HRangeSlider;
	var startB:HRangeSlider;
	var startA:HRangeSlider;
	
	var endR:HRangeSlider;
	var endG:HRangeSlider;
	var endB:HRangeSlider;
	var endA:HRangeSlider;
	
	// Gravity system's parameters controls
	var gravityWindow:Window;
	
	var xPosition:HRangeSlider;
	var yPosition:HRangeSlider;
	var zPosition:HRangeSlider;
	
	var xVelocity:HRangeSlider;
	var yVelocity:HRangeSlider;
	var zVelocity:HRangeSlider;
	
	var xGravity:HUISlider;
	var yGravity:HUISlider;
	var zGravity:HUISlider;
	
	// Other settings
	var otherSettingsWindow:Window;
	var bgRed:HUISlider;
	var bgGreen:HUISlider;
	var bgBlue:HUISlider;
	
	var blendSource:ComboBox;
	var blendDestination:ComboBox;
	var blendMode:BlendMode;
	
	var load:PushButton;
	var save:PushButton;
	
	var textureEditor:TextureEditor;
	var textureBmd:BitmapData;
	private var texture:Texture2D;
	
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
		
		textureBmd = Type.createInstance(Circle, [0, 0]);
		texture = world.cache.getBitmapTexture(textureBmd);
		
		gravityPreset = new GravityParticlePreset();
        gravityPreset.particleNum = 1000;
        gravityPreset.spawnNum = 100;
        gravityPreset.spawnStep = 0.03;
        gravityPreset.life = new Bounds<Float>(2, 3);
        gravityPreset.startPosition = new Bounds<Vector3D>(new Vector3D(500, 500, 500), new Vector3D(500, 500, 500));
        gravityPreset.velocity = new Bounds<Vector3D>(new Vector3D(30, 0, 0), new Vector3D(40, 10, 0));
        startColorMin = new Color(1, 1, 1, 0.6);
		startColorMax = new Color(1, 1, 1, 0.6);
		gravityPreset.startColor = new Bounds<Color>(startColorMin, startColorMax);
		endColorMin = new Color(0, 0, 0, 0.01);
		endColorMax = new Color(1, 1, 1, 0.01);
        gravityPreset.endColor = new Bounds<Color>(endColorMin, endColorMax);
        gravityPreset.gravity = new Vector3D(0, 100, 0);
        gravityPreset.startScale = new Bounds<Float>(0.5);
        gravityPreset.endScale = new Bounds<Float>(0.05);
        gravityPreset.startRotation = new Bounds<Vector3D>(new Vector3D(0, 0, 0), new Vector3D(0, 0, 360));
		
		ps = new ParticleSystem2D(GravityParticleRenderBuilder.gpuRender(gravityPreset));
        ps.x = s.stageWidth * 0.5;
        ps.y = s.stageHeight * 0.5;
		blendMode = new BlendMode(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE);
        ps.blendMode = blendMode;
        ps.texture = texture;
        scene.addChild(ps);
		
		var xml:Xml = ParticleSaver.systemToXml(ps);
		
		Style.embedFonts = false;
        Style.fontSize = 10;
		Style.fontName = "arial";
        Style.setStyle(Style.LIGHT);
		
		gravityWindow = new Window(s, 0, 0, 'Gravity System Settings');
		gravityWindow.setSize(210, 400);
		gravityWindow.draggable = false;
		gravityWindow.hasMinimizeButton = true;
		
		var panel:ScrollPane = new ScrollPane(gravityWindow, 0, 0);
		panel.showGrid = true;
		panel.autoHideScrollBar = true;
		panel.setSize(210, 400);
		
		var startPositionLabel:Label = new Label(panel, 0, 8, "Start Position");
		startPositionLabel.x = (gravityWindow.width - startPositionLabel.width) * 0.5;
		
		var gapBetweenLabelAndSlider:Float = 10;
		var labelX:Float = 10;
		var rangeX:Float = 30;
		var sliderX:Float = 21;
		
		xPosition = new HRangeSlider(panel, rangeX, 30, onXChange);
		xPosition.minimum = -500;
		xPosition.maximum = 500;
		xPosition.lowValue = 0;
		xPosition.highValue = 0;
		xPosition.width = 136;
		xPosition.labelPosition = 'bottom';
		var label:Label = new Label(panel, labelX, 27, "X");
		
		yPosition = new HRangeSlider(panel, rangeX, 60, onYChange);
		yPosition.minimum = -500;
		yPosition.maximum = 500;
		yPosition.lowValue = 0;
		yPosition.highValue = 0;
		yPosition.width = 136;
		yPosition.labelPosition = 'bottom';
		label = new Label(panel, labelX, 57, "Y");
		
		zPosition = new HRangeSlider(panel, rangeX, 90, onZChange);
		zPosition.minimum = -500;
		zPosition.maximum = 500;
		zPosition.lowValue = 0;
		zPosition.highValue = 0;
		zPosition.width = 136;
		zPosition.labelPosition = 'bottom';
		label = new Label(panel, labelX, 87, "Z");
		
		var startVelocityLabel:Label = new Label(panel, 0, 120, "Start Velocity");
		startVelocityLabel.x = (gravityWindow.width - startVelocityLabel.width) * 0.5;
		
		xVelocity = new HRangeSlider(panel, rangeX, 140, onVelocityXChange);
		xVelocity.minimum = -500;
		xVelocity.maximum = 500;
		xVelocity.lowValue = 0;
		xVelocity.highValue = 0;
		xVelocity.width = 136;
		xVelocity.labelPosition = 'bottom';
		var label:Label = new Label(panel, labelX, 137, "X");
		
		yVelocity = new HRangeSlider(panel, rangeX, 170, onVelocityYChange);
		yVelocity.minimum = -500;
		yVelocity.maximum = 500;
		yVelocity.lowValue = 0;
		yVelocity.highValue = 0;
		yVelocity.width = 136;
		yVelocity.labelPosition = 'bottom';
		var label:Label = new Label(panel, labelX, 167, "Y");
		
		zVelocity = new HRangeSlider(panel, rangeX, 200, onVelocityZChange);
		zVelocity.minimum = -500;
		zVelocity.maximum = 500;
		zVelocity.lowValue = 0;
		zVelocity.highValue = 0;
		zVelocity.width = 136;
		zVelocity.labelPosition = 'bottom';
		var label:Label = new Label(panel, labelX, 197, "Z");
		
		var gravityLabel:Label = new Label(panel, 0, 230, "Gravity");
		gravityLabel.x = (gravityWindow.width - gravityLabel.width) * 0.5;
		
		xGravity = new HUISlider(panel, sliderX, 247, onGravityXChange);
		xGravity.setSliderParams( -500, 500, 0);
		var label:Label = new Label(panel, labelX, 247, "X");
		
		yGravity = new HUISlider(panel, sliderX, 277, onGravityYChange);
		yGravity.setSliderParams( -500, 500, 0);
		var label:Label = new Label(panel, labelX, 277, "Y");
		
		zGravity = new HUISlider(panel, sliderX, 307, onGravityYChange);
		zGravity.setSliderParams( -500, 500, 0);
		var label:Label = new Label(panel, labelX, 307, "Z");
		
		// Particle config
		particleWindow = new Window(s, 210, 0, 'Particle Configuration');
		particleWindow.setSize(210, 400);
		particleWindow.draggable = false;
		particleWindow.hasMinimizeButton = true;
		
		var particlePanel = new ScrollPane(particleWindow, 0, 0);
		particlePanel.showGrid = true;
		particlePanel.autoHideScrollBar = true;
		particlePanel.setSize(210, 400);
		
		numParticles = new HUISlider(particlePanel, sliderX, 27, onNumParticlesChange);
		numParticles.setSliderParams(0, 10000, 1000);
		numParticles.labelPrecision = 0;
		numParticles.label = 'particlesNum';
		
		spawnNum = new HUISlider(particlePanel, sliderX, 57, onSpawnNumChange);
		spawnNum.setSliderParams(0, 1000, 100);
		spawnNum.labelPrecision = 0;
		spawnNum.label = 'spawnNum';
		
		spawnStep = new HUISlider(particlePanel, sliderX, 87, onSpawnStepChange);
		spawnStep.setSliderParams(0, 1, 0.03);
		spawnStep.labelPrecision = 3;
		spawnStep.label = 'spawnStep';
		
		life = new HRangeSlider(particlePanel, rangeX, 117, onLigeChange);
		life.minimum = 1;
		life.maximum = 20;
		life.lowValue = 2;
		life.highValue = 3;
		life.width = 136;
		life.labelPosition = 'bottom';
		label = new Label(particlePanel, labelX, 112, "life");
		
		startScale = new HRangeSlider(particlePanel, rangeX, 147, onStartScaleChange);
		startScale.labelPrecision = 2;
		startScale.minimum = 0.01;
		startScale.maximum = 10;
		startScale.lowValue = 1;
		startScale.highValue = 1;
		startScale.width = 136;
		startScale.labelPosition = 'bottom';
		label = new Label(particlePanel, labelX - 20, 142, "startScale");
		
		endScale = new HRangeSlider(particlePanel, rangeX, 177, onEndScaleChange);
		endScale.labelPrecision = 2;
		endScale.minimum = 0.01;
		endScale.maximum = 10;
		endScale.lowValue = 1;
		endScale.highValue = 1;
		endScale.width = 136;
		endScale.labelPosition = 'bottom';
		label = new Label(particlePanel, labelX - 20, 172, "endScale");
		
		angleX = new HRangeSlider(particlePanel, rangeX, 207, onAngleXChange);
		angleX.minimum = 0;
		angleX.maximum = 360;
		angleX.lowValue = 0;
		angleX.highValue = 0;
		angleX.width = 136;
		angleX.labelPosition = 'bottom';
		label = new Label(particlePanel, labelX - 40, 202, "rotation X");
		
		angleY = new HRangeSlider(particlePanel, rangeX, 237, onAngleYChange);
		angleY.minimum = 0;
		angleY.maximum = 360;
		angleY.lowValue = 0;
		angleY.highValue = 0;
		angleY.width = 136;
		angleY.labelPosition = 'bottom';
		label = new Label(particlePanel, labelX - 40, 232, "rotation Y");
		
		angleZ = new HRangeSlider(particlePanel, rangeX, 267, onAngleYChange);
		angleZ.minimum = 0;
		angleZ.maximum = 360;
		angleZ.lowValue = 0;
		angleZ.highValue = 0;
		angleZ.width = 136;
		angleZ.labelPosition = 'bottom';
		label = new Label(particlePanel, labelX - 40, 262, "rotation Z");
		
		// Color config
		colorWindow = new Window(s, 420, 0, 'Particle Color');
		colorWindow.setSize(210, 400);
		colorWindow.draggable = false;
		colorWindow.hasMinimizeButton = true;
		
		var colorPanel = new ScrollPane(colorWindow, 0, 0);
		colorPanel.showGrid = true;
		colorPanel.autoHideScrollBar = true;
		colorPanel.setSize(210, 400);
		
		startR = new HRangeSlider(colorPanel, sliderX, 27, onStartRChange);
		startR.minimum = 0;
		startR.maximum = 1;
		startR.lowValue = 1;
		startR.highValue = 1;
		startR.width = 136;
		startR.labelPrecision = 2;
		startR.labelPosition = 'bottom';
		label = new Label(colorPanel, labelX - 40, 22, "Start R");
		
		startG = new HRangeSlider(colorPanel, sliderX, 57, onStartGChange);
		startG.minimum = 0;
		startG.maximum = 1;
		startG.lowValue = 1;
		startG.highValue = 1;
		startG.width = 136;
		startG.labelPrecision = 2;
		startG.labelPosition = 'bottom';
		label = new Label(colorPanel, labelX - 40, 52, "Start G");
		
		startB = new HRangeSlider(colorPanel, sliderX, 87, onStartBChange);
		startB.minimum = 0;
		startB.maximum = 1;
		startB.lowValue = 1;
		startB.highValue = 1;
		startB.width = 136;
		startB.labelPrecision = 2;
		startB.labelPosition = 'bottom';
		label = new Label(colorPanel, labelX - 40, 82, "Start B");
		
		startA = new HRangeSlider(colorPanel, sliderX, 117, onStartAChange);
		startA.minimum = 0;
		startA.maximum = 1;
		startA.lowValue = 1;
		startA.highValue = 1;
		startA.width = 136;
		startA.labelPrecision = 2;
		startA.labelPosition = 'bottom';
		label = new Label(colorPanel, labelX - 40, 112, "Start A");
		
		//
		endR = new HRangeSlider(colorPanel, sliderX, 147, onEndRChange);
		endR.minimum = 0;
		endR.maximum = 1;
		endR.lowValue = 1;
		endR.highValue = 1;
		endR.width = 136;
		endR.labelPrecision = 2;
		endR.labelPosition = 'bottom';
		label = new Label(colorPanel, labelX - 40, 142, "End R");
		
		endG = new HRangeSlider(colorPanel, sliderX, 177, onEndGChange);
		endG.minimum = 0;
		endG.maximum = 1;
		endG.lowValue = 1;
		endG.highValue = 1;
		endG.width = 136;
		endG.labelPrecision = 2;
		endG.labelPosition = 'bottom';
		label = new Label(colorPanel, labelX - 40, 172, "End G");
		
		endB = new HRangeSlider(colorPanel, sliderX, 207, onEndBChange);
		endB.minimum = 0;
		endB.maximum = 1;
		endB.lowValue = 1;
		endB.highValue = 1;
		endB.width = 136;
		endB.labelPrecision = 2;
		endB.labelPosition = 'bottom';
		label = new Label(colorPanel, labelX - 40, 202, "End B");
		
		endA = new HRangeSlider(colorPanel, sliderX, 237, onEndAChange);
		endA.minimum = 0;
		endA.maximum = 1;
		endA.lowValue = 1;
		endA.highValue = 1;
		endA.width = 136;
		endA.labelPrecision = 2;
		endA.labelPosition = 'bottom';
		label = new Label(colorPanel, labelX - 40, 232, "End A");
		
		// Other settings
		otherSettingsWindow = new Window(s, 630, 0, 'Particle Configuration');
		otherSettingsWindow.setSize(210, 400);
		otherSettingsWindow.draggable = false;
		otherSettingsWindow.hasMinimizeButton = true;
		
		var otherPanel = new ScrollPane(otherSettingsWindow, 0, 0);
		otherPanel.showGrid = true;
		otherPanel.autoHideScrollBar = true;
		otherPanel.setSize(210, 400);
		
		bgRed = new HUISlider(otherPanel, 20, 20, "bgRed", onBgRedChange);
		bgRed.setSliderParams(0, 1, 0.5);
		bgGreen = new HUISlider(otherPanel, 20, 50, "bgGreen", onBgGreenChange);
		bgGreen.setSliderParams(0, 1, 0.5);
		bgBlue = new HUISlider(otherPanel, 20, 80, "bgBlue", onBgBlueChange);
		bgBlue.setSliderParams(0, 1, 0.5);
		
		blendSource = new ComboBox(otherPanel, 20, 110, "SOURCE");
		blendSource.addItem("ZERO");
		blendSource.addItem("ONE");
		blendSource.addItem("SRC");
		blendSource.addItem("ONE_SRC");
		blendSource.addItem("SRC_ALPHA");
		blendSource.addItem("ONE_SRC_ALPHA");
		blendSource.addItem("DST_ALPHA");
		blendSource.addItem("ONE_DST_ALPHA");
		blendSource.addItem("DST_COLOR");
		blendSource.addItem("ONE_DST_COLOR");
		blendSource.selectedItem = "ONE";
		blendSource.addEventListener(Event.SELECT, onBlendSrcSelect);
		
		blendDestination = new ComboBox(otherPanel, 20, 140, "DEST");
		blendDestination.addItem("ZERO");
		blendDestination.addItem("ONE");
		blendDestination.addItem("SRC");
		blendDestination.addItem("ONE_SRC");
		blendDestination.addItem("SRC_ALPHA");
		blendDestination.addItem("ONE_SRC_ALPHA");
		blendDestination.addItem("DST_ALPHA");
		blendDestination.addItem("ONE_DST_ALPHA");
		blendDestination.addItem("DST_COLOR");
		blendDestination.addItem("ONE_DST_COLOR");
		blendDestination.selectedItem = "ONE";
		blendDestination.addEventListener(Event.SELECT, onBlendDestSelect);
		
		textureEditor = new TextureEditor(textureBmd);
		textureEditor.addEventListener(Event.COMPLETE, onTextureChange);
		textureEditor.y = 400;
		s.addChild(textureEditor);
    }
	
	private function onTextureChange(e:Event):Void 
	{
		var bmd:BitmapData = textureEditor.displayData;
		texture = world.cache.getBitmapTexture(bmd);
		ps.texture = texture;
	}
	
	private function onBlendSrcSelect(e:Event):Void 
	{
		switch (Std.string(blendSource.selectedItem))
		{
			case "ZERO":
				blendMode.src = Context3DBlendFactor.ZERO;
			case "ONE":
				blendMode.src = Context3DBlendFactor.ONE;
			case "SRC":
				blendMode.src = Context3DBlendFactor.SOURCE_COLOR;
			case "ONE_SRC":
				blendMode.src = Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR;
			case "SRC_ALPHA":
				blendMode.src = Context3DBlendFactor.SOURCE_ALPHA;
			case "ONE_SRC_ALPHA":
				blendMode.src = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			case "DST_ALPHA":
				blendMode.src = Context3DBlendFactor.DESTINATION_ALPHA;
			case "ONE_DST_ALPHA":
				blendMode.src = Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA;
			case "DST_COLOR":
				blendMode.src = Context3DBlendFactor.DESTINATION_COLOR;
			case "ONE_DST_COLOR":
				blendMode.src = Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR;
		}
	}
	
	private function onBlendDestSelect(e:Event):Void 
	{
		switch (Std.string(blendDestination.selectedItem))
		{
			case "ZERO":
				blendMode.dst = Context3DBlendFactor.ZERO;
			case "ONE":
				blendMode.dst = Context3DBlendFactor.ONE;
			case "SRC":
				blendMode.dst = Context3DBlendFactor.SOURCE_COLOR;
			case "ONE_SRC":
				blendMode.dst = Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR;
			case "SRC_ALPHA":
				blendMode.dst = Context3DBlendFactor.SOURCE_ALPHA;
			case "ONE_SRC_ALPHA":
				blendMode.dst = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			case "DST_ALPHA":
				blendMode.dst = Context3DBlendFactor.DESTINATION_ALPHA;
			case "ONE_DST_ALPHA":
				blendMode.dst = Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA;
			case "DST_COLOR":
				blendMode.dst = Context3DBlendFactor.DESTINATION_COLOR;
			case "ONE_DST_COLOR":
				blendMode.dst = Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR;
		}
	}
	
	function onBgRedChange(param1:Dynamic)
	{
		world.bgColor.r = bgRed.value;
	}
	
	function onBgGreenChange(param1:Dynamic)
	{
		world.bgColor.g = bgGreen.value;
	}
	
	function onBgBlueChange(param1:Dynamic)
	{
		world.bgColor.b = bgBlue.value;
	}
	
	function onXChange(param1:Dynamic)
	{
		gravityPreset.startPosition.min.x = xPosition.lowValue;
		gravityPreset.startPosition.max.x = xPosition.highValue;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onYChange(param1:Dynamic)
	{
		gravityPreset.startPosition.min.y = yPosition.lowValue;
		gravityPreset.startPosition.max.y = yPosition.highValue;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onZChange(param1:Dynamic)
	{
		gravityPreset.startPosition.min.z = zPosition.lowValue;
		gravityPreset.startPosition.max.z = zPosition.highValue;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onVelocityXChange(param1:Dynamic)
	{
		gravityPreset.velocity.min.x = xVelocity.lowValue;
		gravityPreset.velocity.max.x = xVelocity.highValue;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onVelocityYChange(param1:Dynamic)
	{
		gravityPreset.velocity.min.y = yVelocity.lowValue;
		gravityPreset.velocity.max.y = yVelocity.highValue;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onVelocityZChange(param1:Dynamic)
	{
		gravityPreset.velocity.min.z = zVelocity.lowValue;
		gravityPreset.velocity.max.z = zVelocity.highValue;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onGravityXChange(param1:Dynamic)
	{
		gravityPreset.gravity.x = xGravity.value;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onGravityYChange(param1:Dynamic)
	{
		gravityPreset.gravity.y = yGravity.value;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onGravityZChange(param1:Dynamic)
	{
		gravityPreset.gravity.z = zGravity.value;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onNumParticlesChange(param1:Dynamic)
	{
		gravityPreset.particleNum = cast(Std.int(numParticles.value), UInt);
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onSpawnNumChange(param1:Dynamic)
	{
		gravityPreset.spawnNum = cast(Std.int(spawnNum.value), UInt);
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onSpawnStepChange(param1:Dynamic)
	{
		gravityPreset.spawnStep = spawnStep.value;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onLigeChange(param1:Dynamic)
	{
		gravityPreset.life.min = life.lowValue;
		gravityPreset.life.max = life.highValue;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onStartScaleChange(param1:Dynamic)
	{
		gravityPreset.startScale.min = startScale.lowValue;
		gravityPreset.startScale.max = startScale.highValue;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onEndScaleChange(param1:Dynamic)
	{
		gravityPreset.endScale.min = endScale.lowValue;
		gravityPreset.endScale.max = endScale.highValue;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onAngleXChange(param1:Dynamic)
	{
		gravityPreset.startRotation.min.x = angleX.lowValue;
		gravityPreset.startRotation.max.x = angleX.highValue;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onAngleYChange(param1:Dynamic)
	{
		gravityPreset.startRotation.min.y = angleY.lowValue;
		gravityPreset.startRotation.max.y = angleY.highValue;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onAngleZChange(param1:Dynamic)
	{
		gravityPreset.startRotation.min.z = angleZ.lowValue;
		gravityPreset.startRotation.max.z = angleZ.highValue;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onStartRChange(param1:Dynamic)
	{
		gravityPreset.startColor.min.r = startR.lowValue;
		gravityPreset.startColor.max.r = startR.highValue;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onStartGChange(param1:Dynamic)
	{
		gravityPreset.startColor.min.g = startG.lowValue;
		gravityPreset.startColor.max.g = startG.highValue;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onStartBChange(param1:Dynamic)
	{
		gravityPreset.startColor.min.b = startB.lowValue;
		gravityPreset.startColor.max.b = startB.highValue;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onStartAChange(param1:Dynamic)
	{
		gravityPreset.startColor.min.a = startA.lowValue;
		gravityPreset.startColor.max.a = startA.highValue;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onEndRChange(param1:Dynamic)
	{
		gravityPreset.endColor.min.r = endR.lowValue;
		gravityPreset.endColor.max.r = endR.highValue;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onEndGChange(param1:Dynamic)
	{
		gravityPreset.endColor.min.g = endG.lowValue;
		gravityPreset.endColor.max.g = endG.highValue;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onEndBChange(param1:Dynamic)
	{
		gravityPreset.endColor.min.b = endB.lowValue;
		gravityPreset.endColor.max.b = endB.highValue;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}
	
	function onEndAChange(param1:Dynamic)
	{
		gravityPreset.endColor.min.a = endA.lowValue;
		gravityPreset.endColor.max.a = endA.highValue;
		cast(ps.render, ParticleRenderBase).preset = gravityPreset;
	}

    static function main()
    {
        new Main();
    }
}