package tests;

import com.bit101.components.Label;
import com.bit101.components.RadioButton;
import com.bit101.components.VBox;
import flash.display.Sprite;
import haxe.FastList;
import deep.dd.display.Cloud2D;
import deep.dd.display.Node2D;
import deep.dd.display.Batch2D;
import flash.geom.Vector3D;
import deep.dd.camera.Camera2D;
import deep.dd.texture.atlas.parser.SpriteSheetParser;
import deep.dd.texture.atlas.AtlasTexture2D;
import deep.dd.display.Sprite2D;
import flash.display.BitmapData;
import mt.m3d.Color;
import deep.dd.World2D;

@:bitmap("../assets/test3d/haxe.png") class Image extends BitmapData {}

class Test3D extends Test
{
    inline static var nx = 18;
    inline static var ny = 26;

    var c:Sprite2D;
    var t:AtlasTexture2D;

    var list:FastList<Sprite2D>;

    public function new(wrld:World2D)
    {
        super(wrld);

        var bmp = new Image(0, 0);

        var iw:Float = bmp.width / nx;
        var ih:Float = bmp.height / ny;

        t = new AtlasTexture2D(world.cache.getBitmapTexture(bmp), new SpriteSheetParser(iw, ih));

        list = new FastList<Sprite2D>();
        var pivot = new Vector3D(iw * 0.5, ih * 0.5);
        for (y in 0...ny)
        {
            for (x in 0...nx)
            {
                var s = new Sprite2D();
                s.texture = t.getTextureById(y * nx + x);
                s.pivot = pivot;
                s.x = x * iw - bmp.width * 0.5;
                s.y = y * ih - bmp.height * 0.5;
                list.add(s);
            }
        }

        initGUI();
    }

    function initGUI()
    {
        var cont = new VBox();
        cont.y = 40;
        var labels = ["simple", "batch", "cloud"];
        var action = [initSimple, initBatch, initCloud];

        for (i in 0...labels.length)
        {
            var r = new RadioButton(cont, 0, 0, labels[i], false, action[i]);
        }

        flash.Lib.current.addChild(cont.component);
    }

    function initSimple(?_)
    {
        var n = new Sprite2D();

        reInit(n);
    }

    function initBatch(?_)
    {
        var n = new Batch2D();
        n.texture = t;
        reInit(n);
    }

    function initCloud(?_)
    {
        var n = new Cloud2D(nx*ny);
        n.texture = t;
        reInit(n);
    }

    function reInit(n:Sprite2D)
    {
        for (c in list)
        {
            n.addChild(c);
        }

        if (c != null)
        {
            c.texture = null;
            c.dispose();
        }
        addChild(c = n);
    }

    override public function drawStep(camera:Camera2D):Void
    {

        for (i in list)
        {
            i.rotationX += 1.5;
            i.rotationY += 1.5;
        }

        if (c != null)
        {
            c.x = world.stage.stageWidth * 0.5;
            c.y = world.stage.stageHeight * 0.5;
        }

        super.drawStep(camera);
    }

    override public function dispose():Void
    {
        super.dispose();
        c = null;
    }


}
