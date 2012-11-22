package;
import flash.geom.Point;
import com.bit101.components.Accordion;
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
import deep.dd.display.smart.render.RenderBase;
import deep.dd.display.Scene2D;
import deep.dd.display.particle.preset.parser.ParticleParser;
import deep.dd.display.particle.preset.RadialParticlePreset;
import deep.dd.display.particle.render.ParticleRenderBase;
import deep.dd.display.particle.render.RadialParticleRender;
import deep.dd.texture.Texture2D;
import deep.dd.utils.Stats;
import deep.dd.World2D;
import deep.dd.display.particle.ParticleSystem2D;
import deep.dd.display.particle.preset.GravityParticlePreset;
import deep.dd.display.particle.render.GravityParticleRender;
import deep.dd.display.particle.ParticleSystem2D;
import deep.dd.display.particle.render.GravityParticleRender.GPUGravityParticleRender;
import deep.dd.display.particle.preset.ParticlePresetBase;
import deep.dd.display.particle.preset.ParticlePresetBase.Bounds;
import deep.dd.utils.BlendMode;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.StageScaleMode;
import flash.display.StageAlign;
import flash.display3D.Context3DRenderMode;
import flash.display3D.Context3DBlendFactor;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.Lib;
import flash.net.FileFilter;
import flash.net.FileReference;
import flash.utils.ByteArray;
import mt.m3d.Color;

@:bitmap("../assets/img/deep.png") class Image extends BitmapData {}
@:bitmap("../assets/img/circle.png") class Circle extends BitmapData { }

@:file("../assets/xml/campFire.pxml") class CampFireData extends ByteArray { }
@:file("../assets/xml/campFireSmoke.pxml") class CampFireSmokeData extends ByteArray { }
@:file("../assets/xml/candle.pxml") class CandleData extends ByteArray { }
@:file("../assets/xml/dungeonTorch.pxml") class DungeonTorchData extends ByteArray { }
@:file("../assets/xml/heroField.pxml") class HeroFieldData extends ByteArray { }
@:file("../assets/xml/rocketExhaust.pxml") class RocketExhaustData extends ByteArray { }
@:file("../assets/xml/shower.pxml") class ShowerData extends ByteArray { }

class Main
{
	var world:World2D;
    var scene:Scene2D;

    var gravityPreset:GravityParticlePreset;
	var gravityRender:GPUGravityParticleRender;
	var radialPreset:RadialParticlePreset;
	var radialRender:GPURadialParticleRender;
	var currentPreset:ParticlePresetBase;
	var currentRender:ParticleRenderBase;
	var currentPresetClass:Class<ParticlePresetBase>;
    var ps:ParticleSystem2D;
	
	// Particles Configuration
	var particleWindow:Window;
	
	var numParticles:HUISlider;
	var spawnNum:HUISlider;
	var spawnStep:HUISlider;
	var life:HRangeSlider;
	var systemType:ComboBox;
	
	var startScale:HRangeSlider;
	var endScale:HRangeSlider;

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
	
	// Other settings
	var otherSettingsWindow:Window;
	var bgRed:HUISlider;
	var bgGreen:HUISlider;
	var bgBlue:HUISlider;
	
	var blendSource:ComboBox;
	var blendDestination:ComboBox;
	var blendMode:BlendMode;
	
	var preset:ComboBox;
	var renderMode:ComboBox;
	
	// Gravity system's parameters controls
	var gravityWindow:Window;
	var gravityPanel:Panel;
	
	var xPosition:HRangeSlider;
	var yPosition:HRangeSlider;
	
	var xVelocity:HRangeSlider;
	var yVelocity:HRangeSlider;
	
	var xGravity:HUISlider;
	var yGravity:HUISlider;
	
	// Radial system's parameters controls
	var radialWindow:Window;
	var radialPanel:Panel;
	
	var startAngle:HRangeSlider;
	var angleSpeed:HRangeSlider;
	var startDepth:HRangeSlider;
	var depthSpeed:HRangeSlider;
	var startRadius:HRangeSlider;
	var endRadius:HRangeSlider;
	
	var accordion:Accordion;
	
	var load:PushButton;
	var save:PushButton;
	var fileRef:FileReference;
	var fileTypes:Array<FileFilter>;
	
	var textureEditor:TextureEditor;
	var textureBmd:BitmapData;
	var texture:Texture2D;
	
	var sliderX:Float;
	
