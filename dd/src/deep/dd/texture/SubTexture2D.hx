package deep.dd.texture;
import flash.display3D.Context3D;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
/**
* Суб текстура.
 * Позволяет изменяя фрейм получить часть картинки, при этом повторно используя ресурсы базовой текстуры
* @lang ru
**/
class SubTexture2D extends Texture2D
{
    public function new (texture:Texture2D)
    {
        baseTexture = texture;
        super();

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
		
		texture = null;
		if (cache == null)
        {
            Reflect.setField(this, "frame", null);
        }
        ctx = null;

        if (baseTexture != null)
        {
            baseTexture.useCount --;
            baseTexture.dispose();
            baseTexture = null;
        }
    }
}
