package deep.dd.display;

import deep.dd.utils.MouseData;
import msignal.Signal;
import msignal.Signal.Signal1;
import msignal.Signal.Signal2;
import flash.events.TouchEvent;
import flash.events.MouseEvent;
import msignal.Signal;
import haxe.FastList;
import msignal.Signal;
import mt.m3d.Color;
import deep.dd.World2D;
import flash.geom.Vector3D;
import deep.dd.utils.BlendMode;
import flash.geom.Matrix3D;
import deep.dd.camera.Camera2D;
import flash.display3D.Context3D;

class Node2D
{
    public var blendMode:BlendMode;

    public var parent(default, null):Node2D;
    public var scene(default, null):Scene2D;
    public var world(get_world, null):World2D;

    var _width:Float = 1;
    var _height:Float = 1;

    public var transform(default, null):Matrix3D;
    var invalidateTransform:Bool = true;

    public var worldTransform(default, null):Matrix3D;
    var invalidateWorldTransform:Bool = true;

    public var colorTransform(default, set_colorTransform):Color;
    public var worldColorTransform(default, null):Vector3D;
    var invalidateColorTransform:Bool;

    public var alpha(default, set_alpha):Float = 1;

    public var visible:Bool = true;

    var children:FastList<Node2D>;

    public var numChildren(default, null):UInt = 0;

    var ctx:Context3D;

    public var mouseEnabled:Bool = false;
    public var mouseX(default, null):Float;
    public var mouseY(default, null):Float;

    var oldMouseOver:Bool = false;
    public var mouseOver(default, null):Bool = false;
    public var mouseDown(default, null):Bool = false;

    var mouseTransform:Matrix3D;

    public var ignoreInBatch:Bool = false;

    public var transformChange(default, null):Signal0;
    public var colorTransformChange(default, null):Signal0;
    public var onMouseOver(default, null):Signal2<Node2D, MouseData>;
    public var onMouseOut(default, null):Signal2<Node2D, MouseData>;
    public var onMouseDown(default, null):Signal2<Node2D, MouseData>;
    public var onMouseUp(default, null):Signal2<Node2D, MouseData>;

    public function new()
    {
        blendMode = BlendMode.NORMAL;

        transformChange = new Signal0();
        colorTransformChange = new Signal0();
        onMouseOver = new Signal2<Node2D, MouseData>();
        onMouseOut = new Signal2<Node2D, MouseData>();
        onMouseDown = new Signal2<Node2D, MouseData>();
        onMouseUp = new Signal2<Node2D, MouseData>();

        children = new FastList<Node2D>();
        transform = new Matrix3D();

        mouseTransform = new Matrix3D();

        worldColorTransform = new Vector3D();
        worldTransform = new Matrix3D();

        colorTransform = null;
    }

    public function dispose():Void
    {
        if (parent != null)
        {
            parent.removeChild(this);
        }

        transformChange.removeAll();
        colorTransformChange.removeAll();

        for (child in children)
        {
            child.dispose();
        }

        ctx = null;
        children = null;
        transform = null;
        worldTransform = null;
        worldColorTransform = null;
        blendMode = null;

        Reflect.setField(this, "pivot", null);
        Reflect.setField(this, "colorTransform", null);
    }

    public function init(ctx:Context3D):Void
    {
        if (this.ctx != ctx)
        {
            this.ctx = ctx;
            for (i in children) i.init(ctx);
        }
    }

    function setParent(p:Node2D)
    {
        if (parent != null)
        {
            parent.transformChange.remove(onParentTransformChange);
            parent.colorTransformChange.remove(onParentColorChange);
        }

        parent = p;
        invalidateWorldTransform = true;
        invalidateColorTransform = true;

        if (parent != null)
        {
            parent.transformChange.add(onParentTransformChange);
            parent.colorTransformChange.add(onParentColorChange);
        }
    }

    function onParentColorChange()
    {
        invalidateColorTransform = true;
    }

    function onParentTransformChange()
    {
        invalidateWorldTransform = true;
    }

    function setScene(s:Scene2D):Void
    {
        scene = s;
        for (i in children) i.setScene(s);
    }

    function get_world():World2D
    {
        return scene != null ? scene.world : null;
    }

    // children

    public function addChild(c:Node2D):Void
    {
        if (c.parent != null)
        {
            if (c.parent == this)
            {
                children.remove(c);  // small optimization
                children.add(c);
                return;
            }

            c.parent.removeChild(c);
        }
        children.add(c);
        c.setParent(this);
        if (scene != null) c.setScene(scene);
        if (ctx != null) c.init(ctx);
        numChildren ++;
    }

    public function removeChild(c:Node2D):Void
    {
        if (!children.remove(c)) throw "c must be child";
        c.invalidateWorldTransform = true;
        c.parent = null;
        c.setParent(null);
        c.setScene(null);
        numChildren --;
    }
	
    public function iterator():Iterator<Node2D>
    {
        return children.iterator();
    }

    // mouse