    public function new()
    {
		fileTypes = [new FileFilter("DD particle system format", "*.pxml")];
		
		var s = flash.Lib.current.stage;
        s.scaleMode = StageScaleMode.NO_SCALE;
        s.align = StageAlign.TOP_LEFT;
		
		world = new World2D(s, Context3DRenderMode.AUTO);
		
		s.addChild(new Stats(world));
		world.scene = scene = new Scene2D();

		world.antialiasing = 2;
        world.bgColor.fromInt(0x333333);
		
		textureBmd = Type.createInstance(Circle, [0, 0]);
		texture = world.cache.getBitmapTexture(textureBmd);
		
		gravityPreset = new GravityParticlePreset();
        gravityPreset.particleNum = 500;
        gravityPreset.spawnNum = 500;
        gravityPreset.spawnStep = 0.03;
        gravityPreset.life = new Bounds<Float>(1, 1.7);
        gravityPreset.startPosition = new Bounds<Vector3D>(new Vector3D(0, 0, 0), new Vector3D(0, 0, 0));
        gravityPreset.velocity = new Bounds<Vector3D>(new Vector3D(0, -70, 0), new Vector3D(0, -130, 0));
		gravityPreset.startColor = new Bounds<Color>(new Color(1, 0.3, 0, 0.6), new Color(1, 0.3, 0, 0.6));
        gravityPreset.endColor = new Bounds<Color>(new Color(1, 0, 0, 0), new Color(1, 0, 0, 0));
        gravityPreset.gravity = new Point(0, 0);
        gravityPreset.startScale = new Bounds<Float>(1.3);
        gravityPreset.endScale = new Bounds<Float>(0.0);
        gravityPreset.startRotation = new Bounds<Float>(0, 0);
		
		radialPreset = new RadialParticlePreset();
		radialPreset.particleNum = 500;
		radialPreset.spawnNum = 500;
        radialPreset.spawnStep = 0.03;
        radialPreset.life = new Bounds<Float>(1, 1.7);
		radialPreset.startColor = new Bounds<Color>(new Color(1, 0.3, 0, 0.6), new Color(1, 0.3, 0, 0.6));
        radialPreset.endColor = new Bounds<Color>(new Color(1, 0, 0, 0), new Color(1, 0, 0, 0));
		radialPreset.startRotation = new Bounds<Float>(0, 0);
		radialPreset.startScale = new Bounds<Float>(1.3);
        radialPreset.endScale = new Bounds<Float>(0.0);
		radialPreset.startAngle = new Bounds<Float>(0, 360);
		radialPreset.angleSpeed = new Bounds<Float>(0, 10);
		radialPreset.startDepth = new Bounds<Float>(0, 0);
		radialPreset.depthSpeed = new Bounds<Float>(0, 0);
		radialPreset.startRadius = new Bounds<Float>(0, 0);
		radialPreset.endRadius = new Bounds<Float>(100, 100);
		
		currentPreset = gravityPreset;
		currentPresetClass = GravityParticlePreset;
		
		gravityRender = GravityParticleRenderBuilder.gpuRender(gravityPreset);
		currentRender = gravityRender;
		
		radialRender = RadialParticleRenderBuilder.gpuRender(radialPreset);
		
		ps = new ParticleSystem2D(currentRender);
        ps.x = s.stageWidth * 0.5;
        ps.y = s.stageHeight * 0.5;
		blendMode = new BlendMode(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE);
        ps.blendMode = blendMode;
        ps.texture = texture;
        scene.addChild(ps);
		
		Style.embedFonts = false;
        Style.fontSize = 10;
		Style.fontName = "arial";
        Style.setStyle(Style.LIGHT);
		
		var gap:Float = 10;
		var gap2:Float = 19;
		
		var guiWindow:Window = new Window(s, 0, 0, "Settings");
		guiWindow.setSize(350, 446);
		guiWindow.draggable = false;
		guiWindow.hasMinimizeButton = true;
		
		accordion = new Accordion(guiWindow, 0, 0);
		accordion.setSize(350, 600);
		
		// Particle config
		particleWindow = accordion.getWindowAt(0);
		particleWindow.title = 'Particle Configuration';
		
		makeLabel(particleWindow, 27, "particlesNum", gap);
		numParticles = new HUISlider(particleWindow, sliderX, 27, onNumParticlesChange);
		numParticles.setSliderParams(0, 15000, 500);
		numParticles.labelPrecision = 0;
		
		makeLabel(particleWindow, 57, "spawnNum", gap);
		spawnNum = new HUISlider(particleWindow, sliderX, 57, onSpawnNumChange);
		spawnNum.setSliderParams(0, 15000, 500);
		spawnNum.labelPrecision = 0;
		
		makeLabel(particleWindow, 87, "spawnStep", gap);
		spawnStep = new HUISlider(particleWindow, sliderX, 87, onSpawnStepChange);
		spawnStep.setSliderParams(0, 2, 0.03);
		spawnStep.labelPrecision = 3;
		
		makeLabel(particleWindow, 112, "life", gap2);
		life = new HRangeSlider(particleWindow, sliderX, 117, onLifeChange);
		life.minimum = 0.1;
		life.maximum = 20;
		life.labelPrecision = 1;
		life.tick = 0.1;
		setValuesForRangeSlider(life, 1, 1.7);
		life.width = 136;
		life.labelPosition = 'bottom';
		
		makeLabel(particleWindow, 142, "startScale", gap2);
		startScale = new HRangeSlider(particleWindow, sliderX, 147, onStartScaleChange);
		startScale.labelPrecision = 2;
		startScale.tick = 0.01;
		startScale.minimum = 0.0;
		startScale.maximum = 50;
		setValuesForRangeSlider(startScale, 1.3, 1.3);
		startScale.width = 136;
		startScale.labelPosition = 'bottom';
		
		makeLabel(particleWindow, 172, "endScale", gap2);
		endScale = new HRangeSlider(particleWindow, sliderX, 177, onEndScaleChange);
		endScale.labelPrecision = 2;
		endScale.tick = 0.01;
		endScale.minimum = 0.0;
		endScale.maximum = 50;
		setValuesForRangeSlider(endScale, 0, 0);
		endScale.width = 136;
		endScale.labelPosition = 'bottom';
		
		makeLabel(particleWindow, 202, "rotation", gap2);
		angleZ = new HRangeSlider(particleWindow, sliderX, 207, onAngleZChange);
		angleZ.minimum = 0;
		angleZ.maximum = 360;
		setValuesForRangeSlider(angleZ, 0, 0);
		angleZ.width = 136;
		angleZ.labelPosition = 'bottom';
		
		makeLabel(particleWindow, 297, "System Type", gap2);
		systemType = new ComboBox(particleWindow, sliderX, 297, 'Type', ['Gravity', 'Radial']);
		systemType.selectedIndex = 0;
		systemType.addEventListener(Event.SELECT, switchTypePanels);
		
		// Other settings
		otherSettingsWindow = accordion.getWindowAt(1);
		otherSettingsWindow.title = 'Particle Configuration 2';
		
		makeLabel(otherSettingsWindow, 20, "bgRed", gap);
		bgRed = new HUISlider(otherSettingsWindow, sliderX, 20, onBgRedChange);
		bgRed.setSliderParams(0, 1, 0.5);
		
		makeLabel(otherSettingsWindow, 50, "bgGreen", gap);
		bgGreen = new HUISlider(otherSettingsWindow, sliderX, 50, onBgGreenChange);
		bgGreen.setSliderParams(0, 1, 0.5);
		
		makeLabel(otherSettingsWindow, 80, "bgBlue", gap);
		bgBlue = new HUISlider(otherSettingsWindow, sliderX, 80, onBgBlueChange);
		bgBlue.setSliderParams(0, 1, 0.5);
		
		makeLabel(otherSettingsWindow, 110, "Blend SRC", gap2);
		blendSource = new ComboBox(otherSettingsWindow, sliderX, 110, "SOURCE");
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
		
		makeLabel(otherSettingsWindow, 140, "Blend DST", gap2);
		blendDestination = new ComboBox(otherSettingsWindow, sliderX, 140, "DEST");
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
		
		makeLabel(otherSettingsWindow, 170, "Preset", gap2);
		preset = new ComboBox(otherSettingsWindow, sliderX, 170, "Preset");
		preset.addItem("Custom");
		preset.addItem("CampFire");
		preset.addItem("CampFireSmoke");
		preset.addItem("Candle");
		preset.addItem("DungeonTorch");
		preset.addItem("HeroField");
		preset.addItem("RocketExhaust");
		preset.addItem("Shower");
		setCustomPreset();
		preset.addEventListener(Event.SELECT, onPresetSelect);
		
		makeLabel(otherSettingsWindow, 200, "RenderMode", gap2);
		renderMode = new ComboBox(otherSettingsWindow, sliderX, 200, "RenderMode");
		renderMode.addItem("GPU");
		renderMode.addItem("CPU_Cloud");
		renderMode.addItem("CPU_Batch");
		renderMode.addEventListener(Event.SELECT, onRenderModeSelect);
		
		save = new PushButton(otherSettingsWindow, sliderX, 230, "Save The System", onSave);
		load = new PushButton(otherSettingsWindow, sliderX, 260, "Load The System", onLoad);
		
		// Color config
		accordion.addWindow('Particle Color');
		colorWindow = accordion.getWindowAt(2);
		
		makeLabel(colorWindow, 22, "Start R", gap2);
		startR = new HRangeSlider(colorWindow, sliderX, 27, onStartRChange);
		startR.labelPrecision = 2;
		startR.tick = 0.01;
		startR.minimum = 0;
		startR.maximum = 1;
		setValuesForRangeSlider(startR, 1, 1);
		startR.width = 136;
		startR.labelPosition = 'bottom';
		
		makeLabel(colorWindow, 52, "Start G", gap2);
		startG = new HRangeSlider(colorWindow, sliderX, 57, onStartGChange);
		startG.labelPrecision = 2;
		startG.tick = 0.01;
		startG.minimum = 0;
		startG.maximum = 1;
		setValuesForRangeSlider(startG, 0.3, 0.3);
		startG.width = 136;
		startG.labelPosition = 'bottom';
		
		makeLabel(colorWindow, 82, "Start B", gap2);
		startB = new HRangeSlider(colorWindow, sliderX, 87, onStartBChange);
		startB.labelPrecision = 2;
		startB.tick = 0.01;
		startB.minimum = 0;
		startB.maximum = 1;
		setValuesForRangeSlider(startB, 0, 0);
		startB.width = 136;
		startB.labelPosition = 'bottom';
		
		makeLabel(colorWindow, 112, "Start A", gap2);
		startA = new HRangeSlider(colorWindow, sliderX, 117, onStartAChange);
		startA.labelPrecision = 2;
		startA.tick = 0.01;
		startA.minimum = 0;
		startA.maximum = 1;
		setValuesForRangeSlider(startA, 0.6, 0.6);
		startA.width = 136;
		startA.labelPosition = 'bottom';
		
		//
		makeLabel(colorWindow, 142, "End R", gap2);
		endR = new HRangeSlider(colorWindow, sliderX, 147, onEndRChange);
		endR.labelPrecision = 2;
		endR.tick = 0.01;
		endR.minimum = 0;
		endR.maximum = 1;
		setValuesForRangeSlider(endR, 1, 1);
		endR.width = 136;
		endR.labelPosition = 'bottom';
		
		makeLabel(colorWindow, 172, "End G", gap2);
		endG = new HRangeSlider(colorWindow, sliderX, 177, onEndGChange);
		endG.labelPrecision = 2;
		endG.tick = 0.01;
		endG.minimum = 0;
		endG.maximum = 1;
		setValuesForRangeSlider(endG, 0, 0);
		endG.width = 136;
		endG.labelPosition = 'bottom';
		
		makeLabel(colorWindow, 202, "End B", gap2);
		endB = new HRangeSlider(colorWindow, sliderX, 207, onEndBChange);
		endB.labelPrecision = 2;
		endB.tick = 0.01;
		endB.minimum = 0;
		endB.maximum = 1;
		setValuesForRangeSlider(endB, 0, 0);
		endB.width = 136;
		endB.labelPosition = 'bottom';
		
		makeLabel(colorWindow, 232, "End A", gap2);
		endA = new HRangeSlider(colorWindow, sliderX, 237, onEndAChange);
		endA.labelPrecision = 2;
		endA.tick = 0.01;
		endA.minimum = 0;
		endA.maximum = 1;
		setValuesForRangeSlider(endA, 0, 0);
		endA.width = 136;
		endA.labelPosition = 'bottom';
		
		//"Texture Editor"
		accordion.addWindow('Texture Editor');
		textureEditor = new TextureEditor(textureBmd, accordion.getWindowAt(3));
		textureEditor.addEventListener(Event.COMPLETE, onTextureChange);
		
		// gravity settings
		accordion.addWindow('Gravity System Settings');
		gravityWindow = accordion.getWindowAt(4);
		
		gravityPanel = new Panel(gravityWindow, 0, 0);
		gravityPanel.setSize(350, 500);
		
		var startPositionLabel:Label = new Label(gravityPanel, 0, 8, "Start Position");
		startPositionLabel.x = (gravityPanel.width - startPositionLabel.width) * 0.5;
		
		makeLabel(gravityPanel, 27, "X", gap2);
		xPosition = new HRangeSlider(gravityPanel, sliderX, 30, onXChange);
		xPosition.minimum = -1000;
		xPosition.maximum = 1000;
		setValuesForRangeSlider(xPosition, 0, 0);
		xPosition.width = 136;
		xPosition.labelPosition = 'bottom';
		
		makeLabel(gravityPanel, 57, "Y", gap2);
		yPosition = new HRangeSlider(gravityPanel, sliderX, 60, onYChange);
		yPosition.minimum = -1000;
		yPosition.maximum = 1000;
		setValuesForRangeSlider(yPosition, 0, 0);
		yPosition.width = 136;
		yPosition.labelPosition = 'bottom';
		
		var startVelocityLabel:Label = new Label(gravityPanel, 0, 90, "Start Velocity");
		startVelocityLabel.x = (gravityPanel.width - startVelocityLabel.width) * 0.5;
		
		makeLabel(gravityPanel, 107, "X", gap2);
		xVelocity = new HRangeSlider(gravityPanel, sliderX, 110, onVelocityXChange);
		xVelocity.minimum = -500;
		xVelocity.maximum = 500;
		setValuesForRangeSlider(xVelocity, 0, 0);
		xVelocity.width = 136;
		xVelocity.labelPosition = 'bottom';
		
		makeLabel(gravityPanel, 137, "Y", gap2);
		yVelocity = new HRangeSlider(gravityPanel, sliderX, 140, onVelocityYChange);
		yVelocity.minimum = -500;
		yVelocity.maximum = 500;
		setValuesForRangeSlider(yVelocity, -130, -70);
		yVelocity.width = 136;
		yVelocity.labelPosition = 'bottom';
		
		var gravityLabel:Label = new Label(gravityPanel, 0, 170, "Gravity");
		gravityLabel.x = (gravityPanel.width - gravityLabel.width) * 0.5;
		
		makeLabel(gravityPanel, 187, "X", gap);
		xGravity = new HUISlider(gravityPanel, sliderX, 187, onGravityXChange);
		xGravity.setSliderParams( -500, 500, 0);
		
		makeLabel(gravityPanel, 217, "Y", gap);
		yGravity = new HUISlider(gravityPanel, sliderX, 217, onGravityYChange);
		yGravity.setSliderParams( -500, 500, 0);
		
		// radial settings
		radialWindow = gravityWindow;
		radialPanel = new Panel(radialWindow, 0, 0);
		radialPanel.setSize(350, 500);
		
		makeLabel(radialPanel, 27, "startAngle", gap2);
		startAngle = new HRangeSlider(radialPanel, sliderX, 30, onStartAngleChange);
		startAngle.minimum = 0;
		startAngle.maximum = 360;
		setValuesForRangeSlider(startAngle, 0, 360);
		startAngle.width = 136;
		startAngle.labelPosition = 'bottom';
		
		makeLabel(radialPanel, 57, "angleSpeed", gap2);
		angleSpeed = new HRangeSlider(radialPanel, sliderX, 60, onAngleSpeedChange);
		angleSpeed.minimum = -360;
		angleSpeed.maximum = 360;
		setValuesForRangeSlider(angleSpeed, 0, 10);
		angleSpeed.width = 136;
		angleSpeed.labelPosition = 'bottom';
		
		makeLabel(radialPanel, 87, "startDepth", gap2);
		startDepth = new HRangeSlider(radialPanel, sliderX, 90, onStartDepthChange);
		startDepth.minimum = -5000;
		startDepth.maximum = 5000;
		setValuesForRangeSlider(startDepth, 0, 0);
		startDepth.width = 136;
		startDepth.labelPosition = 'bottom';
		
		makeLabel(radialPanel, 117, "depthSpeed", gap2);
		depthSpeed = new HRangeSlider(radialPanel, sliderX, 120, onDepthSpeedChange);
		depthSpeed.minimum = -500;
		depthSpeed.maximum = 500;
		setValuesForRangeSlider(depthSpeed, 0, 0);
		depthSpeed.width = 136;
		depthSpeed.labelPosition = 'bottom';
		
		makeLabel(radialPanel, 147, "startRadius", gap2);
		startRadius = new HRangeSlider(radialPanel, sliderX, 150, onStartRadiusChange);
		startRadius.minimum = 0;
		startRadius.maximum = 500;
		setValuesForRangeSlider(startRadius, 0, 0);
		startRadius.width = 136;
		startRadius.labelPosition = 'bottom';
		
		makeLabel(radialPanel, 177, "endRadius", gap2);
		endRadius = new HRangeSlider(radialPanel, sliderX, 180, onEndRadiusChange);
		endRadius.minimum = 0;
		endRadius.maximum = 500;
		setValuesForRangeSlider(endRadius, 0, 100);
		endRadius.width = 136;
		endRadius.labelPosition = 'bottom';
		
		switchTypePanels();
		updateUI();
		
		s.addEventListener(MouseEvent.CLICK, onStageClick);
		s.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }
	
