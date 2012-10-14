package deep.dd;

import msignal.Signal.Signal2;
import deep.dd.utils.MouseData;
import deep.dd.display.Node2D;
import flash.events.TouchEvent;
import flash.geom.Vector3D;
import flash.events.MouseEvent;
import deep.dd.utils.GlobalStatistics;
import deep.dd.utils.Statistics;
import deep.dd.material.Material;
import deep.dd.utils.Cache;
import mt.m3d.Color;
import deep.dd.display.Scene2D;
import deep.dd.camera.Camera2D;
import flash.display.Stage;
import flash.display3D.Context3D;
import flash.display3D.Context3DRenderMode;
import flash.display3D.Context3DTriangleFace;
import flash.display3D.Context3DCompareMode;
import flash.display.Stage3D;
import flash.events.Event;
import flash.geom.Rectangle;

class World2D
{
    public var stageId(default, null):Int;

    public var context3DRenderMode(default, null):Context3DRenderMode;

    public var stage(default, null):Stage;
    public var stage3d(default, null):Stage3D;

    public var ctx(default, null):Context3D;
    public var isHW(default, null):Bool = false;

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

    public var statistics(default, null):Statistics;

    public var onResize:Signal2<Int, Int>;

    public function new(context3DRenderMode:Context3DRenderMode, bounds:Rectangle = null, antialiasing:Int = 2, stageId:Int = 0)
    {
        stage = flash.Lib.current.stage;

        this.context3DRenderMode = context3DRenderMode;
        this.bounds =  bounds;
        this.antialiasing = antialiasing;
        this.stageId = stageId;

        onResize = new Signal2<Int, Int>();

        cache = new Cache(this);
        #if dd_stat
        statistics = new Statistics(this);
        #end

        bgColor = new Color(1, 1, 1);

        camera = new Camera2D();

        stage.addEventListener(Event.RESIZE, onResizeHandler);

        stage3d = stage.stage3Ds[stageId];
        stage3d.addEventListener(Event.CONTEXT3D_CREATE, onContext);

        if (stage3d.context3D != null && stage3d.context3D.driverInfo != "Disposed") onContext(null);
        else stage3d.requestContext3D(Std.string(context3DRenderMode));
    }

    function onContext(_)
    {
        if (ctx == stage3d.context3D) return;

        if (ctx != null)
        {
            Material.freeContextCache(ctx);
            cache.reinitBitmapTextureCache();
            #if dd_stat
            GlobalStatistics.freeContext(ctx);
            #end
        }
        ctx = stage3d.context3D;

        isHW = ctx.driverInfo.toLowerCase().indexOf("software") == -1;
		
		#if debug
        ctx.enableErrorChecking = true;
		#end

        #if dd_stat
        GlobalStatistics.initContext(ctx);
        #end
		
        if (scene != null) scene.init(ctx);
        invalidateSize = true;

        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseEvent);
        stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
        stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave);

        stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchEvent);
        stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchEvent);
        stage.addEventListener(TouchEvent.TOUCH_END, onTouchEvent);

        stage.addEventListener(Event.ENTER_FRAME, onRender);
    }

    static var touchAlias = initTouchAlias();

    static function initTouchAlias()
    {
        var res:Hash<String> = new Hash<String>();
        res.set(TouchEvent.TOUCH_MOVE, MouseEvent.MOUSE_MOVE);
        res.set(TouchEvent.TOUCH_BEGIN, MouseEvent.MOUSE_DOWN);
        res.set(TouchEvent.TOUCH_END, MouseEvent.MOUSE_UP);

        return res;
    }

    var mouseOut:Bool;

    function onTouchEvent(e:TouchEvent)
    {
        if (scene == null) return;

        if (mouseOut && (mouseOut = bounds.contains(e.stageX, e.stageY))) return;

        var md:MouseData = new MouseData();
        md.type = touchAlias.get(e.type);
        md.pointId = e.touchPointID;
        md.touch = true;
        md.shift = e.shiftKey;
        md.ctrl = e.ctrlKey;
        md.alt = e.altKey;

        mouseStep(e.stageX, e.stageY, md);
    }

    function onMouseLeave(e:Event)
    {
        if (scene == null) return;

        var md:MouseData = new MouseData();
        md.type = MouseEvent.MOUSE_MOVE;

        mouseStep(stage.mouseX, stage.mouseY, md);
    }

    function onMouseEvent(e:MouseEvent)
    {
        if (scene == null) return;

        if (mouseOut && (mouseOut = bounds.contains(e.stageX, e.stageY))) return;

        var md:MouseData = new MouseData();
        md.type = e.type;
        md.shift = e.shiftKey;
        md.ctrl = e.ctrlKey;
        md.alt = e.altKey;

        mouseStep(e.stageX, e.stageY, md);
    }

    inline function mouseStep(mx:Float, my:Float, md:MouseData)
    {
        var m = new Vector3D(0, 0, 0, 1);

        m.x = (mx - bounds.x) / bounds.width * 2 - 1;
        m.y = -(my - bounds.y) / bounds.height * 2 + 1;

        scene.mouseStep(m, camera, md);
    }

    inline function ctxExist():Bool
    {
        return ctx != null && ctx.driverInfo != "Disposed";
    }

    function onResizeHandler(?_)
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
        stage3d.x = bounds.x;
        stage3d.y = bounds.y;
        camera.resize(w, h);
        ctx.configureBackBuffer(w, h, antialiasing);

        onResize.dispatch(w, h);
        invalidateSize = false;
    }

    function onRender(_)
    {
        if (pause) return;

        if (ctxExist())
		{
            #if dd_stat
            statistics.reset();
            #end

			if (invalidateSize) updateSize();

			if (camera.needUpdate) camera.update();

			ctx.setCulling(Context3DTriangleFace.NONE);
			ctx.setDepthTest(false, Context3DCompareMode.ALWAYS);

			ctx.clear(bgColor.r, bgColor.g, bgColor.b, bgColor.a);

			scene.drawStep(camera);

			ctx.present();
		}
    }
	
	function dispose(disposeContext3D:Bool = true):Void
	{
		stage3d.removeEventListener(Event.CONTEXT3D_CREATE, onContext);
		stage.removeEventListener(Event.ENTER_FRAME, onRender);
        stage.removeEventListener(Event.RESIZE, onResizeHandler);

        stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseEvent);
        stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
        stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseEvent);

        stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchEvent);
        stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchEvent);
        stage.removeEventListener(TouchEvent.TOUCH_END, onTouchEvent);
		
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

        if (statistics != null)
        {
            statistics.dispose();
            statistics = null;
        }
        cache.dispose();
        cache = null;

        context3DRenderMode = null;
        bgColor = null;
		stage = null;
		stage3d = null;

        if (disposeContext3D) ctx.dispose();
        ctx = null;

        Reflect.setField(this, "bounds", null);
	}

    function set_scene(s:Scene2D)
    {
        if (scene != null)
        {
            Reflect.callMethod(scene, Reflect.field(scene, "setWorld"), [null]);
        }
        scene = s;
        if (scene != null)
        {
            Reflect.callMethod(scene, Reflect.field(scene, "setWorld"), [this]);
            scene.init(ctx);
        }
		
        return s;
    }

    function set_antialiasing(val:UInt):UInt
    {
        invalidateSize = (val != antialiasing);
        return antialiasing = val;
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
            autoResize = false;
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
            autoResize = false;
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
