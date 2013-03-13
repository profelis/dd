package deep.dd.animation;

/**
*  @author Zaphod
*/

import deep.dd.utils.Frame;
import deep.dd.texture.Texture2D;

/**
* Утилитарный класс, хранит кадры анимации и ее название
* @lang ru
*/

class Animation 
{
    /**
    * Набор фреймов
    * @lang ru
    **/
	public var frames(default, null):Array<Frame>;

    /**
    * Кол-во фреймов
    * @lang ru
    **/
	public var numFrames(default, null):Int;

    /**
    * Имя анимации
    * @lang ru
    **/
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

    public function toString()
    {
        return '{Animation: $name numFrames:$numFrames}';
    }
}