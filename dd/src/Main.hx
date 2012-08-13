import deep.dd.texture.Texture2D;
import flash.display.BitmapData;
import deep.dd.display.Sprite2D;
import flash.events.MouseEvent;
import deep.dd.utils.Color;
import deep.dd.utils.BlendMode;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import deep.dd.display.Quad2D;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import deep.dd.display.Scene2D;
import flash.display3D.Context3DRenderMode;
import deep.dd.World2D;
import deep.dd.geometry.Geometry;
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

    var sp2:Sprite2D;

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

        world.scene.addChild(sp2 = new Sprite2D());
        var sp:Sprite2D;
        for (x in 0...1)
            for (y in 0...1)
            {
                sp2.addChild(sp = new Sprite2D(Geometry.create(150, 150, true)));
                sp.texture = world.cache.getTexture(Image);
                sp.x = x * 150;
                sp.y = y * 100;
                //sp.scaleX = 0.5;
                //sp.scaleY = 0.5;
            }
        sp2.pivot = new Vector3D(160, 100, 0);
        sp2.x = 160;
        sp2.y = 100;

        s.addEventListener(Event.ENTER_FRAME, onRender);

        s.addEventListener(MouseEvent.CLICK, onClick);
    }

    function onClick(_)
    {
        world.bounds = world.autoResize ? new Rectangle(200, 20, 400, 400) : null;

        if (sp2 != null)
        {
            //sp2.dispose();
            //sp2 = null;
        }
    }

    function onRender(_)
    {
        if (sp2 != null) sp2.rotationX += 0.5;
        q2.rotationY = q2.rotationY + 0.5;
        q.rotationZ ++;
        q.scaleX *= 0.995;
    }


    static function main()
    {
        new Main();
    }
}