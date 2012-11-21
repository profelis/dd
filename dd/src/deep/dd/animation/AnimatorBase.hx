package deep.dd.animation;

/**
* @author Dima Granetchi <system.grand@gmail.com>, <deep@e-citrus.ru>
*/

import deep.dd.utils.Frame;
import deep.dd.texture.Texture2D;
import deep.dd.texture.atlas.AtlasTexture2D;

/**
* Абстрактный аниматор
* Аниматоры перелистывают кадры заданого атласа
* @lang ru
**/
class AnimatorBase
{
    /**
    * Атлас, который будет использоваться в качестве текстуры
    * @lang ru
    **/
    public var atlas(default, set_atlas):AtlasTexture2D;

    /**
    * Текущий кадр анимации
    * @lang ru
    **/
    public var textureFrame(default, null):Frame;

    /**
    * @private
    **/
    function new() {}

    /**
    * Вызывается раз в кадр
    * Аниматор в этот момент обновляет кадр анимации или делает другие вычисления
    * @param time временная метка
    * @lang ru
    **/
    public function update(time:Float):Void {}

    /**
    * Клонирование аниматора
    * @lang ru
    **/
    public function copy():AnimatorBase
    {
        throw "not implemented";
        return null;
    }

    public function dispose():Void
    {
        Reflect.setField(this, "atlas", null);
        this.textureFrame = null;
    }

	function set_atlas(atl:AtlasTexture2D):AtlasTexture2D
	{
		atlas = atl;
		if (atl != null)
		{
			textureFrame = atl.frames[0];
		}
		return atl;
	}
}