	private function onRenderModeSelect(e:Event):Void 
	{
		/*renderMode.addItem("GPU");
		renderMode.addItem("CPU_Cloud");
		renderMode.addItem("CPU_Batch");*/
		
		var selectedRenderMode:String = Std.string(renderMode.selectedItem);
		var newRenderer:ParticleRenderBase = null;
		
		if (Std.is(currentPreset, GravityParticlePreset))
		{
			switch (selectedRenderMode)
			{
				case "GPU":
					newRenderer = GravityParticleRenderBuilder.gpuRender(gravityPreset);
				case "CPU_Cloud":
					newRenderer = GravityParticleRenderBuilder.cpuCloudRender(gravityPreset);
				case "CPU_Batch":
					newRenderer = GravityParticleRenderBuilder.cpuBatchRender(gravityPreset);
			}
		}
		else if (Std.is(currentPreset, RadialParticlePreset))
		{
			
		}
		
		if (newRenderer != null)
		{
            var old = ps.render;
			ps.render = newRenderer;
            if (old != null) old.dispose();
		}
	}
	
	private function makeLabel(parent:Dynamic, labelY:Float, labelText:String, gap:Float)
	{
		var maxLabelWidth:Float = 65;
		var minLabelX:Float = 10;
		var label:Label = new Label(parent, minLabelX, labelY, labelText);
		var labelX:Float = minLabelX + (maxLabelWidth - label.width);
		sliderX = labelX + label.width + gap;
		label.x = labelX;
	}
	
