package tests;

import deep.dd.display.Sprite2D;
import flash.display.BitmapData;
import mt.m3d.Color;
import deep.dd.World2D;

@:bitmap("../assets/test3d/homeBanner.jpg") class Image extends BitmapData {}

class Test3D extends Test
{
    public function new(wrld:World2D)
    {
        super(wrld);

        wrld.bgColor = new Color(1, 1, 1, 1);


        var s = new Sprite2D();
        addChild(s);
        s.texture = world.cache.getTexture(Image);
    }
}
