package deep.dd.texture.atlas;

import deep.dd.animation.Animation;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.display3D.Context3D;
import deep.dd.texture.Texture2D;

class AtlasTexture2D extends SubTexture2D
{
    public var frames(default, null):Array<Frame>;

	var animationMap:Hash<Animation>;

    public function new(texture:Texture2D, parser:IAtlasParser)
    {
        super(texture);

        frames = parser.parse(this);

        var s = parser.getPreferredSize();
        width = s.x;
        height = s.y;

        frame = frames[0];
		
		animationMap = new Hash<Animation>();
    }

    public function getTextureById(id:Int):Texture2D
    {
        return getTextureByFrame(frames[id]);
    }

    public function getTextureByName(name:String):Texture2D
    {
        for (f in frames)
            if (f.name == name) return getTextureByFrame(f);

        return null;
    }

    public function getTextureByFrame(f:Frame):Texture2D
    {
        var res = new SubTexture2D(baseTexture);
        res.frame = f;

        return res;
    }

	public function addAnimation(name:String, keyFrames:Array<Dynamic>):Animation
	{
		#if debug
		if (animationMap.exists(name)) throw ("Animation " + name + "  already exist");
		#end
		
		var framesToAdd:Array<Frame> = [];
		var numFrames:Int = keyFrames.length;
		for (i in 0...(numFrames))
		{
			if (Std.is(keyFrames[i], Int))
			{
				framesToAdd.push(frames[keyFrames[i]]);
				#if debug
				if (frames[keyFrames[i]] == null) throw "There is no frame with " + keyFrames[i] + " index";
				#end
			}
			else
			{
				// we have a string key
				var frameFound:Bool = false;
				for (fr in frames)
				{
					if (fr.name == keyFrames[i])
					{
						framesToAdd.push(fr);
						frameFound = true;
					}
				}
				#if debug
				if (!frameFound) throw "There is no frame with " + keyFrames[i] + " name";
				#end
			}
		}
		
		var anim:Animation = new Animation(framesToAdd, name);
		animationMap.set(name, anim);
		return anim;
	}
	
	public function getAnimation(name:String):Animation
	{
		var anim:Animation = animationMap.get(name);
		if (anim != null) return anim;
		
		var animFrames:Array<Frame> = [];
		for (fr in frames)
		{
			if (StringTools.startsWith(fr.name, name)) animFrames.push(fr);
		}
		
		if (animFrames.length > 0)
		{
			AtlasTexture2D.sortPrefix = name;
			AtlasTexture2D.sortFramesInAnimation(animFrames);
			anim = new Animation(animFrames, name);
			animationMap.set(name, anim);
		}
		
		return anim;
	}
	
	static function sortFramesInAnimation(animFrames:Array<Frame>):Array<Frame>
	{
		animFrames.sort(AtlasTexture2D.frameSortFunction);
		return animFrames;
	}
	
	// I know that it is a bad practice to use such global variable, but it makes sorting a lot easier
	static var sortPrefix:String;
	
	static function frameSortFunction(frame1:Frame, frame2:Frame):Int
	{
		var num1:Int = Std.parseInt(StringTools.replace(frame1.name, AtlasTexture2D.sortPrefix, ""));
		var num2:Int = Std.parseInt(StringTools.replace(frame2.name, AtlasTexture2D.sortPrefix, ""));
		
		if (num1 > num2)
		{
			return 1;
		}
		else if (num2 > num1)
		{
			return -1;
		}
		
		return 0;
	}
	
	override public function dispose():Void 
	{
		super.dispose();
		
		for (anim in animationMap)
		{
			anim.dispose();
		}
		animationMap = null;
	}

}

interface IAtlasParser
{
    function parse(a:AtlasTexture2D):Array<Frame>;

    function getPreferredSize():Point;
}

class SubTexture2D extends Texture2D
{
    function new (texture:Texture2D)
    {
        baseTexture = texture;
        super(baseTexture.options);

        bitmapWidth = baseTexture.bitmapWidth;
        bitmapHeight = baseTexture.bitmapHeight;
        textureWidth = baseTexture.textureWidth;
        textureHeight = baseTexture.textureHeight;

        width = baseTexture.width;
        height = baseTexture.height;

        baseTexture.useCount ++;
    }

    public var baseTexture(default, null):Texture2D;

    override public function init(ctx:Context3D)
    {
        baseTexture.init(ctx);

        texture = baseTexture.texture;
    }

    override public function dispose():Void
    {
        if (useCount > 0) return;

        baseTexture.useCount --;
        baseTexture.dispose();

    }
}
