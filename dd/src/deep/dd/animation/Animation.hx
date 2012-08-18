package deep.dd.animation;

import deep.dd.texture.Frame;
import deep.dd.texture.Texture2D;
/**
 * ...
 * @author Zaphod
 */

class Animation 
{
	public var frames(default, null):Array<Frame>;
	public var numFrames(default, null):Int;
	public var name(default, null):String;
	
	public function new(frames:Array<Frame>, name:String) 
	{
		this.frames = frames;
		this.numFrames = frames.length;
		this.name = name;
	}
	
	public function dispose():Void
	{
		frames = null;
	}
	
}