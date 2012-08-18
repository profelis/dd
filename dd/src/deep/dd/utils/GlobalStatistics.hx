package deep.dd.utils;

import deep.dd.texture.Texture2D;
import flash.utils.TypedDictionary;
import flash.display3D.Context3D;

class GlobalStatistics
{
    public function new()
    {
    }

    static public var stats(default, null):TypedDictionary<Context3D, Stat> = new TypedDictionary();

    static public function freeContext(ctx:Context3D)
    {
        stats.delete(ctx);
    }

    static public function removeTexture(ctx:Context3D, text:Texture2D)
    {
        var s:Stat = stats.get(ctx);
        if (s != null)
        {
            s.textures --;
            s.texturesMemory -= text.memory;
        }
    }

    static public function addTexture(ctx:Context3D, text:Texture2D)
    {
        var s:Stat = stats.get(ctx);
        if (s == null) stats.set(ctx, s = new Stat());

        s.textures ++;
        s.texturesMemory += text.memory;
    }
}

class Stat
{
    public function new() {}

    public var textures:UInt = 0;
    public var texturesMemory:UInt = 0;

    public function toString()
    {
        return ["textures: ", textures, ", texturesMemory: ", texturesMemory / 1000, " kb"].join("");
    }
}
