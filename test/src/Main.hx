package ;
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

    public function new()
    {
        var s = flash.Lib.current.stage;
        s.scaleMode = StageScaleMode.NO_SCALE;
        s.align = StageAlign.TOP_LEFT;

        world = new World2D(Context3DRenderMode.AUTO);

        world.scene = new Scene2D();

		//world.bounds = new Rectangle(20, 20, 400, 400);
		world.antialiasing = 2;
        world.bgColor.fromInt(0x666666);

        sp = new Sprite2D(Geometry.createTextured(100, 100));
        world.scene.addChild(sp);

        sp.texture = SpriteSheetTexture2D.fromBitmap(new Image(0,0), 39, 40);

        s.addEventListener(Event.ENTER_FRAME, onRender);

        s.addEventListener(MouseEvent.CLICK, onClick);
    }

    function onClick(_)
    {

    }

    function onRender(_)
    {

    }


    static function main()
    {
        new Main();
    }
}