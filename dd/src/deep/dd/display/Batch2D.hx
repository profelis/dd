package deep.dd.display;

import deep.dd.display.render.BatchRender;
import deep.dd.utils.Frame;
import deep.dd.material.batch2d.Batch2DMaterial;
import deep.dd.display.Node2D;
import haxe.FastList;
import mt.m3d.Color;
import deep.dd.display.Sprite2D;
import flash.geom.Vector3D;
import flash.geom.Matrix3D;
import flash.Vector;
import deep.dd.camera.Camera2D;
import deep.dd.material.Material;
import deep.dd.material.batch2d.Batch2DMaterial;
import deep.dd.animation.AnimatorBase;
import deep.dd.geometry.Geometry;
import deep.dd.utils.FastHaxe;

class Batch2D extends SmartSprite2D
{
    public function new()
    {
        super(batchRender = new BatchRender());
    }

    public var batchRender(default, null):BatchRender;
}
