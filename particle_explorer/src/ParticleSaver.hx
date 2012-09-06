package;

import deep.dd.particle.ParticleSystem2D;
import deep.dd.particle.preset.GravityParticlePreset;
import deep.dd.particle.preset.ParticlePresetBase;
import deep.dd.particle.preset.RadialParticlePreset;
import deep.dd.particle.render.ParticleRenderBase;
import deep.dd.particle.render.GravityParticleRender;
import deep.dd.particle.render.RadialParticleRender;
import deep.dd.utils.BlendMode;
import flash.geom.Vector3D;
import mt.m3d.Color;

import flash.display3D.Context3DBlendFactor;
	
/**
 * ...
 * @author Zaphod
 */
class ParticleSaver 
{
	public static function systemToXml(ps:ParticleSystem2D):Xml
	{
		var config:Xml = Xml.createElement("particleEmitterConfig");
		var type:String = "";
		
		var preset:ParticlePresetBase = cast(ps.render, ParticleRenderBase).preset;
		if (Std.is(preset, GravityParticlePreset))
		{
			type = "gravity";
		}
		else
		{
			type = "radial";
		}
		
		var typeElmnt:Xml = Xml.createElement("type");
		typeElmnt.set("value", type);
		config.addChild(typeElmnt);
		
		var life:Xml = Xml.createElement("life");
		life.set("min", Std.string(preset.life.min));
		life.set("max", Std.string(preset.life.max));
		config.addChild(life);
		
		var particleNum:Xml = Xml.createElement("particleNum");
		particleNum.set("value", Std.string(preset.particleNum));
		config.addChild(particleNum);
		
		var spawnNum:Xml = Xml.createElement("spawnNum");
		spawnNum.set("value", Std.string(preset.spawnNum));
		config.addChild(spawnNum);
		
		var spawnStep:Xml = Xml.createElement("spawnStep");
		spawnStep.set("value", Std.string(preset.spawnStep));
		config.addChild(spawnStep);
		
		var blend:Xml = Xml.createElement("blend");
		var src:String = blendFactorToString(ps.blendMode.src);
		var dst:String = blendFactorToString(ps.blendMode.dst);
		
		blend.set("source", src);
		blend.set("destination", dst);
		config.addChild(blend);
		
		var startColor:Xml = Xml.createElement("startColor");
		var endColor:Xml = Xml.createElement("endColor");
		var startScale:Xml = Xml.createElement("startScale");
		var endScale:Xml = Xml.createElement("endScale");
		var rotation:Xml = Xml.createElement("rotation");
		
		if (type == "gravity")
		{
			var gravityPreset:GravityParticlePreset = cast(preset, GravityParticlePreset);
			
			startColor.set("minR", Std.string(gravityPreset.startColor.min.r));
			startColor.set("maxR", Std.string(gravityPreset.startColor.max.r));
			startColor.set("minG", Std.string(gravityPreset.startColor.min.g));
			startColor.set("maxG", Std.string(gravityPreset.startColor.max.g));
			startColor.set("minB", Std.string(gravityPreset.startColor.min.b));
			startColor.set("maxB", Std.string(gravityPreset.startColor.max.b));
			startColor.set("minA", Std.string(gravityPreset.startColor.min.a));
			startColor.set("maxA", Std.string(gravityPreset.startColor.max.a));
			
			endColor.set("minR", Std.string(gravityPreset.endColor.min.r));
			endColor.set("maxR", Std.string(gravityPreset.endColor.max.r));
			endColor.set("minG", Std.string(gravityPreset.endColor.min.g));
			endColor.set("maxG", Std.string(gravityPreset.endColor.max.g));
			endColor.set("minB", Std.string(gravityPreset.endColor.min.b));
			endColor.set("maxB", Std.string(gravityPreset.endColor.max.b));
			endColor.set("minA", Std.string(gravityPreset.endColor.min.a));
			endColor.set("maxA", Std.string(gravityPreset.endColor.max.a));
			
			startScale.set("min", Std.string(gravityPreset.startScale.min));
			startScale.set("max", Std.string(gravityPreset.startScale.max));
			
			endScale.set("min", Std.string(gravityPreset.endScale.min));
			endScale.set("max", Std.string(gravityPreset.endScale.max));
			
			rotation.set("minX", Std.string(gravityPreset.startRotation.min.x));
			rotation.set("maxX", Std.string(gravityPreset.startRotation.max.x));
			rotation.set("minY", Std.string(gravityPreset.startRotation.min.y));
			rotation.set("maxY", Std.string(gravityPreset.startRotation.max.y));
			rotation.set("minZ", Std.string(gravityPreset.startRotation.min.z));
			rotation.set("maxZ", Std.string(gravityPreset.startRotation.max.z));
			
			var startPosition:Xml = Xml.createElement("startPosition");
			startPosition.set("minX", Std.string(gravityPreset.startPosition.min.x));
			startPosition.set("maxX", Std.string(gravityPreset.startPosition.max.x));
			startPosition.set("minY", Std.string(gravityPreset.startPosition.min.y));
			startPosition.set("maxY", Std.string(gravityPreset.startPosition.max.y));
			startPosition.set("minZ", Std.string(gravityPreset.startPosition.min.z));
			startPosition.set("maxZ", Std.string(gravityPreset.startPosition.max.z));
			config.addChild(startPosition);
			
			var startVelocity:Xml = Xml.createElement("startVelocity");
			startVelocity.set("minX", Std.string(gravityPreset.velocity.min.x));
			startVelocity.set("maxX", Std.string(gravityPreset.velocity.max.x));
			startVelocity.set("minY", Std.string(gravityPreset.velocity.min.y));
			startVelocity.set("maxY", Std.string(gravityPreset.velocity.max.y));
			startVelocity.set("minZ", Std.string(gravityPreset.velocity.min.z));
			startVelocity.set("maxZ", Std.string(gravityPreset.velocity.max.z));
			config.addChild(startVelocity);
			
			var gravity:Xml = Xml.createElement("gravity");
			gravity.set("x", Std.string(gravityPreset.gravity.x));
			gravity.set("y", Std.string(gravityPreset.gravity.y));
			gravity.set("z", Std.string(gravityPreset.gravity.z));
			config.addChild(gravity);
		}
		else
		{
			var radialPreset:RadialParticlePreset = cast(preset, RadialParticlePreset);
			
			startColor.set("minR", Std.string(radialPreset.startColor.min.r));
			startColor.set("maxR", Std.string(radialPreset.startColor.max.r));
			startColor.set("minG", Std.string(radialPreset.startColor.min.g));
			startColor.set("maxG", Std.string(radialPreset.startColor.max.g));
			startColor.set("minB", Std.string(radialPreset.startColor.min.b));
			startColor.set("maxB", Std.string(radialPreset.startColor.max.b));
			startColor.set("minA", Std.string(radialPreset.startColor.min.a));
			startColor.set("maxA", Std.string(radialPreset.startColor.max.a));
			
			endColor.set("minR", Std.string(radialPreset.endColor.min.r));
			endColor.set("maxR", Std.string(radialPreset.endColor.max.r));
			endColor.set("minG", Std.string(radialPreset.endColor.min.g));
			endColor.set("maxG", Std.string(radialPreset.endColor.max.g));
			endColor.set("minB", Std.string(radialPreset.endColor.min.b));
			endColor.set("maxB", Std.string(radialPreset.endColor.max.b));
			endColor.set("minA", Std.string(radialPreset.endColor.min.a));
			endColor.set("maxA", Std.string(radialPreset.endColor.max.a));
			
			startScale.set("min", Std.string(radialPreset.startScale.min));
			startScale.set("max", Std.string(radialPreset.startScale.max));
			
			endScale.set("min", Std.string(radialPreset.endScale.min));
			endScale.set("max", Std.string(radialPreset.endScale.max));
			
			rotation.set("minX", Std.string(radialPreset.startRotation.min.x));
			rotation.set("maxX", Std.string(radialPreset.startRotation.max.x));
			rotation.set("minY", Std.string(radialPreset.startRotation.min.y));
			rotation.set("maxY", Std.string(radialPreset.startRotation.max.y));
			rotation.set("minZ", Std.string(radialPreset.startRotation.min.z));
			rotation.set("maxZ", Std.string(radialPreset.startRotation.max.z));
			
			var startAngle:Xml = Xml.createElement("startAngle");
			startAngle.set("min", Std.string(radialPreset.startAngle.min));
			startAngle.set("max", Std.string(radialPreset.startAngle.max));
			config.addChild(startAngle);
			
			var angleSpeed:Xml = Xml.createElement("angleSpeed");
			angleSpeed.set("min", Std.string(radialPreset.angleSpeed.min));
			angleSpeed.set("max", Std.string(radialPreset.angleSpeed.max));
			config.addChild(angleSpeed);
			
			var startDepth:Xml = Xml.createElement("startDepth");
			startDepth.set("min", Std.string(radialPreset.startDepth.min));
			startDepth.set("max", Std.string(radialPreset.startDepth.max));
			config.addChild(startDepth);
			
			var depthSpeed:Xml = Xml.createElement("depthSpeed");
			depthSpeed.set("min", Std.string(radialPreset.depthSpeed.min));
			depthSpeed.set("max", Std.string(radialPreset.depthSpeed.max));
			config.addChild(depthSpeed);
			
			var startRadius:Xml = Xml.createElement("startRadius");
			startRadius.set("min", Std.string(radialPreset.startRadius.min));
			startRadius.set("max", Std.string(radialPreset.startRadius.max));
			config.addChild(startRadius);
			
			var endRadius:Xml = Xml.createElement("endRadius");
			endRadius.set("min", Std.string(radialPreset.endRadius.min));
			endRadius.set("max", Std.string(radialPreset.endRadius.max));
			config.addChild(endRadius);
		}
		
		config.addChild(startColor);
		config.addChild(endColor);
		config.addChild(startScale);
		config.addChild(endScale);
		config.addChild(rotation);
		
		return config;
	}
	
