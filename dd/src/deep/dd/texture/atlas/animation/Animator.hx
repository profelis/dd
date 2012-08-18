package deep.dd.texture.atlas.animation;

import deep.dd.texture.Texture2D;
import deep.dd.texture.atlas.AtlasTexture2D;
import deep.dd.display.MovieClip2D;

class Animator extends AnimatorBase
{
    public var fps:Float = 30;
	public var currentFrame(default, null):Int = 0;
	public var currentFrameLabel(get_currentFrameLabel, null):String;
	public var isPlaying(default, null):Bool = true;
	public var totalFrames(get_totalFrames, null):Int;
	public var currentAnimationFrames(get_currentAnimationFrames, null):Int;
	public var activeAnimation:Animation;
	
	var loop:Bool = true;

    var frameTime:Float = 0;
    var prevTime:Float = 0;

    public function new(fps:Float = 30)
    {
        super();
        this.fps = fps;
    }

    override public function draw(time:Float)
    {
        frameTime += fps * (time - prevTime);
        prevTime = time;
        if (frameTime > 1)
        {
            frameTime = 0;

			var numFrames:Int = currentAnimationFrames;
			var nextFrame:Int = currentFrame + 1;
			if (isPlaying)
			{
				if (loop || nextFrame < numFrames) 
				{
					currentFrame = nextFrame % numFrames;
					isPlaying = true;
				}
				else
				{
					isPlaying = false;
				}
			}
			
            frame = (activeAnimation != null) ? activeAnimation.frames[currentFrame] : atlas.frames[currentFrame];
        }
    }
	
	/**
	 * Analogue of gotoAndPlay() method of native MovieClip class
	 * @param	name		name of animation to play. If null then MovieClip2D will play all frames in its texture
	 * @param	startIdx	start index in animation to play
	 * @param	loop		set looping of animation. If true then animation will be repeating all the time
	 * @param	restart		this parameter will force animation to restart
	 */
	public function playAnimation(name:String = null, startIdx:Int = 0, loop:Bool = true, restart:Bool = false):Void
	{
		isPlaying = true;
		
		if (name == null) 
		{
			activeAnimation = null;
			#if debug
			if (atlas.frames.length <= startIdx)
			{
				throw "Number of frames in this AtlasTexture2D objects is less or equal to startIdx parameter";
			}
			#end
			if (restart) currentFrame = startIdx;
			this.loop = loop;
			return;
		}
		
		var anim:Animation = atlas.getAnimation(name);
		
		#if debug
		if (anim == null) 
		{
			throw "There is no " + name + " animation in current AtlasTexture2D object";
		}
		else if (anim.numFrames <= startIdx)
		{
			throw "Length of " + name + " animation is less or equal to startIdx parameter";
		}
		#end
		
		if (restart || activeAnimation != anim)
		{
			currentFrame = startIdx;
			activeAnimation = anim;
		}
		this.loop = loop;
	}
	
	public function stop():Void
	{
		if (currentFrame < 0) currentFrame = 0;
		isPlaying = false;
	}
	
	public function nextFrame():Void 
	{
		gotoFrame(currentFrame + 1);
	}
	
	public function prevFrame():Void 
	{
		gotoFrame(currentFrame - 1);
	}
	
	
	public function gotoFrame(frame:Dynamic):Void 
	{
		if (Std.is(frame, Int))
		{
			if (frame > 0 && frame < currentAnimationFrames) currentFrame = frame;
		}
		else
		{
			// Assume that frame is String
			var frames:Array<Frame> = (activeAnimation != null) ? activeAnimation.frames : atlas.frames;
			
			var frameFound:Bool = false;
			for (i in 0...(frames.length))
			{
				if (frames[i].name == frame)
				{
					frameFound = true;
					currentFrame = i;
				}
			}
			
			#if debug
			if (!frameFound) throw ("This animation doesn't contain frame " + frame);
			#end
		}

		stop();
	}
	
	function get_currentFrameLabel():String
	{
		return atlas.frames[currentFrame].name;
	}
	
	function get_totalFrames():Int
	{
		return atlas.frames.length;
	}
	
	function get_currentAnimationFrames():Int
	{
		if (activeAnimation != null)
		{
			return activeAnimation.frames.length;
		}
		
		return totalFrames;
	}
	
	override private function set_atlas(atl:AtlasTexture2D):AtlasTexture2D 
	{
		if (atl != null) activeAnimation = null;
		currentFrame = 0;
		loop = true;
		isPlaying = true;
		return super.set_atlas(atl);
	}

    override public function copy():AnimatorBase
    {
        var res:Animator = new Animator(fps);
		res.atlas = atlas;
		res.frame = frame;
		res.activeAnimation = activeAnimation;
		Reflect.setField(res, "currentFrame", currentFrame);
		Reflect.setField(res, "loop", loop);
		if (!isPlaying) res.stop();

        return res;
    }
	
	override public function dispose():Void 
	{
		super.dispose();
		activeAnimation = null;
	}

}