	private function switchTypePanels(e:Event = null):Void 
	{
		if (systemType.selectedItem == "Gravity")
		{
			gravityPanel.visible = true;
			radialPanel.visible = false;
			gravityWindow.title = "Gravity System Settings";
			
			currentPreset = gravityPreset;
			currentRender = gravityRender;
			currentPresetClass = GravityParticlePreset;
		}
		else
		{
			gravityPanel.visible = false;
			radialPanel.visible = true;
			radialWindow.title = "Radial System Settings";
			
			currentPreset = radialPreset;
			currentRender = radialRender;
			currentPresetClass = RadialParticlePreset;
		}
		
		needUpdate = true;
	}
	
	var needUpdate:Bool = false;
	
	private function onEnterFrame(e:Event):Void 
	{
		if (needUpdate)
		{
			ps.render = currentRender;
			cast(ps.render, ParticleRenderBase).preset = currentPreset;
			needUpdate = false;
		}
	}
	
	private function onStageClick(e:MouseEvent):Void 
	{
		if (e.target == Lib.current.stage)
		{
			ps.x = e.stageX;
			ps.y = e.stageY;
		}
	}
	
	private function onSave(e:Event) 
	{
		var fileName:String = "particle.pxml";
		var data:String = ParticleSaver.systemToXmlString(ps); // .toString();
		fileRef = new FileReference();
		fileRef.addEventListener(Event.COMPLETE, onSaveComplete);
		fileRef.addEventListener(Event.CANCEL, onSaveCancel);
		fileRef.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		fileRef.save(data, fileName);
	}
	
