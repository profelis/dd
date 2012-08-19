package tests;
import deep.dd.display.Scene2D;
import deep.dd.World2D;

/**
 * ...
 * @author Zaphod
 */

class Test extends Scene2D
{

	public function new(wrld:World2D) 
	{
		super();
		world = wrld;
		world.scene = this;
	}

}