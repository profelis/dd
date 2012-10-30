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
	public static function systemToXmlString(ps:ParticleSystem2D):String
	{
		var output:String = '<particleEmitterConfig>\n';
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
		
		output += '<type value="' + type + '"/>\n';
		output += '<life min="' + Std.string(preset.life.min) + '" max="' + Std.string(preset.life.max) + '"/>\n';
		output += '<particleNum value="' + Std.string(preset.particleNum) + '"/>\n';
		output += '<spawnNum value="' + Std.string(preset.spawnNum) + '"/>\n';
		output += '<spawnStep value="' + Std.string(preset.spawnStep) + '"/>\n';
		
		var src:String = blendFactorToString(ps.blendMode.src);
		var dst:String = blendFactorToString(ps.blendMode.dst);
		output += '<blend source="' + src + '" destination="' + dst + '"/>\n';
		
		var startColor:String = '<startColor ';
		var endColor:String = '<endColor ';
		var startScale:String = '<startScale ';
		var endScale:String = '<endScale ';
		var rotation:String = '<rotation ';
		
		if (type == "gravity")
		{
			var gravityPreset:GravityParticlePreset = cast(preset, GravityParticlePreset);
			
			startColor += 'minR="' + Std.string(gravityPreset.startColor.min.r) + '" ';
			startColor += 'maxR="' + Std.string(gravityPreset.startColor.max.r) + '" ';
			startColor += 'minG="' + Std.string(gravityPreset.startColor.min.g) + '" ';
			startColor += 'maxG="' + Std.string(gravityPreset.startColor.max.g) + '" ';
			startColor += 'minB="' + Std.string(gravityPreset.startColor.min.b) + '" ';
			startColor += 'maxB="' + Std.string(gravityPreset.startColor.max.b) + '" ';
			startColor += 'minA="' + Std.string(gravityPreset.startColor.min.a) + '" ';
			startColor += 'maxA="' + Std.string(gravityPreset.startColor.max.a) + '" ';
			
			endColor += 'minR="' + Std.string(gravityPreset.endColor.min.r) + '" ';
			endColor += 'maxR="' + Std.string(gravityPreset.endColor.max.r) + '" ';
			endColor += 'minG="' + Std.string(gravityPreset.endColor.min.g) + '" ';
			endColor += 'maxG="' + Std.string(gravityPreset.endColor.max.g) + '" ';
			endColor += 'minB="' + Std.string(gravityPreset.endColor.min.b) + '" ';
			endColor += 'maxB="' + Std.string(gravityPreset.endColor.max.b) + '" ';
			endColor += 'minA="' + Std.string(gravityPreset.endColor.min.a) + '" ';
			endColor += 'maxA="' + Std.string(gravityPreset.endColor.max.a) + '" ';
			
			startScale += 'min="' + Std.string(gravityPreset.startScale.min) + '" ';
			startScale += 'max="' + Std.string(gravityPreset.startScale.max) + '" ';
			
			endScale += 'min="' + Std.string(gravityPreset.endScale.min) + '" ';
			endScale += 'max="' + Std.string(gravityPreset.endScale.max) + '" ';
			
			rotation += 'minZ="' + Std.string(gravityPreset.startRotation.min) + '" ';
			rotation += 'maxZ="' + Std.string(gravityPreset.startRotation.max) + '" ';
			
			var startPosition:String = '<startPosition ';
			startPosition += 'minX="' + Std.string(gravityPreset.startPosition.min.x) + '" ';
			startPosition += 'maxX="' + Std.string(gravityPreset.startPosition.max.x) + '" ';
			startPosition += 'minY="' + Std.string(gravityPreset.startPosition.min.y) + '" ';
			startPosition += 'maxY="' + Std.string(gravityPreset.startPosition.max.y) + '" ';
			startPosition += 'minZ="' + Std.string(gravityPreset.startPosition.min.z) + '" ';
			startPosition += 'maxZ="' + Std.string(gravityPreset.startPosition.max.z) + '" ';
			startPosition += '/>\n';
			output += startPosition;
			
			var startVelocity:String = '<startVelocity ';
			startVelocity += 'minX="' + Std.string(gravityPreset.velocity.min.x) + '" ';
			startVelocity += 'maxX="' + Std.string(gravityPreset.velocity.max.x) + '" ';
			startVelocity += 'minY="' + Std.string(gravityPreset.velocity.min.y) + '" ';
			startVelocity += 'maxY="' + Std.string(gravityPreset.velocity.max.y) + '" ';
			startVelocity += 'minZ="' + Std.string(gravityPreset.velocity.min.z) + '" ';
			startVelocity += 'maxZ="' + Std.string(gravityPreset.velocity.max.z) + '" ';
			startVelocity += '/>\n';
			output += startVelocity;
			
			var gravity:String = '<gravity ';
			gravity += 'x="' + Std.string(gravityPreset.gravity.x) + '" ';
			gravity += 'y="' + Std.string(gravityPreset.gravity.y) + '" ';
			gravity += '/>\n';
			output += gravity;
		}
		else
		{
			var radialPreset:RadialParticlePreset = cast(preset, RadialParticlePreset);
			
			startColor += 'minR="' + Std.string(radialPreset.startColor.min.r) + '" ';
			startColor += 'maxR="' + Std.string(radialPreset.startColor.max.r) + '" ';
			startColor += 'minG="' + Std.string(radialPreset.startColor.min.g) + '" ';
			startColor += 'maxG="' + Std.string(radialPreset.startColor.max.g) + '" ';
			startColor += 'minB="' + Std.string(radialPreset.startColor.min.b) + '" ';
			startColor += 'maxB="' + Std.string(radialPreset.startColor.max.b) + '" ';
			startColor += 'minA="' + Std.string(radialPreset.startColor.min.a) + '" ';
			startColor += 'maxA="' + Std.string(radialPreset.startColor.max.a) + '" ';
			
			endColor += 'minR="' + Std.string(radialPreset.endColor.min.r) + '" ';
			endColor += 'maxR="' + Std.string(radialPreset.endColor.max.r) + '" ';
			endColor += 'minG="' + Std.string(radialPreset.endColor.min.g) + '" ';
			endColor += 'maxG="' + Std.string(radialPreset.endColor.max.g) + '" ';
			endColor += 'minB="' + Std.string(radialPreset.endColor.min.b) + '" ';
			endColor += 'maxB="' + Std.string(radialPreset.endColor.max.b) + '" ';
			endColor += 'minA="' + Std.string(radialPreset.endColor.min.a) + '" ';
			endColor += 'maxA="' + Std.string(radialPreset.endColor.max.a) + '" ';
			
			startScale += 'min="' + Std.string(radialPreset.startScale.min) + '" ';
			startScale += 'max="' + Std.string(radialPreset.startScale.max) + '" ';
			
			endScale += 'min="' + Std.string(radialPreset.endScale.min) + '" ';
			endScale += 'max="' + Std.string(radialPreset.endScale.max) + '" ';
			
			rotation += 'minZ="' + Std.string(radialPreset.startRotation.min) + '" ';
			rotation += 'maxZ="' + Std.string(radialPreset.startRotation.max) + '" ';
			
			output += '<startAngle min="' + Std.string(radialPreset.startAngle.min) + '" max="' + Std.string(radialPreset.startAngle.max) + '"/>\n';
			
			output += '<angleSpeed min="' + Std.string(radialPreset.angleSpeed.min) + '" max="' + Std.string(radialPreset.angleSpeed.max) + '"/>\n';
			
			output += '<startDepth min="' + Std.string(radialPreset.startDepth.min) + '" max="' + Std.string(radialPreset.startDepth.max) + '"/>\n';
			
			output += '<depthSpeed min="' + Std.string(radialPreset.depthSpeed.min) + '" max="' + Std.string(radialPreset.depthSpeed.max) + '"/>\n';
			
			output += '<startRadius min="' + Std.string(radialPreset.startRadius.min) + '" max="' + Std.string(radialPreset.startRadius.max) + '"/>\n';
			
			output += '<endRadius min="' + Std.string(radialPreset.endRadius.min) + '" max="' + Std.string(radialPreset.endRadius.max) + '"/>\n';
		}
		
		startColor += '/>\n';
		endColor += '/>\n';
		startScale += '/>\n';
		endScale += '/>\n';
		rotation += '/>\n';
		
		output += startColor;
		output += endColor;
		output += startScale;
		output += endScale;
		output += rotation;
		
		output += '</particleEmitterConfig>';
		return output;
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
	
}