	public static function parseXml(xml:Xml):ParticleSystem2D
	{
		var type:String = "";
		
		for (node in xml.elements())
		{
			if (node.nodeName == "particleEmitterConfig")
			{
				for (nodeChild in node.elements())
				{
					if (nodeChild.nodeName == "type")
					{
						type = nodeChild.get("value");
						break;
					}
				}
			}
			
		}
		
		var preset:ParticlePresetBase = null;
		
		var blendSrc:Context3DBlendFactor = null;
		var blendDst:Context3DBlendFactor = null;
		
		var lifeMin:Float = 0;
		var lifeMax:Float = 0;
		
		var particleNum:UInt = 0;
		var spawnNum:UInt = 0;
		var spawnStep:Float = 0;
		
		var startColorMin:Color = new Color();
		var startColorMax:Color = new Color();
		var endColorMin:Color = new Color();
		var endColorMax:Color = new Color();
		
		var startScaleMin:Float = 0;
		var startScaleMax:Float = 0;
		var endScaleMin:Float = 0;
		var endScaleMax:Float = 0;
		
		var rotationMin:Vector3D = new Vector3D();
		var rotationMax:Vector3D = new Vector3D();
		
		for (node in xml.elements())
		{
			if (node.nodeName == "particleEmitterConfig")
			{
				for (nodeChild in node.elements())
				{
					if (nodeChild.nodeName == "blend")
					{
						blendSrc = stringToBlendFactor(nodeChild.get("source"));
						blendDst = stringToBlendFactor(nodeChild.get("destination"));
					}
					else if (nodeChild.nodeName == "life")
					{
						lifeMin = Std.parseFloat(nodeChild.get("min"));
						lifeMax = Std.parseFloat(nodeChild.get("max"));
					}
					else if (nodeChild.nodeName == "particleNum")
					{
						particleNum = cast(Std.parseInt(nodeChild.get("value")), UInt);
					}
					else if (nodeChild.nodeName == "spawnNum")
					{
						spawnNum = cast(Std.parseInt(nodeChild.get("value")), UInt);
					}
					else if (nodeChild.nodeName == "spawnStep")
					{
						spawnStep = Std.parseFloat(nodeChild.get("value"));
					}
					else if (nodeChild.nodeName == "startColor")
					{
						startColorMin.r = Std.parseFloat(nodeChild.get("minR"));
						startColorMin.g = Std.parseFloat(nodeChild.get("minG"));
						startColorMin.b = Std.parseFloat(nodeChild.get("minB"));
						startColorMin.a = Std.parseFloat(nodeChild.get("minA"));
						
						startColorMax.r = Std.parseFloat(nodeChild.get("maxR"));
						startColorMax.g = Std.parseFloat(nodeChild.get("maxG"));
						startColorMax.b = Std.parseFloat(nodeChild.get("maxB"));
						startColorMax.a = Std.parseFloat(nodeChild.get("maxA"));
					}
					else if (nodeChild.nodeName == "endColor")
					{
						endColorMin.r = Std.parseFloat(nodeChild.get("minR"));
						endColorMin.g = Std.parseFloat(nodeChild.get("minG"));
						endColorMin.b = Std.parseFloat(nodeChild.get("minB"));
						endColorMin.a = Std.parseFloat(nodeChild.get("minA"));
						
						endColorMax.r = Std.parseFloat(nodeChild.get("maxR"));
						endColorMax.g = Std.parseFloat(nodeChild.get("maxG"));
						endColorMax.b = Std.parseFloat(nodeChild.get("maxB"));
						endColorMax.a = Std.parseFloat(nodeChild.get("maxA"));
					}
					else if (nodeChild.nodeName == "startScale")
					{
						startScaleMin = Std.parseFloat(nodeChild.get("min"));
						startScaleMax = Std.parseFloat(nodeChild.get("max"));
					}
					else if (nodeChild.nodeName == "endScale")
					{
						endScaleMin = Std.parseFloat(nodeChild.get("min"));
						endScaleMax = Std.parseFloat(nodeChild.get("max"));
					}
					else if (nodeChild.nodeName == "rotation")
					{
						rotationMin.x = Std.parseFloat(nodeChild.get("minX"));
						rotationMin.y = Std.parseFloat(nodeChild.get("minY"));
						rotationMin.z = Std.parseFloat(nodeChild.get("minZ"));
						
						rotationMax.x = Std.parseFloat(nodeChild.get("maxX"));
						rotationMax.y = Std.parseFloat(nodeChild.get("maxY"));
						rotationMax.z = Std.parseFloat(nodeChild.get("maxZ"));
					}
				}
			}
		}
		
		if (type == "gravity")
		{
			var gravityPreset:GravityParticlePreset = new GravityParticlePreset();
			
			var startPositionMin:Vector3D = new Vector3D();
			var startPositionMax:Vector3D = new Vector3D();
			var startVelocityMin:Vector3D = new Vector3D();
			var startVelocityMax:Vector3D = new Vector3D();
			var gravity:Vector3D = new Vector3D();
			
			for (node in xml.elements())
			{
				if (node.nodeName == "particleEmitterConfig")
				{
					for (nodeChild in node.elements())
					{
						if (nodeChild.nodeName == "startPosition")
						{
							startPositionMin.x = Std.parseFloat(nodeChild.get("minX"));
							startPositionMin.y = Std.parseFloat(nodeChild.get("minY"));
							startPositionMin.z = Std.parseFloat(nodeChild.get("minZ"));
							
							startPositionMax.x = Std.parseFloat(nodeChild.get("maxX"));
							startPositionMax.y = Std.parseFloat(nodeChild.get("maxY"));
							startPositionMax.z = Std.parseFloat(nodeChild.get("maxZ"));
						}
						else if (nodeChild.nodeName == "startVelocity")
						{
							startVelocityMin.x = Std.parseFloat(nodeChild.get("minX"));
							startVelocityMin.y = Std.parseFloat(nodeChild.get("minY"));
							startVelocityMin.z = Std.parseFloat(nodeChild.get("minZ"));
							
							startVelocityMax.x = Std.parseFloat(nodeChild.get("maxX"));
							startVelocityMax.y = Std.parseFloat(nodeChild.get("maxY"));
							startVelocityMax.z = Std.parseFloat(nodeChild.get("maxZ"));
						}
						else if (nodeChild.nodeName == "gravity")
						{
							gravity.x = Std.parseFloat(nodeChild.get("x"));
							gravity.y = Std.parseFloat(nodeChild.get("y"));
							gravity.z = Std.parseFloat(nodeChild.get("z"));
						}
					}
				}
			}
			
			gravityPreset.startPosition = new Bounds<Vector3D>(startPositionMin, startPositionMax);
			gravityPreset.velocity = new Bounds<Vector3D>(startVelocityMin, startVelocityMax);
			gravityPreset.gravity = gravity;
			
			gravityPreset.startColor = new Bounds<Color>(startColorMin, startColorMax);
			gravityPreset.endColor = new Bounds<Color>(endColorMin, endColorMax);
			gravityPreset.startScale = new Bounds<Float>(startScaleMin, startScaleMax);
			gravityPreset.endScale = new Bounds<Float>(endScaleMin, endScaleMax);
			gravityPreset.startRotation = new Bounds<Vector3D>(rotationMin, rotationMax);
			
			preset = gravityPreset;
		}
		else if (type == "radial")
		{
			var radialPreset:RadialParticlePreset = new RadialParticlePreset();
			
			var startAngleMin:Float = 0;
			var startAngleMax:Float = 0;
			
			var angleSpeedMin:Float = 0;
			var angleSpeedMax:Float = 0;
			
			var startDepthMin:Float = 0;
			var startDepthMax:Float = 0;
			
			var depthSpeedMin:Float = 0;
			var depthSpeedMax:Float = 0;
			
			var startRadiusMin:Float = 0;
			var startRadiusMax:Float = 0;
			
			var endRadiusMin:Float = 0;
			var endRadiusMax:Float = 0;
			
			for (node in xml.elements())
			{
				if (node.nodeName == "particleEmitterConfig")
				{
					for (nodeChild in node.elements())
					{
						if (nodeChild.nodeName == "startAngle")
						{
							startAngleMin = Std.parseFloat(nodeChild.get("min"));
							startAngleMax = Std.parseFloat(nodeChild.get("max"));
						}
						else if (nodeChild.nodeName == "angleSpeed")
						{
							angleSpeedMin = Std.parseFloat(nodeChild.get("min"));
							angleSpeedMax = Std.parseFloat(nodeChild.get("max"));
						}
						else if (nodeChild.nodeName == "startDepth")
						{
							startDepthMin = Std.parseFloat(nodeChild.get("min"));
							startDepthMax = Std.parseFloat(nodeChild.get("max"));
						}
						else if (nodeChild.nodeName == "depthSpeed")
						{
							depthSpeedMin = Std.parseFloat(nodeChild.get("min"));
							depthSpeedMax = Std.parseFloat(nodeChild.get("max"));
						}
						else if (nodeChild.nodeName == "startRadius")
						{
							startRadiusMin = Std.parseFloat(nodeChild.get("min"));
							startRadiusMax = Std.parseFloat(nodeChild.get("max"));
						}
						else if (nodeChild.nodeName == "endRadius")
						{
							endRadiusMin = Std.parseFloat(nodeChild.get("min"));
							endRadiusMax = Std.parseFloat(nodeChild.get("max"));
						}
					}
				}
			}	
			
			radialPreset.startAngle = new Bounds<Float>(startAngleMin, startAngleMax);
			radialPreset.angleSpeed = new Bounds<Float>(angleSpeedMin, angleSpeedMax);
			radialPreset.startDepth = new Bounds<Float>(startDepthMin, startDepthMax);
			radialPreset.depthSpeed = new Bounds<Float>(depthSpeedMin, depthSpeedMax);
			radialPreset.startRadius = new Bounds<Float>(startRadiusMin, startRadiusMax);
			radialPreset.endRadius = new Bounds<Float>(endRadiusMin, endRadiusMax);
			
			radialPreset.startColor = new Bounds<Color>(startColorMin, startColorMax);
			radialPreset.endColor = new Bounds<Color>(endColorMin, endColorMax);
			radialPreset.startScale = new Bounds<Float>(startScaleMin, startScaleMax);
			radialPreset.endScale = new Bounds<Float>(endScaleMin, endScaleMax);
			radialPreset.startRotation = new Bounds<Vector3D>(rotationMin, rotationMax);
			
			preset = radialPreset;
		}
		#if debug
		else
		{
			throw "Wrong file format";
		}
		#end
		preset.life = new Bounds<Float>(lifeMin, lifeMax);
		preset.particleNum = particleNum;
		preset.spawnNum = spawnNum;
		preset.spawnStep = spawnStep;
		
		var ps:ParticleSystem2D = null;
		if (type == "gravity")
		{
			ps = new ParticleSystem2D(GravityParticleRenderBuilder.gpuRender(cast(preset, GravityParticlePreset)));
		}
		else
		{
			ps = new ParticleSystem2D(RadialParticleRenderBuilder.gpuRender(cast(preset, RadialParticlePreset)));
		}
		
		ps.blendMode = new BlendMode(blendSrc, blendDst);
		return ps;
	}
	
