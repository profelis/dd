package deep.dd.texture.atlas;

import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.display3D.Context3D;
import deep.dd.texture.Texture2D;

class AtlasTexture2D extends SubTexture2D
{

    public var frames(default, null):Array<Frame>;

    public var frame(default, set_frame):Frame;

    public function new(texture:Texture2D, parser:IAtlasParser)
    {
        super(texture);

        frames = parser.parse(this);

        var s = parser.getPreferredSize();
        width = s.x;
        height = s.y;

        frame = frames[0];
    }

    public function getTextureById(id:Int):Texture2D
    {
        return getTextureByFrame(frames[id]);
    }

    public function getTextureByName(name:String):Texture2D
    {
        for (f in frames)
            if (f.name == name) return getTextureByFrame(f);

        return null;
    }

    public function getTextureByFrame(f:Frame):Texture2D
    {
        var res = new SubTexture2D(baseTexture);
        res.width = f.width;
        res.height = f.height;

        res.region = f.region;
        res.border = f.border;

        return res;
    }

    public function set_frame(f:Frame)
    {
        #if debug
        if (f == null) throw "frame is null";
        #end

        frame = f;
        width = f.width;
        height = f.height;

        region = f.region;
        border = f.border;

        return f;
    }

}

class Frame
{
    public var name:String;

    public var width:Float;
    public var height:Float;

    public var region:Vector3D;

    public var border:Rectangle;

    public function new (width, height, region, ?frame, ?name)
    {
        this.width = width;
        this.height = height;
        this.region = region;
        this.border = frame;
        this.name = name;
    }

    public function toString()
    {
        return "{Frame: " + width + ", " + height + (border != null ? ", " + border : "") + (name != null ? " ~ " + name : "") + "}";
    }
}

interface IAtlasParser
{
    function parse(a:AtlasTexture2D):Array<Frame>;

    function getPreferredSize():Point;
}

class SubTexture2D extends Texture2D
{
    function new (texture:Texture2D)
    {
        baseTexture = texture;
        super(baseTexture.options);

        bitmapWidth = baseTexture.bitmapWidth;
        bitmapHeight = baseTexture.bitmapHeight;
        textureWidth = baseTexture.textureWidth;
        textureHeight = baseTexture.textureHeight;

        width = baseTexture.width;
        height = baseTexture.height;

        region = baseTexture.region;

        border = baseTexture.border;

        baseTexture.useCount ++;
    }

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

    }
}
