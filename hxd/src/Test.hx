import flash.events.MouseEvent;
import mt.m3d.Vector;
import mt.m3d.Cube;
import mt.m3d.Camera;
import mt.m3d.Polygon;
import format.agal.Tools;

typedef K = flash.ui.Keyboard;

class Shader extends format.hxsl.Shader {

    static var SRC = {
    var input : {
    pos : Float3,
    };
    var color : Float3;
    function vertex( mpos : M44, mproj : M44 ) {
        out = pos.xyzw * mpos * mproj;
        color = pos;
    }
    function fragment() {
        out = color.xyzw;
    }
};

}

class Test {

    var stage : flash.display.Stage;
    var s : flash.display.Stage3D;
    var c : flash.display3D.Context3D;
    var shader : Shader;
    var pol : Polygon;
    var t : Float;
    var keys : Array<Bool>;

    var camera : Camera;

    function new() {
        t = 0;
        keys = [];
        stage = flash.Lib.current.stage;
        s = stage.stage3Ds[0];
        s.addEventListener( flash.events.Event.CONTEXT3D_CREATE, onReady );
        stage.addEventListener( flash.events.KeyboardEvent.KEY_DOWN, callback(onKey,true) );
        stage.addEventListener( flash.events.KeyboardEvent.KEY_UP, callback(onKey,false) );
        flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, update);
        s.requestContext3D();
    }

    function onKey( down, e : flash.events.KeyboardEvent ) {
        keys[e.keyCode] = down;
    }

    function onReady( _ ) {
        camera = new Camera();
        //camera.pos = new Vector(0, 0, 3);
        c = s.context3D;
        c.enableErrorChecking = true;
        c.configureBackBuffer( camera.w = stage.stageWidth, camera.h = stage.stageHeight, 4, true );
        camera.ratio = camera.w / camera.h;

        shader = new Shader(c);


        pol = new Cube();
        pol.alloc(c);

        stage.addEventListener(MouseEvent.CLICK, function (_)
        {
            camera.perspective = !camera.perspective;
            camera.zoom = camera.perspective ? 1 : 100;
        });
    }

    function update(_) {
        if( c == null ) return;

        //t += 0.01;

        c.clear(0.5, 0.5, 0.5, 1);
        c.setDepthTest( true, flash.display3D.Context3DCompareMode.LESS_EQUAL );
        c.setCulling(flash.display3D.Context3DTriangleFace.NONE);

        if( keys[K.UP] )
            camera.moveAxis(0,-50.1);
        if( keys[K.DOWN] )
            camera.moveAxis(0,50.1);
        if( keys[K.LEFT] )
            camera.moveAxis(-50.1,0);
        if( keys[K.RIGHT] )
            camera.moveAxis(50.1, 0);
        if( keys[109] )
            camera.zoom /= 1.05;
        if( keys[107] )
            camera.zoom *= 1.05;
        camera.update();

        var project = camera.m.toMatrix();

        var mpos = new flash.geom.Matrix3D();
        mpos.appendRotation(t * 10, flash.geom.Vector3D.Z_AXIS);

        shader.init(
            { mpos : mpos, mproj : project },
            {}
        );

        shader.bind(pol.vbuf);
        c.drawTriangles(pol.ibuf);
        c.present();
    }

    static function main() {
        haxe.Log.setColor(0xFF0000);
        var inst = new Test();
    }

}