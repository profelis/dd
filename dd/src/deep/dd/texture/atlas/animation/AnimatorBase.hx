package deep.dd.texture.atlas.animation;

import deep.dd.texture.atlas.AtlasTexture2D;

class AnimatorBase
{
    public var atlas:AtlasTexture2D;
	public var activeAnimation:Animation;

    // private constructor
    function new()
    {

    }

    public function draw(time:Float):Void
    {

    }
	
	public function playAnimation(name:String = null, startIdx:Int = 0, loop:Bool = true, restart:Bool = false):Void
	{
		
	}
	
	public function stop():Void
	{
		
	}
	
	public function nextFrame():Void
	{
		
	}
	
	public function prevFrame():Void
	{
		
	}
	
	public function gotoFrame(frame:Dynamic):Void
	{
		
	}

    public function copy():AnimatorBase
    {
        throw "not implemented";
        return null;
    }

    public function dispose():Void
    {
        atlas = null;
		activeAnimation = null;
    }
}
