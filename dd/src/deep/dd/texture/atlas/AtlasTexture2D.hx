package deep.dd.texture.atlas;

/**
*  @author Dima Granetchi <system.grand@gmail.com>, <deep@e-citrus.ru>
*  @author Zaphod
*/

import deep.dd.utils.Frame;
import deep.dd.animation.Animation;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.display3D.Context3D;
import deep.dd.texture.Texture2D;

/**
* Текстура, которая для рендера использует нарисованый в битмапу DisplayObject
* @lang ru
**/
class AtlasTexture2D extends SubTexture2D
{
    /**
    * Полный список кадров атласа
    * @lang ru
    **/
    public var frames(default, null):Array<Frame>;

    /**
    * Набор всех анимаций атласа
    * @lang ru
    **/
	public var animations(default, null):Hash<Animation>;

    public function new(texture:Texture2D, parser:IAtlasParser)
    {
        super(texture);

        frames = parser.parse(this);

        frame = frames[0];
		
		animations = new Hash<Animation>();
    }

    /**
    * Возвращает субтекстуру определенного фрейма по ее порядковому номеру
    * @lang ru
    **/
    public function getTextureById(id:Int):Texture2D
    {
        return getTextureByFrame(frames[id]);
    }

    /**
    * Возвращает субтекстуру фрейма по его id
    * @lang ru
    **/
    public function getTextureByName(name:String):Texture2D
    {
        for (f in frames)
            if (f.name == name) return getTextureByFrame(f);

        return null;
    }

    /**
    * Возвращает субтекстуру определенного фрейма
    * @lang ru
    **/
    public function getTextureByFrame(f:Frame):Texture2D
    {
        var res = new SubTexture2D(baseTexture);
        res.frame = f;

        return res;
    }

    /**
    * Добавляем анимацию в список анимаций
    * @lang ru
    **/
	public function addAnimation(name:String, keyFrames:Array<Dynamic>):Animation
	{
		#if debug
		if (animations.exists(name)) throw ("Animation " + name + "  already exist");
		#end
		
		var framesToAdd:Array<Frame> = [];
		var numFrames:Int = keyFrames.length;
		for (i in 0...(numFrames))
		{
			if (Std.is(keyFrames[i], Int))
			{
				framesToAdd.push(frames[keyFrames[i]]);
				#if debug
				if (frames[keyFrames[i]] == null) throw "There is no frame with " + keyFrames[i] + " index";
				#end
			}
			else
			{
				// we have a string key
				var frameFound:Bool = false;
				for (fr in frames)
				{
					if (fr.name == keyFrames[i])
					{
						framesToAdd.push(fr);
						frameFound = true;
					}
				}
				#if debug
				if (!frameFound) throw "There is no frame with " + keyFrames[i] + " name";
				#end
			}
		}
		
		var anim:Animation = new Animation(framesToAdd, name);
		animations.set(name, anim);
		return anim;
	}

    /**
    * Получить анимацию по имени и тут же добавить ее в список анимаций.
    * Если name = "run", то найдутся все кадры run0 run1 ... runN и отсортированы по возрастанию
    * @lang ru
    **/
	public function getAnimation(name:String):Animation
	{
		var anim:Animation = animations.get(name);
		if (anim != null) return anim;
		
		var animFrames:Array<Frame> = [];
		for (fr in frames)
		{
			if (StringTools.startsWith(fr.name, name)) animFrames.push(fr);
		}
		
		if (animFrames.length > 0)
		{
			AtlasTexture2D.sortPrefixLength = name.length;
			AtlasTexture2D.sortFramesInAnimation(animFrames);
			anim = new Animation(animFrames, name);
			animations.set(name, anim);
		}
		
		return anim;
	}
	
	static function sortFramesInAnimation(animFrames:Array<Frame>):Array<Frame>
	{
		animFrames.sort(AtlasTexture2D.frameSortFunction);
		return animFrames;
	}
	
	// I know that it is a bad practice to use such global variable, but it makes sorting a lot easier
	static var sortPrefixLength:Int;
	
	static function frameSortFunction(frame1:Frame, frame2:Frame):Int
	{
		var num1:Int = Std.parseInt(frame1.name.substr(0, AtlasTexture2D.sortPrefixLength));
		var num2:Int = Std.parseInt(frame2.name.substr(0, AtlasTexture2D.sortPrefixLength));
		
		if (num1 > num2)
		{
			return 1;
		}
		else if (num2 > num1)
		{
			return -1;
		}
		
		return 0;
	}
	
	override public function dispose():Void 
	{
		super.dispose();
		
		if (animations != null)
		{
			for (anim in animations)
			{
				anim.dispose();
			}
			animations = null;
		}
	}

}

/**
* Парсер атласной текстуры
* @lang ru
**/
interface IAtlasParser
{
    function parse(a:AtlasTexture2D):Array<Frame>;
}

/**
* Суб текстура.
 * Позволяет изменяя фрейм получить часть картинки, при этом повторно используя ресурсы базовой текстуры
* @lang ru
**/
class SubTexture2D extends Texture2D
{
    function new (texture:Texture2D)
    {
        baseTexture = texture;
        super(baseTexture.options);

        textureWidth = baseTexture.textureWidth;
        textureHeight = baseTexture.textureHeight;

        width = baseTexture.width;
        height = baseTexture.height;

        baseTexture.useCount ++;
    }

    /**
    * Ссылка на базовую текстуру
    * @lang ru
    **/
    public var baseTexture(default, null):Texture2D;

    override public function init(ctx:Context3D)
    {
        baseTexture.init(ctx);

        texture = baseTexture.texture;
    }

    override public function dispose():Void
    {
        if (useCount > 0) return;

        baseTexture.useCount --;
        baseTexture.dispose();
        baseTexture = null;
    }
}