	private function onSaveComplete(e:Event):Void 
	{
		fileRef.removeEventListener(Event.COMPLETE, onSaveComplete);
		fileRef.removeEventListener(Event.CANCEL,onSaveCancel);
		fileRef.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		fileRef = null;
	}
	
	private function onSaveCancel(e:Event):Void 
	{
		fileRef.removeEventListener(Event.COMPLETE, onSaveComplete);
		fileRef.removeEventListener(Event.CANCEL,onSaveCancel);
		fileRef.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		fileRef = null;
	}
	
	private function onSaveError(e:IOErrorEvent):Void 
	{
		fileRef.removeEventListener(Event.COMPLETE, onSaveComplete);
		fileRef.removeEventListener(Event.CANCEL,onSaveCancel);
		fileRef.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		fileRef = null;
	}
	
	private function onLoad(e:Event) 
	{
		fileRef = new FileReference();
		fileRef.addEventListener(Event.SELECT, onOpenSelect);
		fileRef.addEventListener(Event.CANCEL, onOpenCancel);
		fileRef.browse(fileTypes);
	}
	
	private function onOpenSelect(e:Event = null):Void
	{
		fileRef.removeEventListener(Event.SELECT, onOpenSelect);
		fileRef.removeEventListener(Event.CANCEL, onOpenCancel);
		fileRef.addEventListener(Event.COMPLETE, onOpenComplete);
		fileRef.addEventListener(IOErrorEvent.IO_ERROR, onOpenError);
		fileRef.load();
	}
	