    public function mouseStep(pos:Vector3D, camera:Camera2D, md:MouseData)
    {

        mouseTransform.identity();
        mouseTransform.append(worldTransform);
        mouseTransform.append(camera.ort);
        mouseTransform.invert();

        var p = mouseTransform.transformVector(pos);

        var inv = 1 / p.w;
        p.x *= inv;
        p.y *= inv;
        p.z *= inv;
        p.w = 1;

        mouseX = p.x;
        mouseY = p.y;

        checkMouseOver(p);

        if (mouseOver)
        {
            if (!oldMouseOver)
                onMouseOver.dispatch(this, md);
        }
        else
        {
            if (oldMouseOver) onMouseOut.dispatch(this, md);
        }
        oldMouseOver = mouseOver;


        switch (md.type)
        {
            case MouseEvent.MOUSE_DOWN:
                if (mouseOver)
                {
                    mouseDown = true;
                    onMouseDown.dispatch(this, md);
                }

            case MouseEvent.MOUSE_UP:
                if (mouseDown)
                {
                    mouseDown = false;
                    onMouseUp.dispatch(this, md);
                }
        }

        for (i in children)
        {
            if (i.mouseEnabled)
            {
                i.mouseStep(pos, camera, md);
            }
        }
    }

    function checkMouseOver(p:Vector3D)
    {
        mouseOver = p.x >= 0 && p.x <= _width && p.y >= 0 && p.y <= _height;
    }

    // render

    public function drawStep(camera:Camera2D):Void
    {
        if (invalidateTransform) updateTransform();
        if (invalidateWorldTransform) updateWorldTransform();
        if (invalidateColorTransform) updateWorldColor();

        draw(camera);

        for (i in children) if (i.visible) i.drawStep(camera);
    }

    inline public function updateWorldColor()
    {
        worldColorTransform.setTo(colorTransform.r, colorTransform.g, colorTransform.b);
        worldColorTransform.w = colorTransform.a;

        if (parent != null)
        {
            var p = parent.worldColorTransform;
            worldColorTransform.x *= p.x;
            worldColorTransform.y *= p.y;
            worldColorTransform.z *= p.z;
            worldColorTransform.w *= p.w;
        }

        invalidateColorTransform = false;

        colorTransformChange.dispatch();
    }

    inline public function updateWorldTransform()
    {
        worldTransform.identity();
        worldTransform.append(this.transform);

        if (parent != null) worldTransform.append(parent.worldTransform);
        invalidateWorldTransform = false;
    }

    inline public function updateTransform()
    {
        transform.identity();
        if (pivot != null) transform.appendTranslation(-pivot.x, -pivot.y, -pivot.z);
        transform.appendScale(scaleX, scaleY, scaleZ);
        transform.appendRotation(rotationZ, Vector3D.Z_AXIS);
        transform.appendRotation(rotationY, Vector3D.Y_AXIS);
        transform.appendRotation(rotationX, Vector3D.X_AXIS);
        transform.appendTranslation(x, y, z);
        if (pivot != null) transform.appendTranslation(pivot.x, pivot.y, pivot.z);

        invalidateTransform = false;
        invalidateWorldTransform = true;

        transformChange.dispatch();
    }

    public function draw(camera:Camera2D):Void
    {
    }

    // transform

    public var pivot(default, set_pivot):Vector3D;

    function set_pivot(v)
    {
        pivot = v;
        invalidateTransform = true;
        return v;
    }

    public var x(default, set_x):Float = 0;
    public var y(default, set_y):Float = 0;
    public var z(default, set_z):Float = 0;

    public var rotationX(default, set_rotationX):Float = 0;
    public var rotationY(default, set_rotationY):Float = 0;
    public var rotationZ(default, set_rotationZ):Float = 0;

    public var scaleX(default, set_scaleX):Float = 1;
    public var scaleY(default, set_scaleY):Float = 1;
    public var scaleZ(default, set_scaleZ):Float = 1;

    function set_x(v:Float)
    {
        x = v;
        invalidateTransform = true;
        return v;
    }

    function set_y(v:Float)
    {
        y = v;
        invalidateTransform = true;
        return v;
    }

    function set_z(v:Float)
    {
        z = v;
        invalidateTransform = true;
        return v;
    }

    function set_rotationX(v:Float)
    {
        rotationX = v;
        invalidateTransform = true;
        return v;
    }

    function set_rotationY(v:Float)
    {
        rotationY = v;
        invalidateTransform = true;
        return v;
    }

    function set_rotationZ(v:Float)
    {
        rotationZ = v;
        invalidateTransform = true;
        return v;
    }

    function set_scaleX(v:Float)
    {
        scaleX = v;
        invalidateTransform = true;
        return v;
    }

    function set_scaleY(v:Float)
    {
        scaleY = v;
        invalidateTransform = true;
        return v;
    }

    function set_scaleZ(v:Float)
    {
        scaleZ = v;
        invalidateTransform = true;
        return v;
    }

    // color transform

    function set_colorTransform(c)
    {
        if (c!= null && colorTransform != null && colorTransform.eqauls(c)) return colorTransform;

        if (c == null) c = new Color(1, 1, 1, 1);

        colorTransform = c;
        invalidateColorTransform = true;

        return c;
    }

    function set_alpha(v:Float):Float
    {
        v = Color.clamp(v);
        if (v != colorTransform.a)
        {
            alpha = colorTransform.a = v;
            invalidateColorTransform = true;
        }

        return v;
    }
}