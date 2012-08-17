package deep.dd.texture.atlas;

import deep.dd.texture.atlas.animation.Animation;
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

	public function addAnimation(name:String, keyFrames:Array<Dynamic>):Void
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
				// we have string key
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
		
		animationMap.set(name, new Animation(framesToAdd));
	}
	
	public function getAnimation(name:String):Animation
	{
		return animationMap.get(name);
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