	private function onOpenComplete(e:Event = null):Void
	{
		fileRef.removeEventListener(Event.COMPLETE, onOpenComplete);
		fileRef.removeEventListener(IOErrorEvent.IO_ERROR, onOpenError);
		
		var fileContents:String = null;
		var data:ByteArray = fileRef.data;
		if (data != null)
		{
			fileContents = data.readUTFBytes(data.bytesAvailable);
		}
		fileRef = null;
		if((fileContents == null) || (fileContents.length <= 0))
		{
			#if debug
			throw "empty file";
			#end
			return;
		}
		
		replaceParticleSystem(ParticleParser.parseXml(Xml.parse(fileContents)));
	}
	
	private function replaceParticleSystem(newSystem:ParticleSystem2D):Void
	{
		var exist:Bool = (ps != null);
		var psx:Float = world.bounds.width * 0.5;
		var psy:Float = world.bounds.height * 0.5;
		
		if (exist)
		{
			psx = ps.x;
			psy = ps.y;
			world.scene.removeChild(ps);
			ps = null;
		}
		
		ps = newSystem;
		ps.x = psx;
        ps.y = psy;
		ps.texture = texture;
		blendMode = ps.blendMode;
		world.scene.addChild(ps);
		
		if (Std.is(cast(ps.render, ParticleRenderBase).preset, GravityParticlePreset))
		{
			currentPreset = gravityPreset = cast(cast(ps.render, ParticleRenderBase).preset, GravityParticlePreset);
			currentPresetClass = GravityParticlePreset;
			gravityRender = cast ps.render;
		}
		else
		{
			currentPreset = radialPreset = cast(cast(ps.render, ParticleRenderBase).preset, RadialParticlePreset);
			currentPresetClass = RadialParticlePreset;
			radialRender = cast ps.render;
		}
		currentRender = cast ps.render;
		
		updateUI();
	}
	
	private function onOpenCancel(e:Event = null):Void
	{
		fileRef.removeEventListener(Event.SELECT, onOpenSelect);
		fileRef.removeEventListener(Event.CANCEL, onOpenCancel);
		fileRef = null;
	}
	
	private function onOpenError(e:Event=null):Void
	{
		fileRef.removeEventListener(Event.COMPLETE, onOpenComplete);
		fileRef.removeEventListener(IOErrorEvent.IO_ERROR, onOpenError);
		fileRef = null;
		
		#if debug
		throw "Unable to open DD particle system file";
		#end
	}
	
	private function onTextureChange(e:Event):Void 
	{
		var bmd:BitmapData = textureEditor.displayData;
		texture = world.cache.getBitmapTexture(bmd);
		ps.texture = texture;
	}
	
	private function blendFactorToString(blendFactor:Context3DBlendFactor):String
	{
		var str:String = "";
		switch (blendFactor)
		{
			case Context3DBlendFactor.ZERO:
				str = "ZERO";
			case Context3DBlendFactor.ONE:
				str = "ONE";
			case Context3DBlendFactor.SOURCE_COLOR:
				str = "SRC";
			case Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR:
				str = "ONE_SRC";
			case Context3DBlendFactor.SOURCE_ALPHA:
				str = "SRC_ALPHA";
			case Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA:
				str = "ONE_SRC_ALPHA";
			case Context3DBlendFactor.DESTINATION_ALPHA:
				str = "DST_ALPHA";
			case Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA:
				str = "ONE_DST_ALPHA";
			case Context3DBlendFactor.DESTINATION_COLOR:
				str = "DST_COLOR";
			case Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR:
				str = "ONE_DST_COLOR";
		}
		return str;
	}
	
	private function onPresetSelect(e:Event):Void 
	{
		var systemBytes:ByteArray = null;
		switch (Std.string(preset.selectedItem))
		{
			case "CampFire":
				systemBytes = new CampFireData();
			case "CampFireSmoke":
				systemBytes = new CampFireSmokeData();
			case "Candle":
				systemBytes = new CandleData();
			case "DungeonTorch":
				systemBytes = new DungeonTorchData();
			case "HeroField":
				systemBytes = new HeroFieldData();
			case "RocketExhaust":
				systemBytes = new RocketExhaustData();
			case "Shower":
				systemBytes = new ShowerData();
		}
		
		if (systemBytes != null)
		{
			replaceParticleSystem(ParticleParser.parseXml(Xml.parse(Std.string(systemBytes))));
		}
	}
	
	private function setCustomPreset():Void
	{
		preset.selectedItem = "Custom";
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
		needUpdate = true;
	}
	
	function onYChange(param1:Dynamic)
	{
		gravityPreset.startPosition.min.y = yPosition.lowValue;
		gravityPreset.startPosition.max.y = yPosition.highValue;
		needUpdate = true;
	}
	
	function onVelocityXChange(param1:Dynamic)
	{
		gravityPreset.velocity.min.x = xVelocity.lowValue;
		gravityPreset.velocity.max.x = xVelocity.highValue;
		needUpdate = true;
	}
	
