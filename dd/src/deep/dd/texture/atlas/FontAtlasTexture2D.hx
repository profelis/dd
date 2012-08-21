package deep.dd.texture.atlas;

import deep.dd.texture.Frame;
import deep.dd.texture.Texture2D;
import deep.dd.texture.atlas.AtlasTexture2D;

class FontAtlasTexture2D extends AtlasTexture2D
{
	public var spaceWidth:Int = 0;
	
	var glyphs:Hash<Frame>;

    public function new(texture:Texture2D, parser:IAtlasParser)
    {
        super(texture, parser);
		glyphs = new Hash<Frame>();
		for (f in frames)
		{
			glyphs.set(f.name, frame);
		}
    }
	
	
	override public function getTextureByName(name:String):Texture2D 
	{
		var f:Frame = glyphs.get(name);
		if (f != null)
		{
			return getTextureByFrame(f);
		}
		return null;
	}
	
	override public function dispose():Void 
	{
		glyphs = null;
		super.dispose();
	}

}