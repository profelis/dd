package deep.dd.texture.atlas;

import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.display3D.Context3D;
import deep.dd.texture.Texture2D;

class AtlasTexture2D extends Texture2D
{
    public var baseTexture(default, null):Texture2D;
    public var frames(default, null):Array<Frame>;

    public var currentFrame(default, null):Frame;

    public function new(texture:Texture2D, parser:IAtlasParser)
    {
        baseTexture = texture;
        super(baseTexture.options);

        bitmapWidth = baseTexture.bitmapWidth;
        bitmapHeight = baseTexture.bitmapHeight;
        textureWidth = baseTexture.textureWidth;
        textureHeight = baseTexture.textureHeight;

        needUpdate = true;

        frames = parser.parse(this);

        currentFrame = frames.length > 0 ? frames[0] : null;
        if (currentFrame != null)
        {
            region = currentFrame.region;
            frame = currentFrame.frame;

            width = frame.width;
            height = frame.height;
        }
    }

    override public function update(time:Float)
    {
        if (baseTexture.needUpdate) baseTexture.update(time);
    }

    override public function init(ctx:Context3D)
    {
        baseTexture.init(ctx);

        texture = baseTexture.texture;
    }

    override public function dispose():Void
    {
        if (useCount > 0) return;

        baseTexture.dispose();
    }
}

class Frame
{
    public var name:String;
    public var region:Vector3D;
    public var frame:Rectangle;

    public function new (region, ?frame, ?name)
    {
        this.region = region;
        this.frame = frame;
        this.name = name;
    }
}

interface IAtlasParser
{
    function parse(a:AtlasTexture2D):Array<Frame>;
}
