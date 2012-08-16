package deep.dd.texture.atlas.animation;

import deep.dd.texture.atlas.AtlasTexture2D;
import deep.dd.display.MovieClip2D;
import deep.dd.display.Sprite2D;

class Animator extends AnimatorBase
{
    public var fps:UInt = 30;
	
	public var loop:Bool = true;

    var frameTime:Float = 0;
    var currentFrame:Int = -1;

    var prevTime:Float = 0;

    public function new(fps:UInt = 30)
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

            var atlas = cast(sprite.texture, AtlasTexture2D);
			// TODO: take loop value into account
			if (activeAnimation != null)
			{
				currentFrame = (currentFrame + 1) % activeAnimation.frames.length;
			}
			else
			{
				currentFrame = (currentFrame + 1) % atlas.frames.length;
			}
            atlas.frame = atlas.frames[currentFrame];
        }
    }
	
	/**
	 * Analogue of gotoAndPlay() method of native MovieClip class
	 * @param	name		name of animation to play. If null then MovieClip2D will play all frames in its texture
	 * @param	startIdx	start index in animation to play
	 * @param	loop		set looping of animation. If true then animation will be repeating all the time
	 * @param	restart		this parameter will force animation to restart
	 */
	override public function playAnimation(name:String, startIdx:Int = 0, loop:Bool = true, restart:Bool = false):Void
	{
		var atlas:AtlasTexture2D = cast(sprite.texture, AtlasTexture2D);
		
		if (name == null) 
		{
			activeAnimation = null;
			#if debug
			if (atlas.frames.length <= startIdx)
			{
				throw "Number of frames in this AtlasTexture2D objects is less or equal to startIdx parameter";
			}
			#end
			if (restart) currentFrame = startIdx - 1;
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
			currentFrame = startIdx - 1;
			activeAnimation = anim;
			this.loop = loop;
		}
	}
	
	// TODO: current frame getter
	// TODO: current frame label getter
	// TODO: isPlaying
	// TODO: totalFrames or currentAnimationFrames (or both)
	// TODO: stop()
	// TODO: nextFrame()
	// TODO: prevFrame()
	// TODO: gotoFrame() (analogue of gotoAndStop())
	// TODO: need to set animation to null

    override public function copy():AnimatorBase
    {
        var res = new Animator(fps);

        return res;
    }

}
