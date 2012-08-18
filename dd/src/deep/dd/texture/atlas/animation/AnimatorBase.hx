package deep.dd.texture.atlas.animation;

import deep.dd.texture.Texture2D;
import deep.dd.texture.atlas.AtlasTexture2D;

class AnimatorBase
{
    public var atlas(default, set_atlas):AtlasTexture2D;

    // override default texture2d frame
    public var frame(default, null):Frame;

    // private constructor
    function new()
    {

    }

    public function draw(time:Float):Void
    {

    }

    public function copy():AnimatorBase
    {
        throw "not implemented";
        return null;
    }

    public function dispose():Void
    {
        Reflect.setField(this, "atlas", null);
    }
	
	function set_atlas(atl:AtlasTexture2D):AtlasTexture2D
	{
		atlas = atl;
		if (atl != null)
		{
			frame = atl.frames[0];
		}
		return atl;
	}
}
