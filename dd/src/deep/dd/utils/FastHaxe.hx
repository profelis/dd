package deep.dd.utils;


class FastHaxe
{

    inline static public function is<T>(v:Dynamic, c:Class<T>):Bool
    {
        return untyped __is__(v, c);
    }

}
