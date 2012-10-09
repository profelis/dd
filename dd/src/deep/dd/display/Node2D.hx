package deep.dd.display;

import Reflect;
import msignal.Signal.Signal2;
import deep.dd.utils.FastListUtils;
import flash.Vector;
import deep.dd.utils.MouseData;
import flash.events.TouchEvent;
import flash.events.MouseEvent;
import msignal.Signal;
import haxe.FastList;
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

    public var extra:Dynamic;

    /**
    * @private
    */
    public var _width:Float;
    /**
    * @private
    */
    public var _height:Float;

    public var transform(default, null):Matrix3D;
    /**
    * @private
    */
    public var invalidateTransform:Bool = true;

    public var worldTransform(default, null):Matrix3D;
    /**
    * @private
    */
    public var invalidateWorldTransform:Bool = true;

    public var colorTransform(default, set_colorTransform):Color;
    public var worldColorTransform(default, null):Vector3D;
    /**
    * @private
    */
    public var invalidateColorTransform:Bool;

    public var alpha(default, set_alpha):Float = 1;

    public var visible(default, set_visible):Bool = true;

    function set_visible(v)
    {
        return visible = v;
    }

    /**
    * @private
    */
    public var children(default, null):FastList<Node2D>;
    var childrenUtils:FastListUtils<Node2D>;

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
    public var onMouseOver(get_onMouseOver, null):Signal2<Node2D, MouseData>;
    public var onMouseOut(get_onMouseOut, null):Signal2<Node2D, MouseData>;
    public var onMouseDown(get_onMouseDown, null):Signal2<Node2D, MouseData>;
    public var onMouseUp(get_onMouseUp, null):Signal2<Node2D, MouseData>;

    function get_onMouseOver() { if (onMouseOver == null) onMouseOver = new Signal2<Node2D, MouseData>(); return onMouseOver; }
    function get_onMouseOut() { if (onMouseOut == null) onMouseOut = new Signal2<Node2D, MouseData>(); return onMouseOut; }
    function get_onMouseDown() { if (onMouseDown == null) onMouseDown = new Signal2<Node2D, MouseData>(); return onMouseDown; }
    function get_onMouseUp() { if (onMouseUp == null) onMouseUp = new Signal2<Node2D, MouseData>(); return onMouseUp; }

    public function new()
    {
        blendMode = BlendMode.NORMAL;

        transformChange = new Signal0();
        colorTransformChange = new Signal0();

        children = new FastList<Node2D>();
        childrenUtils = new FastListUtils<Node2D>(children);
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
        transformChange = null;
        colorTransformChange.removeAll();
        colorTransformChange = null;

        for (child in children)
        {
            child.dispose();
        }

        ctx = null;
        children = null;
        childrenUtils = null;
        transform = null;
        worldTransform = null;
        worldColorTransform = null;
        blendMode = null;

        if (Reflect.field(this, "onMouseOver") != null)
        {
            onMouseOver.removeAll();
            Reflect.setField(this, "onMouseOver", null);
        }
        if (Reflect.field(this, "onMouseOut") != null)
        {
            onMouseOut.removeAll();
            Reflect.setField(this, "onMouseOut", null);
        }
        if (Reflect.field(this, "onMouseDown") != null)
        {
            onMouseDown.removeAll();
            Reflect.setField(this, "onMouseDown", null);
        }
        if (Reflect.field(this, "onMouseUp") != null)
        {
            onMouseUp.removeAll();
            Reflect.setField(this, "onMouseUp", null);
        }

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

    public function contains(c:Node2D):Bool
    {
        return c.parent == this;
    }

    public function getChildIndex(c:Node2D):Int
    {
        return childrenUtils.indexOf(c);
    }

    public function addChildAt(c:Node2D, pos:UInt):Void
    {
        #if debug
        if (pos > numChildren) throw "out of bounds";
        #end
        if (c.parent != null)
        {
            if (c.parent == this)
            {
                if (childrenUtils.tail.elt != c)
                {
                    childrenUtils.remove(c);
                    childrenUtils.push(c);
                }
                return;
            }

            c.parent.removeChild(c);
        }

        childrenUtils.putAt(c, pos);
        numChildren = childrenUtils.length;

        c.setParent(this);
        if (scene != null) c.setScene(scene);
        if (ctx != null) c.init(ctx);
    }

    public function addChild(c:Node2D):Void
    {
        addChildAt(c, numChildren);
    }

    public function removeChildAt(pos:UInt)
    {
        #if debug
        if (pos >= numChildren) throw "out of bounds";
        #end

        removeChild(childrenUtils.getAt(pos));
    }

    public function removeChild(c:Node2D):Void
    {
        if (!childrenUtils.remove(c)) throw "c must be child";
        numChildren = childrenUtils.length;

        c.invalidateWorldTransform = true;
        c.parent = null;
        c.setParent(null);
        c.setScene(null);
    }

    public function getChildAt(pos:UInt):Node2D
    {
        #if debug
        if (pos >= numChildren) throw "out of bounds";
        #end

        return childrenUtils.getAt(pos);
    }
	
    public function iterator():Iterator<Node2D>
    {
        return children.iterator();
    }

    // mouse

    public function mouseStep(pos:Vector3D, camera:Camera2D, md:MouseData)
    {
        var res:Node2D;

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

        res = mouseOver ? this : null;


        if (children != null)
            for (i in children)
            {
                if (i.mouseEnabled)
                {
                    var subRes = i.mouseStep(pos, camera, md);
                    if (subRes != null) res = subRes;
                }
            }

        if (onMouseDown == null) res = null; // destrucred test
        mouseOver = mouseOver || res != null;

        if (mouseOver)
        {
            if (!oldMouseOver)
            {
                onMouseOver.dispatch(this, md);
//                trace("mouse over " + res + " " + this);
            }
        }
        else
        {
            if (oldMouseOver)
            {
                onMouseOut.dispatch(this, md);
//                trace("mouse out " + res + " " + this);
            }
        }

        if (res != null)
        {
            switch (md.type)
            {
                case MouseEvent.MOUSE_DOWN:
                    if (res.mouseOver)
                    {
                        res.mouseDown = true;
                        onMouseDown.dispatch(res, md);
//                        trace("mouse down " + res + " " + this);
                    }

                case MouseEvent.MOUSE_UP:
                    if (res.mouseDown)
                    {
                        res.mouseDown = false;
                        onMouseUp.dispatch(res, md);
//                        trace("mouse up " + res + " " + this);
                    }
            }
        }

        oldMouseOver = mouseOver;

        return res;
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
        worldTransform.rawData = transform.rawData;
        if (parent != null) worldTransform.append(parent.worldTransform);

        invalidateWorldTransform = false;
    }

    inline public function updateTransform()
    {
        transform.identity();

        var moved = x != 0 || y != 0 || z != 0;
        var scaled = scaleX != 1 || scaleY != 1 || scaleZ != 1;

        if (usePivot) transform.appendTranslation(-pivot.x, -pivot.y, -pivot.z);
        if (scaled) transform.appendScale(scaleX, scaleY, scaleZ);
        if (rotationZ != 0) transform.appendRotation(rotationZ, Vector3D.Z_AXIS);
        if (rotationY != 0) transform.appendRotation(rotationY, Vector3D.Y_AXIS);
        if (rotationX != 0) transform.appendRotation(rotationX, Vector3D.X_AXIS);
        if (moved) transform.appendTranslation(x, y, z);
        if (usePivot) transform.appendTranslation(pivot.x, pivot.y, pivot.z);

        invalidateTransform = false;
        invalidateWorldTransform = true;

        transformChange.dispatch();
    }

    public function draw(camera:Camera2D):Void
    {
    }

    // transform

    public var pivot(default, set_pivot):Vector3D;
    public var usePivot(default, null):Bool;

    function set_pivot(v:Vector3D):Vector3D
    {
        if (v != null && v.x == 0 && v.y == 0 && v.z == 0) v = null;

        pivot = v;
        usePivot = v != null;
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
        z = z = v;
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
        if (c == null) c = new Color(1, 1, 1, 1);

        colorTransform = c;
        alpha = c.a;
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