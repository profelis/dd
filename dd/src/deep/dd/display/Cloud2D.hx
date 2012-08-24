package deep.dd.display;

import deep.dd.display.render.CloudRender;
import flash.geom.Vector3D;
import haxe.FastList;
import deep.dd.material.Material;
import deep.dd.camera.Camera2D;
import deep.dd.material.cloud2d.Cloud2DMaterial;
import deep.dd.geometry.Geometry;
import deep.dd.utils.FastHaxe;


class Cloud2D extends SmartSprite2D
{

    public function new(startSize:UInt = 20, incSize:UInt = 20)
    {
        super(cloudRender = new CloudRender(startSize, incSize));
    }

    public var cloudRender(default, null):CloudRender;

}
