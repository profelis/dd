package deep.dd.display;

import deep.dd.animation.Animation;
import deep.dd.animation.Animator;
import deep.dd.animation.AnimatorBase;
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
	
	public var frameLabel(get_frameLabel, null):String;
	
	function get_frameLabel():String
	{
		return anim.frameLabel;
	}
	
	public var totalFrames(get_totalFrames, null):Int;
	
	function get_totalFrames():Int
	{
		return anim.totalFrames;
	}
	
	public var animationFrames(get_animationFrames, null):Int;
	
	function get_animationFrames():Int
	{
		return anim.animationFrames;
	}
	
	public var animationName(get_animationName, null):String;
	
	function get_animationName():String
	{
		return anim.animationName;
	}
	
	public var animationFrame(get_animationFrame, null):Int;
	
	function get_animationFrame():Int
	{
		return anim.frame;
	}
}