	function onVelocityYChange(param1:Dynamic)
	{
		gravityPreset.velocity.min.y = yVelocity.lowValue;
		gravityPreset.velocity.max.y = yVelocity.highValue;
		needUpdate = true;
	}
	
	function onGravityXChange(param1:Dynamic)
	{
		gravityPreset.gravity.x = xGravity.value;
		needUpdate = true;
	}
	
	function onGravityYChange(param1:Dynamic)
	{
		gravityPreset.gravity.y = yGravity.value;
		needUpdate = true;
	}
	
	function onGravityZChange(param1:Dynamic)
	{
	}
	
	function onNumParticlesChange(param1:Dynamic)
	{
		gravityPreset.particleNum = cast(Std.int(numParticles.value), UInt);
		radialPreset.particleNum = gravityPreset.particleNum;
		needUpdate = true;
	}
	
	function onSpawnNumChange(param1:Dynamic)
	{
		gravityPreset.spawnNum = cast(Std.int(spawnNum.value), UInt);
		radialPreset.spawnNum = gravityPreset.spawnNum;
		needUpdate = true;
	}
	
	function onSpawnStepChange(param1:Dynamic)
	{
		gravityPreset.spawnStep = spawnStep.value;
		radialPreset.spawnStep = spawnStep.value;
		needUpdate = true;
	}
	
	function onLifeChange(param1:Dynamic)
	{
		gravityPreset.life.min = life.lowValue;
		gravityPreset.life.max = life.highValue;
		
		radialPreset.life.min = life.lowValue;
		radialPreset.life.max = life.highValue;
		needUpdate = true;
	}
	
	function onStartScaleChange(param1:Dynamic)
	{
		gravityPreset.startScale.min = startScale.lowValue;
		gravityPreset.startScale.max = startScale.highValue;
		
		radialPreset.startScale.min = startScale.lowValue;
		radialPreset.startScale.max = startScale.highValue;
		needUpdate = true;
	}
	
	function onEndScaleChange(param1:Dynamic)
	{
		gravityPreset.endScale.min = endScale.lowValue;
		gravityPreset.endScale.max = endScale.highValue;
		
		radialPreset.endScale.min = endScale.lowValue;
		radialPreset.endScale.max = endScale.highValue;
		needUpdate = true;
	}
	
	function onAngleZChange(param1:Dynamic)
	{
		gravityPreset.startRotation.min = angleZ.lowValue;
		gravityPreset.startRotation.max = angleZ.highValue;
		
		radialPreset.startRotation.min = angleZ.lowValue;
		radialPreset.startRotation.max = angleZ.highValue;
		needUpdate = true;
	}
	
	function onStartRChange(param1:Dynamic)
	{
		gravityPreset.startColor.min.r = startR.lowValue;
		gravityPreset.startColor.max.r = startR.highValue;
		
		radialPreset.startColor.min.r = startR.lowValue;
		radialPreset.startColor.max.r = startR.highValue;
		needUpdate = true;
	}
	
	function onStartGChange(param1:Dynamic)
	{
		gravityPreset.startColor.min.g = startG.lowValue;
		gravityPreset.startColor.max.g = startG.highValue;
		
		radialPreset.startColor.min.g = startG.lowValue;
		radialPreset.startColor.max.g = startG.highValue;
		needUpdate = true;
	}
	
	function onStartBChange(param1:Dynamic)
	{
		gravityPreset.startColor.min.b = startB.lowValue;
		gravityPreset.startColor.max.b = startB.highValue;
		
		radialPreset.startColor.min.b = startB.lowValue;
		radialPreset.startColor.max.b = startB.highValue;
		needUpdate = true;
	}
	
	function onStartAChange(param1:Dynamic)
	{
		gravityPreset.startColor.min.a = startA.lowValue;
		gravityPreset.startColor.max.a = startA.highValue;
		
		radialPreset.startColor.min.a = startA.lowValue;
		radialPreset.startColor.max.a = startA.highValue;
		needUpdate = true;
	}
	
	function onEndRChange(param1:Dynamic)
	{
		gravityPreset.endColor.min.r = endR.lowValue;
		gravityPreset.endColor.max.r = endR.highValue;
		
		radialPreset.endColor.min.r = endR.lowValue;
		radialPreset.endColor.max.r = endR.highValue;
		needUpdate = true;
	}
	
	function onEndGChange(param1:Dynamic)
	{
		gravityPreset.endColor.min.g = endG.lowValue;
		gravityPreset.endColor.max.g = endG.highValue;
		
		radialPreset.endColor.min.g = endG.lowValue;
		radialPreset.endColor.max.g = endG.highValue;
		needUpdate = true;
	}
	
	function onEndBChange(param1:Dynamic)
	{
		gravityPreset.endColor.min.b = endB.lowValue;
		gravityPreset.endColor.max.b = endB.highValue;
		
		radialPreset.endColor.min.b = endB.lowValue;
		radialPreset.endColor.max.b = endB.highValue;
		needUpdate = true;
	}
	
	function onEndAChange(param1:Dynamic)
	{
		gravityPreset.endColor.min.a = endA.lowValue;
		gravityPreset.endColor.max.a = endA.highValue;
		
		radialPreset.endColor.min.a = endA.lowValue;
		radialPreset.endColor.max.a = endA.highValue;
		needUpdate = true;
	}
	
	private function onEndRadiusChange(param1:Dynamic) 
	{
		radialPreset.endRadius.min = endRadius.lowValue;
		radialPreset.endRadius.max = endRadius.highValue;
		needUpdate = true;
	}
	
