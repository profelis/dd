import deep.hxd.texture.Texture2D;
import flash.display.BitmapData;
import deep.hxd.display.Sprite2D;
import flash.events.MouseEvent;
import deep.hxd.utils.Color;
import deep.hxd.utils.BlendMode;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import deep.hxd.display.Quad2D;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import deep.hxd.display.Scene2D;
import flash.display3D.Context3DRenderMode;
import deep.hxd.World2D;
import deep.hxd.geometry.Geometry;
import flash.events.Event;
import mt.m3d.Camera;
import flash.display3D.Context3D;

@:bitmap("1.jpg") class Image extends BitmapData {}

class Main
{

    var world:World2D;
    var sprite:PerlinSprite;

    var q:Quad2D;
    var q2:Quad2D;

    var sp:Sprite2D;

    public function new()
    {
        var s = flash.Lib.current.stage;
        s.scaleMode = StageScaleMode.NO_SCALE;
        s.align = StageAlign.TOP_LEFT;

        world = new World2D(Context3DRenderMode.AUTO);

        world.scene = new Scene2D();
		
		world.bounds = new Rectangle(20, 20, 400, 400);
		world.antialiasing = 2;
		world.x = 200;
        world.bgColor = new Color(0.0, 0.5, 0.0);


        world.scene.addChild(q = new Quad2D(Geometry.create(300, 300)));
        q.alpha = 0.5;
        q.update();
        q.geometry.colors[0].r = 1;
        q.geometry.colors[0].g = 0;
        q.geometry.colors[0].b = 0;
        q.geometry.needUpdate = true;
        //q.blendMode = BlendMode.ADD_PREMULTIPLIED_ALPHA;

        world.scene.addChild(q2 = new Quad2D(Geometry.create(300, 300)));
        q2.x = 300;
        q2.y = 300;
        q2.pivot = new Vector3D(150, 150, 0);
        q2.color = 0x00FF20;
        //q2.alpha = 0.5;


        q2.addChild(q);
        q.x = 150;
        q.y = 150;
        //world.scene.addChild(sprite = new PerlinSprite());
        //sprite.blendMode = BlendMode.FILTER;

        world.scene.addChild(sp = new Sprite2D(Geometry.create(150, 150, true)));
        sp.texture = Texture2D.fromBitmap(new Image(0, 0));
        sp.x = 100;
        sp.y = 100;

        s.addEventListener(Event.ENTER_FRAME, onRender);

        s.addEventListener(MouseEvent.CLICK, onClick);
    }

    function onClick(_)
    {
        world.bounds = world.autoResize ? new Rectangle(200, 20, 400, 400) : null;
    }

    function onRender(_)
    {
        sp.rotationX += 0.5;
        q2.rotationY = q2.rotationY + 0.5;
        q.rotationZ ++;
        q.scaleX *= 0.995;
    }


    static function main()
    {
        new Main();
    }
}