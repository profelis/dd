package deep.dd.display.particle.preset.parser;

import flash.geom.Point;
import deep.dd.display.particle.ParticleSystem2D;
import deep.dd.display.particle.preset.GravityParticlePreset;
import deep.dd.display.particle.preset.ParticlePresetBase;
import deep.dd.display.particle.preset.RadialParticlePreset;
import deep.dd.utils.BlendMode;

import deep.dd.display.particle.render.GravityParticleRender;
import deep.dd.display.particle.render.RadialParticleRender;

import flash.display3D.Context3DBlendFactor;
import flash.geom.Vector3D;
import mt.m3d.Color;

/**
 * ...
 * @author Zaphod
 */
class ParticleParser
{
    public function new() {  }
	
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
		
		var rotationMin:Float = 0;
		var rotationMax:Float = 0;
		
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
                        rotationMin = Std.parseFloat(nodeChild.get("min"));
						rotationMax = Std.parseFloat(nodeChild.get("max"));
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
			var gravity:Point = new Point();
			
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

							startPositionMax.x = Std.parseFloat(nodeChild.get("maxX"));
							startPositionMax.y = Std.parseFloat(nodeChild.get("maxY"));
						}
						else if (nodeChild.nodeName == "startVelocity")
						{
							startVelocityMin.x = Std.parseFloat(nodeChild.get("minX"));
							startVelocityMin.y = Std.parseFloat(nodeChild.get("minY"));

							startVelocityMax.x = Std.parseFloat(nodeChild.get("maxX"));
							startVelocityMax.y = Std.parseFloat(nodeChild.get("maxY"));
						}
						else if (nodeChild.nodeName == "gravity")
						{
							gravity.x = Std.parseFloat(nodeChild.get("x"));
							gravity.y = Std.parseFloat(nodeChild.get("y"));
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
			gravityPreset.startRotation = new Bounds<Float>(rotationMin, rotationMax);
			
			preset = gravityPreset;
		}
		else if (type == "radial")
		{
			var radialPreset:RadialParticlePreset = new RadialParticlePreset();
			
			var startAngleMin:Float = 0;
			var startAngleMax:Float = 0;
			
			var angleSpeedMin:Float = 0;
			var angleSpeedMax:Float = 0;
			
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
			radialPreset.startRadius = new Bounds<Float>(startRadiusMin, startRadiusMax);
			radialPreset.endRadius = new Bounds<Float>(endRadiusMin, endRadiusMax);
			
			radialPreset.startColor = new Bounds<Color>(startColorMin, startColorMax);
			radialPreset.endColor = new Bounds<Color>(endColorMin, endColorMax);
			radialPreset.startScale = new Bounds<Float>(startScaleMin, startScaleMax);
			radialPreset.endScale = new Bounds<Float>(endScaleMin, endScaleMax);
			radialPreset.startRotation = new Bounds<Float>(rotationMin, rotationMax);
			
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
