package deep.dd.texture.atlas.animation;

import deep.dd.texture.Texture2D;
/**
 * ...
 * @author Zaphod
 */

class Animation 
{
	public var frames:Array<Frame>;
	public var numFrames:Int;
	
	public function new(frames:Array<Frame>) 
	{
		this.frames = frames;
		this.numFrames = frames.length;
	}
	
	public function dispose():Void
	{
		frames = null;
	}
	
}