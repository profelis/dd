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
class World2D
{
    var _stageId:Int;
    var _context3DRenderMode:Context3DRenderMode;

    var stage:Stage;
    var st3d:Stage3D;

    public var ctx(default, null):Context3D;

    public var autoResize:Bool;

    public var w:Int;
    public var h:Int;

    public var pause:Bool;

    public var camera:Camera2D;
    public var scene(default, set_scene):Scene2D;

    public var bgColor:Color;

    public function new(context3DRenderMode:Context3DRenderMode, stageId:Int = 0)
    {
        _context3DRenderMode = context3DRenderMode;
        _stageId = stageId;

        pause = false;
        autoResize = true;

        bgColor = new Color(255, 255, 255);

        camera = new Camera2D();

        stage = flash.Lib.current.stage;
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
        if (autoResize)
        {
            w = Std.int(stage.stageWidth);
            h = Std.int(stage.stageHeight);
        }
        camera.resize(w, h);
        ctx.configureBackBuffer(w, h, 2);
    }

    function onRender(_)
    {
        if (pause) return;

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
}
