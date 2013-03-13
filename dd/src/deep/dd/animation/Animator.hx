package deep.dd.animation;

/**
*  @author Zaphod
*  @author Dima Granetchi <system.grand@gmail.com>, <deep@e-citrus.ru>
*/

import deep.dd.utils.Frame;
import deep.dd.utils.FastHaxe;
import deep.dd.texture.Texture2D;
import deep.dd.texture.atlas.AtlasTexture2D;
import deep.dd.display.MovieClip2D;

/**
* Базовый аниматор для MovieClip2D
* @lang ru
**/
class Animator extends AnimatorBase
{
    /**
    * фпс анимации
    * @lang ru
    **/
    public var fps:Float = 30;

    /**
    * Порядковый номер текущего фрейма
    * @lang ru
    **/
	public var frame(default, null):Int = 0;

    /**
    * Имя текущего кадра
    * @lang ru
    **/
	public var frameLabel(get_frameLabel, null):String;

    /**
    * Активна ли в этот момент анимация
    * @lang ru
    **/
	public var isPlaying(default, null):Bool = true;

    /**
    * Общее число кадров у атласа
    * @lang ru
    **/
	public var totalFrames(get_totalFrames, null):Int;

    /**
    * Кол-во кадров текущей анимации
    * @lang ru
    **/
	public var animationFrames(get_animationFrames, null):Int;

    /**
    * Имя текущей анимации
    * @lang ru
    **/
	public var animationName(get_animationName, null):String;

    /**
    * Текущая анимация
    * @lang ru
    **/
	var animation:Animation;

	var loop:Bool = true;

    var frameTime:Float = 0;
    var prevTime:Float = 0;

    public function new(fps:Float = 30)
    {
        super();
        this.fps = fps;
    }

    override public function update(time:Float)
    {
        frameTime += fps * (time - prevTime);
        prevTime = time;
        if (frameTime > 1)
        {
            frameTime = 0;

			var numFrames:Int = animationFrames;
			var nextFrame:Int = frame + 1;
			if (isPlaying)
			{
				if (loop || nextFrame < numFrames)
				{
					frame = nextFrame % numFrames;
					isPlaying = true;
				}
				else
				{
					isPlaying = false;
				}
			}

            textureFrame = (animation != null) ? animation.frames[frame] : atlas.frames[frame];
        }
    }

    /**
    * Метод аналогичен gotoAndPlay() нативной реализации MovieClip класса
    * @param	name		имя анимации, если имя не задано, то будут проигрываться все фреймы, начиная со startIdx
	* @param	startIdx	порядковый номер кадра, с которого начнется проигрываться анимация
	* @param	loop		проигрывать ли анимацию по кругу или всего один раз
	* @param	restart		заставит запустить анимацию с начала
	* @lang ru
    **/
	/**
	 * Analogue of gotoAndPlay() method of native MovieClip class
	 * @param	name		name of animation to play. If null then MovieClip2D will play all frames in its texture
	 * @param	startIdx	start index in animation to play
	 * @param	loop		set looping of animation. If true then animation will be repeating all the time
	 * @param	restart		this parameter will force animation to restart
	 * @lang en
	 */
	public function playAnimation(name:String = null, startIdx:Int = 0, loop:Bool = true, restart:Bool = false):Void
	{
		isPlaying = true;

		if (name == null)
		{
			animation = null;
			#if debug
			if (atlas.frames.length <= startIdx)
			{
				throw "Number of frames in this AtlasTexture2D objects is less or equal to startIdx parameter";
			}
			#end
			if (restart) frame = startIdx;
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

		if (restart || animation != anim)
		{
			frame = startIdx;
			animation = anim;
		}
		this.loop = loop;
	}

    /**
    * Остановить анимацию
    * @lang ru
    **/
	public function stop():Void
	{
		if (frame < 0) frame = 0;
		frameTime = 1;
		isPlaying = false;
	}

    /**
    * Проиграть следующий кадр
    * @lang ru
    **/
	public function nextFrame():Void
	{
		gotoFrame(frame + 1);
	}

    /**
    * Проиграть предущий кадр
    * @lang ru
    **/
	public function prevFrame():Void
	{
		gotoFrame(frame - 1);
	}

    /**
    * Перейти на определеный кадр
    * @param frame имя или название кадра
    * @lang ru
    **/
	public function gotoFrame(frame:Dynamic):Void
	{
		if (Std.is(frame, Int))
		{
			if (frame > 0 && frame < animationFrames) this.frame = frame;
		}
		else
		{
			// Assume that frame is String
			var frames:Array<Frame> = (animation != null) ? animation.frames : atlas.frames;

			var frameFound:Bool = false;
			for (i in 0...(frames.length))
			{
				if (frames[i].name == frame)
				{
					frameFound = true;
					this.frame = i;
					break;
				}
			}

			#if debug
			if (!frameFound) throw ("This animation doesn't contain frame " + frame);
			#end
		}

		stop();
	}

	function get_frameLabel():String
	{
		return atlas.frames[frame].name;
	}

	function get_totalFrames():Int
	{
		return atlas.frames.length;
	}

	function get_animationFrames():Int
	{
		return animation != null ? animation.frames.length : totalFrames;
	}

	function get_animationName():String
	{
		return animation != null ? animation.name : "";
	}

	override private function set_atlas(atl:AtlasTexture2D):AtlasTexture2D
	{
		if (atl != null) animation = null;
		frame = 0;
		loop = true;
		isPlaying = true;
		return super.set_atlas(atl);
	}

    override public function copy():AnimatorBase
    {
        var res:Animator = new Animator(fps);
		res.atlas = atlas;
		res.textureFrame = textureFrame;
		Reflect.setField(res, "animation", animation);
		Reflect.setField(res, "frame", frame);
		Reflect.setField(res, "loop", loop);
		if (!isPlaying) res.stop();

        return res;
    }

	override public function dispose():Void
	{
		super.dispose();
		animation = null;
	}

    public function toString()
    {
        return '{Animator: fps:$fps frame:$frame frameLabel:$frameLabel isPlaying:$isPlaying}';
    }
}