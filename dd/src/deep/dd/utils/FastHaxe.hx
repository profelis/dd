package deep.dd.utils;


class FastHaxe
{
    
    inline static public function is<T>(v:Dynamic, c:Class<T>):Bool
    {
		#if flash9
        return untyped __is__(v, c);
		#else
		return Std.is(v, c);
		#end
    }
    
}