	private static function blendFactorToString(blendFactor:Context3DBlendFactor):String
	{
		var str:String = "";
		switch (blendFactor)
		{
			case Context3DBlendFactor.ZERO:
				str = "ZERO";
			case Context3DBlendFactor.ONE:
				str = "ONE";
			case Context3DBlendFactor.SOURCE_COLOR:
				str = "SOURCE_COLOR";
			case Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR:
				str = "ONE_MINUS_SOURCE_COLOR";
			case Context3DBlendFactor.SOURCE_ALPHA:
				str = "SOURCE_ALPHA";
			case Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA:
				str = "ONE_MINUS_SOURCE_ALPHA";
			case Context3DBlendFactor.DESTINATION_ALPHA:
				str = "DESTINATION_ALPHA";
			case Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA:
				str = "ONE_MINUS_DESTINATION_ALPHA";
			case Context3DBlendFactor.DESTINATION_COLOR:
				str = "DESTINATION_COLOR";
			case Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR:
				str = "ONE_MINUS_DESTINATION_COLOR";
		}
		return str;
	}
	
	private static function stringToBlendFactor(str:String):Context3DBlendFactor
	{
		var blendFactor:Context3DBlendFactor = null;
		switch (str)
		{
			case "ZERO":
				blendFactor = Context3DBlendFactor.ZERO;
			case "ONE":
				blendFactor = Context3DBlendFactor.ONE;
			case "SOURCE_COLOR":
				blendFactor = Context3DBlendFactor.SOURCE_COLOR;
			case "ONE_MINUS_SOURCE_COLOR":
				blendFactor = Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR;
			case "SOURCE_ALPHA":
				blendFactor = Context3DBlendFactor.SOURCE_ALPHA;
			case "ONE_MINUS_SOURCE_ALPHA":
				blendFactor = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			case "DESTINATION_ALPHA":
				blendFactor = Context3DBlendFactor.DESTINATION_ALPHA;
			case "ONE_MINUS_DESTINATION_ALPHA":
				blendFactor = Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA;
			case "DESTINATION_COLOR":
				blendFactor = Context3DBlendFactor.DESTINATION_COLOR;
			case "ONE_MINUS_DESTINATION_COLOR":
				blendFactor = Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR;
		}
		return blendFactor;
	}
}