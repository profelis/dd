package ;
import deep.dd.texture.atlas.parser.SpriteSheetParser;
import deep.dd.texture.atlas.AtlasTexture2D;
import deep.dd.texture.SpriteSheetTexture2D;
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

@:bitmap("metalslug_monster39x40.png") class Image extends BitmapData {}

class Main
{

    var world:World2D;
    var sprite:PerlinSprite;


    var sp:Sprite2D;
    var sp2:Sprite2D;

    public function new()
    {
        var s = flash.Lib.current.stage;
        s.scaleMode = StageScaleMode.NO_SCALE;
        s.align = StageAlign.TOP_LEFT;

        world = new World2D(Context3DRenderMode.AUTO);

        world.scene = new Scene2D();

		world.antialiasing = 2;
        world.bgColor.fromInt(0x666666);

        var scale = 5;

        var q = new Quad2D(Geometry.createSolid(39, 40));
        q.color = 0xFF0000;
        q.scaleX = q.scaleY = scale;
        world.scene.addChild(q);

        sp = new Sprite2D(Geometry.createTextured(100, 100));
        world.scene.addChild(sp);
        //sp.x = 100;
        //sp.y = 100;
        sp.scaleY = sp.scaleX = scale;

        var t = new AtlasTexture2D(world.cache.getTexture(Image), new SpriteSheetParser(39, 40));
        //t.fps = 8;
        sp.texture = t;

        s.addEventListener(Event.ENTER_FRAME, onRender);

        s.addEventListener(MouseEvent.CLICK, onClick);
    }

    function onClick(_)
    {
        world.ctx.dispose();
    }

    function onRender(_)
    {

    }


    static function main()
    {
        new Main();
    }
}