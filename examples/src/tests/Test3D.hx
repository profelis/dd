package tests;

import deep.dd.camera.Camera2D;
import deep.dd.texture.atlas.parser.SpriteSheetParser;
import deep.dd.texture.atlas.AtlasTexture2D;
import deep.dd.display.Sprite2D;
import flash.display.BitmapData;
import mt.m3d.Color;
import deep.dd.World2D;

@:bitmap("../assets/test3d/homeBanner.jpg") class Image extends BitmapData {}

class Test3D extends Test
{
    inline static var nx = 10;
    inline static var ny = 4;

    public function new(wrld:World2D)
    {
        super(wrld);

        wrld.bgColor = new Color(1, 1, 1, 1);


        var bmp = new Image(0, 0);

        var iw:Float = bmp.width / nx;
        var ih:Float = bmp.height / ny;

        var t = new AtlasTexture2D(world.cache.getBitmapTexture(bmp), new SpriteSheetParser(iw, ih));

        for (x in 0...nx)
        {
            for (y in 0...ny)
            {
                var s = new Sprite2D();
                s.texture = t.getTextureById(x * ny + y);
                s.x = x * iw;
                s.y = y * ih;
                addChild(s);
            }
        }

    }

    override public function drawStep(camera:Camera2D):Void
    {

        super.drawStep(camera);
    }


}
