package ;

/**
 *  @author Dima Granetchi <system.grand@gmail.com>, <deep@e-citrus.ru>
 */

import haxe.macro.Context;
class TestMacro
{
    public function new()
    {
        
    }

	static public function main()
	{
		var t:Null<Bool> = null;
		test(t);
	}

	@:macro static function test(e)
	{
		trace(Context.typeof(e));
		trace(e);
		return e;
	}
}