	private function onStartRadiusChange(param1:Dynamic) 
	{
		radialPreset.startRadius.min = startRadius.lowValue;
		radialPreset.startRadius.max = startRadius.highValue;
		needUpdate = true;
	}
	
	private function onDepthSpeedChange(param1:Dynamic) 
	{
		radialPreset.depthSpeed.min = depthSpeed.lowValue;
		radialPreset.depthSpeed.max = depthSpeed.highValue;
		needUpdate = true;
	}
	
	private function onStartDepthChange(param1:Dynamic) 
	{
		radialPreset.startDepth.min = startDepth.lowValue;
		radialPreset.startDepth.max = startDepth.highValue;
		needUpdate = true;
	}
	
	private function onAngleSpeedChange(param1:Dynamic) 
	{
		radialPreset.angleSpeed.min = angleSpeed.lowValue;
		radialPreset.angleSpeed.max = angleSpeed.highValue;
		needUpdate = true;
	}
	
	private function onStartAngleChange(param1:Dynamic) 
	{
		radialPreset.startAngle.min = startAngle.lowValue;
		radialPreset.startAngle.max = startAngle.highValue;
		needUpdate = true;
	}
	
	private function updateUI():Void
	{
		blendSource.selectedItem = blendFactorToString(blendMode.src);
		blendDestination.selectedItem = blendFactorToString(blendMode.dst);
		
		if (currentPresetClass == GravityParticlePreset)
		{
			systemType.selectedItem = "Gravity";
			var grav:GravityParticlePreset = cast(cast(ps.render, ParticleRenderBase).preset, GravityParticlePreset);
			
			setValuesForRangeSlider(xPosition, grav.startPosition.min.x, grav.startPosition.max.x);
			setValuesForRangeSlider(yPosition, grav.startPosition.min.y, grav.startPosition.max.y);
			
			setValuesForRangeSlider(xVelocity, grav.velocity.min.x, grav.velocity.max.x);
			setValuesForRangeSlider(yVelocity, grav.velocity.min.y, grav.velocity.max.y);
			
			xGravity.value = grav.gravity.x;
			yGravity.value = grav.gravity.y;
		}
		else
		{
			systemType.selectedItem = "Radial";
			var radial:RadialParticlePreset = cast(cast(ps.render, ParticleRenderBase).preset, RadialParticlePreset);
			
			setValuesForRangeSlider(startAngle, radial.startAngle.min, radial.startAngle.max);
			
			setValuesForRangeSlider(angleSpeed, radial.angleSpeed.min, radial.angleSpeed.max);
			
			setValuesForRangeSlider(startDepth, radial.startDepth.min, radial.startDepth.max);
			
			setValuesForRangeSlider(depthSpeed, radial.depthSpeed.min, radial.depthSpeed.max);
			
			setValuesForRangeSlider(startRadius, radial.startRadius.min, radial.startRadius.max);
			
			setValuesForRangeSlider(endRadius, radial.endRadius.min, radial.endRadius.max);
		}
		
		var preset = currentPreset;// cast(ps.render, ParticleRenderBase).preset;
		numParticles.value = preset.particleNum;
		spawnNum.value = preset.spawnNum;
		spawnStep.value = preset.spawnStep;
		
		setValuesForRangeSlider(life, preset.life.min, preset.life.max);
		
		setValuesForRangeSlider(startScale, Reflect.field(preset, 'startScale').min, Reflect.field(preset, 'startScale').max);
		
		setValuesForRangeSlider(endScale, Reflect.field(preset, 'endScale').min, Reflect.field(preset, 'endScale').max);
		
		var startRotationMin:Float = cast(Reflect.field(preset, 'startRotation').min, Float);
		var startRotationMax:Float = cast(Reflect.field(preset, 'startRotation').max, Float);
		
		setValuesForRangeSlider(angleZ, startRotationMin, startRotationMax);
		
		var startColorMin:Color = cast(Reflect.field(preset, 'startColor').min, Color);
		var startColorMax:Color = cast(Reflect.field(preset, 'startColor').max, Color);
		
		setValuesForRangeSlider(startR, startColorMin.r, startColorMax.r);
		setValuesForRangeSlider(startG, startColorMin.g, startColorMax.g);
		setValuesForRangeSlider(startB, startColorMin.b, startColorMax.b);
		setValuesForRangeSlider(startA, startColorMin.a, startColorMax.a);
		
		var endColorMin:Color = cast(Reflect.field(preset, 'endColor').min, Color);
		var endColorMax:Color = cast(Reflect.field(preset, 'endColor').max, Color);
		
		setValuesForRangeSlider(endR, endColorMin.r, endColorMax.r);
		setValuesForRangeSlider(endG, endColorMin.g, endColorMax.g);
		setValuesForRangeSlider(endB, endColorMin.b, endColorMax.b);
		setValuesForRangeSlider(endA, endColorMin.a, endColorMax.a);
	}
	
	private function setValuesForRangeSlider(slider:HRangeSlider, min:Float, max:Float)
	{
		var currentMin:Float = slider.lowValue;
		var currentMax:Float = slider.highValue;
		
		if (max <= currentMin)
		{
			slider.lowValue = min;
			slider.highValue = max;
		}
		else// if (min >= currentMax)
		{
			slider.highValue = max;
			slider.lowValue = min;
		}
	}

    static function main()
    {
        new Main();
    }
}