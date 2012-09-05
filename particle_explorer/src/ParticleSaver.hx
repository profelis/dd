package;

import deep.dd.particle.ParticleSystem2D;
import deep.dd.particle.preset.GravityParticlePreset;
import deep.dd.particle.preset.ParticlePresetBase;
import deep.dd.particle.preset.RadialParticlePreset;
import deep.dd.particle.render.ParticleRenderBase;

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
		var src:String = "";
		var dst:String = "";
		
		switch (ps.blendMode.src)
		{
			case Context3DBlendFactor.ZERO:
				src = "ZERO";
			case Context3DBlendFactor.ONE:
				src = "ONE";
			case Context3DBlendFactor.SOURCE_COLOR:
				src = "SOURCE_COLOR";
			case Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR:
				src = "ONE_MINUS_SOURCE_COLOR";
			case Context3DBlendFactor.SOURCE_ALPHA:
				src = "SOURCE_ALPHA";
			case Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA:
				src = "ONE_MINUS_SOURCE_ALPHA";
			case Context3DBlendFactor.DESTINATION_ALPHA:
				src = "DESTINATION_ALPHA";
			case Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA:
				src = "ONE_MINUS_DESTINATION_ALPHA";
			case Context3DBlendFactor.DESTINATION_COLOR:
				src = "DESTINATION_COLOR";
			case Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR:
				src = "ONE_MINUS_DESTINATION_COLOR";
		}
		
		switch (ps.blendMode.dst)
		{
			case Context3DBlendFactor.ZERO:
				dst = "ZERO";
			case Context3DBlendFactor.ONE:
				dst = "ONE";
			case Context3DBlendFactor.SOURCE_COLOR:
				dst = "SOURCE_COLOR";
			case Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR:
				dst = "ONE_MINUS_SOURCE_COLOR";
			case Context3DBlendFactor.SOURCE_ALPHA:
				dst = "SOURCE_ALPHA";
			case Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA:
				dst = "ONE_MINUS_SOURCE_ALPHA";
			case Context3DBlendFactor.DESTINATION_ALPHA:
				dst = "DESTINATION_ALPHA";
			case Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA:
				dst = "ONE_MINUS_DESTINATION_ALPHA";
			case Context3DBlendFactor.DESTINATION_COLOR:
				dst = "DESTINATION_COLOR";
			case Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR:
				dst = "ONE_MINUS_DESTINATION_COLOR";
		}
		
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
	
	/*public static function parseXml(xml:Xml):ParticleSystem2D
	{
		
	}*/
}