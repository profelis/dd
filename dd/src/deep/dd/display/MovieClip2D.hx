package deep.dd.display;

import deep.dd.texture.atlas.animation.Animation;
import deep.dd.texture.atlas.animation.Animator;
import deep.dd.texture.atlas.animation.AnimatorBase;
import deep.dd.camera.Camera2D;
import deep.dd.geometry.Geometry;
import deep.dd.texture.atlas.AtlasTexture2D;

class MovieClip2D extends Sprite2D
{
    var anim:Animator;

    public function new()
    {
        super();
        animator = anim = new Animator();
    }

    override function set_animator(v)
    {
        #if debug
        if (!Std.is(v, Animator)) throw "animator must be Animator instance";
        #end
        anim = cast v;
        return super.set_animator(v);
    }
	
	public function addAnimation(name:String, keyFrames:Array<Dynamic>):Animation
	{
		return cast(texture, AtlasTexture2D).addAnimation(name, keyFrames);
	}
	
	public function playAnimation(name:String = null, startIdx:Int = 0, loop:Bool = true, restart:Bool = false):Void
	{
		anim.playAnimation(name, startIdx, loop, restart);
	}
	
	public function stop():Void
	{
		anim.stop();
	}
	
	public function nextFrame():Void 
	{
		anim.nextFrame();
	}
	
	public function prevFrame():Void 
	{
		anim.prevFrame();
	}
	
	public function gotoFrame(frame:Dynamic):Void 
	{
		anim.gotoFrame(frame);
	}
	
	override public function dispose():Void 
	{
		super.dispose();
		anim = null;
	}

    public var fps(default, set_fps):Float;

    function set_fps(v)
    {
        return anim.fps = fps = v;
    }
	
	public var currentFrameLabel(get_currentFrameLabel, null):String;
	
	function get_currentFrameLabel():String
	{
		return anim.currentFrameLabel;
	}
	
	public var totalFrames(get_totalFrames, null):Int;
	
	function get_totalFrames():Int
	{
		return anim.totalFrames;
	}
	
	public var currentAnimationFrames(get_currentAnimationFrames, null):Int;
	
	function get_currentAnimationFrames():Int
	{
		return anim.currentAnimationFrames;
	}
	
	public var activeAnimationName(get_activeAnimationName, null):String;
	
	function get_activeAnimationName():String
	{
		return anim.activeAnimationName;
	}
	
	public var currentFrame(get_currentFrame, null):Int;
	
	function get_currentFrame():Int
	{
		return anim.currentFrame;
	}
}
