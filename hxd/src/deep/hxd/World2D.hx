package deep.hxd;
import deep.hxd.utils.Color;
import flash.display3D.Context3DRenderMode;
import deep.hxd.display.Scene2D;
import deep.hxd.camera.Camera2D;
import flash.display.Stage;
import flash.display3D.Context3D;
import flash.display3D.Context3DTriangleFace;
import flash.display3D.Context3DCompareMode;
import flash.display.Stage3D;
import flash.events.Event;
import flash.display.Sprite;
import flash.geom.Rectangle;

class World2D
{
    var _stageId:Int;
    var _context3DRenderMode:Context3DRenderMode;

    var stage:Stage;
    var st3d:Stage3D;
	
	var _bounds:Rectangle;
	var _needResize:Bool;
	public var bounds(default, set_bounds):Rectangle;
	
	var _antialiasing:UInt;
	public var antialiasing(get_antialiasing, set_antialiasing):UInt;

    public var ctx(default, null):Context3D;

    public var autoResize:Bool;
	
	public var x(get_x, set_x):Float;
	public var y(get_y, set_y):Float;
    public var width(get_width, set_width):Int;
    public var height(get_height, set_height):Int;

    public var pause:Bool;

    public var camera:Camera2D;
    public var scene(default, set_scene):Scene2D;

    public var bgColor:Color;

    public function new(context3DRenderMode:Context3DRenderMode, bounds:Rectangle = null, stageId:Int = 0)
    {
        _context3DRenderMode = context3DRenderMode;
        _stageId = stageId;

        pause = false;

        bgColor = new Color(255, 255, 255);

        camera = new Camera2D();

        stage = flash.Lib.current.stage;
		
		_bounds = (bounds != null) ? bounds : new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
        autoResize = (bounds == null);
		_needResize = true;
		_antialiasing = 2;
		
        st3d = stage.stage3Ds[_stageId];
        st3d.addEventListener(Event.CONTEXT3D_CREATE, onContext);

        st3d.requestContext3D(Std.string(_context3DRenderMode));
    }

    function onContext(_)
    {
        ctx = st3d.context3D;
        ctx.enableErrorChecking = true;

        scene.init(ctx);

        stage.addEventListener(Event.ENTER_FRAME, onRender);
        stage.addEventListener(Event.RESIZE, onResize);

        onResize();
    }

    function onResize(?_)
    {
       var w:Int, h:Int;
		if (autoResize)
        {
            w = Std.int(stage.stageWidth);
            h = Std.int(stage.stageHeight);
        }
		else
		{
			w = Std.int(_bounds.width);
			h = Std.int(_bounds.height);
		}
		
		st3d.x = _bounds.x;
		st3d.y = _bounds.y;
        camera.resize(w, h);
        ctx.configureBackBuffer(w, h, _antialiasing);
		_needResize = false;
    }

    function onRender(_)
    {
        if (pause) return;
		if (_needResize) onResize();

        camera.update();

        ctx.setCulling(Context3DTriangleFace.NONE);
        ctx.setDepthTest(false, Context3DCompareMode.ALWAYS);

        ctx.clear(bgColor.r, bgColor.g, bgColor.b, bgColor.a);

        scene.drawStep(camera);

        ctx.present();
    }

    function set_scene(s:Scene2D)
    {
        scene = s;
        Reflect.setProperty(scene, "world", this);
        return s;
    }
	
	function set_bounds(rect:Rectangle):Rectangle
	{
		if (rect.width <= 0 || rect.height <= 0)
		{
			return rect;
		}
		_bounds = rect;
		autoResize = false;
		_needResize = true;
		return rect;
	}
	
	function get_antialiasing():UInt
	{
		return _antialiasing;
	}
	
	function set_antialiasing(val:UInt):UInt
	{
		_needResize = (val != _antialiasing);
		_antialiasing = val;
		return val;
	}
	
	function get_x():Float
	{
		return _bounds.x;
	}
	
	function set_x(val:Float):Float
	{
		if (_bounds.x != val)
		{
			_bounds.x = val;
			_needResize = true;
		}
		return val;
	}
	
	function get_y():Float
	{
		return _bounds.y;
	}
	
	function set_y(val:Float):Float
	{
		if (_bounds.y != val)
		{
			_bounds.y = val;
			_needResize = true;
		}
		return val;
	}
	
	function get_width():Int
	{
		return Std.int(_bounds.width);
	}
	
	function set_width(val:Int):Int
	{
		if (val >= 0 && _bounds.width != val)
		{
			_bounds.width = val;
			_needResize = true;
			autoResize = false;
		}
		return val;
	}
	
	function get_height():Int
	{
		return Std.int(_bounds.height);
	}
	
	function set_height(val:Int):Int
	{
		if (val >= 0 && _bounds.height != val)
		{
			_bounds.height = val;
			_needResize = true;
			autoResize = false;
		}
		return val;
	}
}
