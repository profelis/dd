package ;
import deep.dd.texture.atlas.animation.Animator;
import deep.dd.display.MovieClip2D;
import deep.dd.display.Node2D;
import deep.dd.texture.atlas.parser.CheetahParser;
import flash.utils.ByteArray;
import deep.dd.texture.atlas.parser.SpriteSheetParser;
import deep.dd.texture.atlas.AtlasTexture2D;
import deep.dd.texture.Texture2D;
import flash.display.BitmapData;
import deep.dd.display.Sprite2D;
import flash.events.MouseEvent;
import mt.m3d.Color;
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

@:bitmap("metalslug_monster39x40.png") class SpriteSheet extends BitmapData {}

@:bitmap("atlas1/text.png") class Image extends BitmapData {}
@:file("atlas1/text.atlas") class Atlas extends ByteArray {}

class Main
{

    var world:World2D;
    var sprite:PerlinSprite;


    var sp:Sprite2D;
    var sp2:Node2D;

    var mc:MovieClip2D;

    public function new()
    {
        var s = flash.Lib.current.stage;
        s.scaleMode = StageScaleMode.NO_SCALE;
        s.align = StageAlign.TOP_LEFT;

        world = new World2D(Context3DRenderMode.AUTO);

        world.scene = new Scene2D();

		world.antialiasing = 2;
        world.bgColor.fromInt(0x666666);

        sp2 = new Node2D();
        world.scene.addChild(sp2);

        var q = new Quad2D(Geometry.createSolid(128, 128));
        q.color = 0xFF0000;
        //q.x = 10;
        //q.y = 10;
        sp2.addChild(q);



        var t = new AtlasTexture2D(world.cache.getTexture(Image),new CheetahParser(Std.string(new Atlas())));
        var dx = 0.0;
        for (i in 0...t.frames.length)
        {
            trace(t.frames[i]);
            sp = new Sprite2D(Geometry.createTextured(100, 100));
            sp2.addChild(sp);

            sp.texture = t.getTextureById(i);
            sp.x = dx;
            dx += sp.width;
        }

        mc = new MovieClip2D(new Animator(5));
        mc.scaleX = mc.scaleY = 5;
        mc.texture = new AtlasTexture2D(world.cache.getTexture(SpriteSheet), new SpriteSheetParser(39, 40, 0.5));
        mc.y = 200;

        world.scene.addChild(mc);

        mc = new MovieClip2D(new Animator(5));
        mc.scaleX = mc.scaleY = 5;
        mc.texture = new AtlasTexture2D(world.cache.getTexture(SpriteSheet), new SpriteSheetParser(39, 40, 5));
        mc.colorTransform = new Color(1, 0, 0, 1);
        mc.y = 200;

        world.scene.addChild(mc);

        s.addEventListener(Event.ENTER_FRAME, onRender);

        s.addEventListener(MouseEvent.CLICK, onClick);
    }

    function onClick(_)
    {
        world.ctx.dispose();
    }

    function onRender(_)
    {
        sp2.rotationY += 0.05;
    }


    static function main()
    {
        new Main();
    }
}