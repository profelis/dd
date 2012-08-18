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
	public var name:String;
	
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