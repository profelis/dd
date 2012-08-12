package deep.hxd;
import deep.hxd.utils.Cache;
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
    public var stageId(default, null):Int;

    public var context3DRenderMode(default, null):Context3DRenderMode;

    var stage:Stage;
    var st3d:Stage3D;

    public var ctx(default, null):Context3D;

    public var autoResize(default, null):Bool;
	public var bounds(default, set_bounds):Rectangle;
    var invalidateSize:Bool = true;

	public var antialiasing(default, set_antialiasing):UInt;

	public var x(get_x, set_x):Float;
	public var y(get_y, set_y):Float;
    public var width(get_width, set_width):Int;
    public var height(get_height, set_height):Int;

    public var pause:Bool = false;

    public var camera:Camera2D;
    public var scene(default, set_scene):Scene2D;

    public var bgColor:Color;

    public var cache(default, null):Cache;

    public function new(context3DRenderMode:Context3DRenderMode, bounds:Rectangle = null, antialiasing:Int = 2, stageId:Int = 0)
    {
        stage = flash.Lib.current.stage;

        this.context3DRenderMode = context3DRenderMode;
        this.bounds =  bounds;
        this.antialiasing = antialiasing;
        this.stageId = stageId;

        cache = new Cache(this);

        bgColor = new Color(1, 1, 1);

        camera = new Camera2D();

        st3d = stage.stage3Ds[stageId];
        st3d.addEventListener(Event.CONTEXT3D_CREATE, onContext);
        st3d.requestContext3D(Std.string(context3DRenderMode));
    }

    function onContext(_)
    {
        ctx = st3d.context3D;
		
		#if debug
        ctx.enableErrorChecking = true;
		#end

        scene.init(ctx);

        stage.addEventListener(Event.ENTER_FRAME, onRender);
        stage.addEventListener(Event.RESIZE, onResize);

        onResize();
    }

    function onResize(?_)
    {
		if (autoResize)
        {
            bounds.width = Std.int(stage.stageWidth);
            bounds.height = Std.int(stage.stageHeight);
            invalidateSize = true;
        }
    }

    function updateSize()
    {
        var w = Std.int(bounds.width);
        var h = Std.int(bounds.height);
        st3d.x = bounds.x;
        st3d.y = bounds.y;
        camera.resize(w, h);
        ctx.configureBackBuffer(w, h, antialiasing);
        invalidateSize = false;
    }

    function onRender(_)
    {
        if (pause) return;
		if (invalidateSize) updateSize();

        if (camera.needUpdate) camera.update();

        ctx.setCulling(Context3DTriangleFace.NONE);
        ctx.setDepthTest(false, Context3DCompareMode.ALWAYS);

        ctx.clear(bgColor.r, bgColor.g, bgColor.b, bgColor.a);

        scene.drawStep(camera);

        ctx.present();
    }
	
	function dispose(disposeContext3D:Bool = true):Void
	{
		st3d.removeEventListener(Event.CONTEXT3D_CREATE, onContext);
		stage.removeEventListener(Event.ENTER_FRAME, onRender);
        stage.removeEventListener(Event.RESIZE, onResize);
		
        if (camera != null)
        {
            camera.dispose();
		    camera = null;
        }
		if (scene != null)
        {
            scene.dispose();
		    scene = null;
        }

        context3DRenderMode = null;
        bgColor = null;
		stage = null;
		st3d = null;

        if (disposeContext3D) ctx.dispose();
        ctx = null;

        Reflect.setField(this, "bounds", null);
	}

    function set_scene(s:Scene2D)
    {
        if (scene != null)
        {
            Reflect.setProperty(scene, "world", null);
        }
        scene = s;
        if (scene != null)
        {
            Reflect.setProperty(scene, "world", this);
        }
        return s;
    }

    function set_antialiasing(val:UInt):UInt
    {
        invalidateSize = (val != antialiasing);
        antialiasing = val;
        return val;
    }

	function set_bounds(rect:Rectangle):Rectangle
	{
		#if debug
		if (rect != null)
		{
            if (rect.width <= 0) throw "bounds.width < 0";
            if (rect.height <= 0) throw "bounds.height < 0";
        }
        #end

		bounds = rect != null ? rect : new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
        autoResize = (rect == null);
		invalidateSize = true;
		return bounds;
	}
	
	function get_x():Float
	{
		return bounds.x;
	}
	
	function set_x(val:Float):Float
	{
		if (bounds.x != val)
		{
			bounds.x = val;
			invalidateSize = true;
		}
		return val;
	}
	
	function get_y():Float
	{
		return bounds.y;
	}
	
	function set_y(val:Float):Float
	{
		if (bounds.y != val)
		{
			bounds.y = val;
			invalidateSize = true;
		}
		return val;
	}
	
	function get_width():Int
	{
		return Std.int(bounds.width);
	}
	
	function set_width(val:Int):Int
	{
        #if debug
        if (val < 0) throw "width < 0";
        #end
		if (bounds.width != val)
		{
			bounds.width = val;
			invalidateSize = true;
			autoResize = false;
		}
		return val;
	}
	
	function get_height():Int
	{
		return Std.int(bounds.height);
	}
	
	function set_height(val:Int):Int
	{
        #if debug
        if (val < 0) throw "height < 0";
        #end
		if (bounds.height != val)
		{
			bounds.height = val;
			invalidateSize = true;
			autoResize = false;
		}
		return val;
	}
}
