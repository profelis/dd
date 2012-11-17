package deep.dd.display;

import flash.geom.Rectangle;
import msignal.Signal.Signal1;
import msignal.Signal.Signal2;
import Reflect;
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
    public var world(default, null):World2D;

    public var extra:Dynamic;

    public var transform(get_transform, null):Matrix3D;
    /**
    * @private
    */
    public var invalidateTransform:Bool = true;

    public var worldTransform(get_worldTransform, null):Matrix3D;
    /**
    * @private
    */
    public var invalidateWorldTransform:Bool = true;

    public var colorTransform(default, set_colorTransform):Color;
    public var worldColorTransform(get_worldColorTransform, null):Vector3D;
    /**
    * @private
    */
    public var invalidateColorTransform:Bool;

    public var alpha(default, set_alpha):Float = 1;

    public var visible(default, set_visible):Bool = true;

    function set_visible(v)
    {
        visible = v;
        if (Reflect.hasField(this, "onVisibleChange")) onVisibleChange.dispatch(this);
        return visible;
    }

    /**
    * @private
    */
    public var children(default, null):FastList<Node2D>;
    var childrenUtils:FastListUtils<Node2D>;

    public var numChildren(default, null):UInt = 0;

    var ctx:Context3D;

    public var mouseEnabled:Bool = false;
    public var mouseChildren:Bool = true;
    public var mouseX(default, null):Float;
    public var mouseY(default, null):Float;

    var oldMouseOver:Bool = false;
    public var mouseOver(default, null):Bool = false;
    public var mouseDown(default, null):Bool = false;

    var mouseTransform:Matrix3D;

    public var ignoreInBatch:Bool = false;

    public var onTransformChange(default, null):Signal0;
    public var onWorldTransformChange(default, null):Signal0;
    public var onColorTransformChange(default, null):Signal0;
    public var onVisibleChange(get_onVisibleChange, null):Signal1<Node2D>;

    public var onMouseOver(get_onMouseOver, null):Signal2<Node2D, MouseData>;
    public var onMouseOut(get_onMouseOut, null):Signal2<Node2D, MouseData>;
    public var onMouseDown(get_onMouseDown, null):Signal2<Node2D, MouseData>;
    public var onMouseUp(get_onMouseUp, null):Signal2<Node2D, MouseData>;

    public var onWorld(get_onWorld, null):Signal2<World2D, World2D>;
    public var onScene(get_onScene, null):Signal2<Scene2D, Scene2D>;

    function get_onMouseOver() { if (onMouseOver == null) onMouseOver = new Signal2<Node2D, MouseData>(); return onMouseOver; }
    function get_onMouseOut() { if (onMouseOut == null) onMouseOut = new Signal2<Node2D, MouseData>(); return onMouseOut; }
    function get_onMouseDown() { if (onMouseDown == null) onMouseDown = new Signal2<Node2D, MouseData>(); return onMouseDown; }
    function get_onMouseUp() { if (onMouseUp == null) onMouseUp = new Signal2<Node2D, MouseData>(); return onMouseUp; }
    function get_onWorld() { if (onWorld == null) onWorld = new Signal2<World2D, World2D>(); return onWorld; }
    function get_onScene() { if (onScene == null) onScene = new Signal2<Scene2D, Scene2D>(); return onScene; }
    function get_onVisibleChange() { if (onVisibleChange == null) onVisibleChange = new Signal1<Node2D>(); return onVisibleChange; }

    static var uid:Int = 0;

    public var name:String;
	
	/**
	 * Helpers for bound calculations
	 */
	private var _boundRect:Rectangle;
	private var _boundRect2:Rectangle;

    public function new()
    {
        blendMode = BlendMode.NORMAL_A;

        onTransformChange = new Signal0();
        onWorldTransformChange = new Signal0();
        onColorTransformChange = new Signal0();

        children = new FastList<Node2D>();
        childrenUtils = new FastListUtils<Node2D>(children);
        transform = new Matrix3D();

        mouseTransform = new Matrix3D();

        worldColorTransform = new Vector3D();
        worldTransform = new Matrix3D();

        colorTransform = null;

        name = "node_" + uid++;
		
		_boundRect = new Rectangle();
		_boundRect2 = new Rectangle();
    }

    public function dispose():Void
    {
        if (parent != null)
        {
            parent.removeChild(this);
        }

        onTransformChange.removeAll();
        onTransformChange = null;
        onWorldTransformChange.removeAll();
        onWorldTransformChange = null;
        onColorTransformChange.removeAll();
        onColorTransformChange = null;

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

        // TODO: replace with var o:Dynamic = this; o.onVisibleChange = null;
        if (Reflect.field(this, "onVisibleChange") != null)
        {
            onVisibleChange.removeAll();
            Reflect.setField(this, "onVisibleChange", null);
        }
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
        if (Reflect.field(this, "onWorld") != null)
        {
            onWorld.removeAll();
            Reflect.setField(this, "onWorld", null);
        }
        if (Reflect.field(this, "onScene") != null)
        {
            onScene.removeAll();
            Reflect.setField(this, "onScene", null);
        }

        Reflect.setField(this, "pivot", null);
        Reflect.setField(this, "colorTransform", null);
		
		_boundRect = null;
		_boundRect2 = null;
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
            parent.onWorldTransformChange.remove(onParentTransformChange);
            parent.onColorTransformChange.remove(onParentColorChange);
        }

        parent = p;

        if (parent != null)
        {
            parent.onWorldTransformChange.add(onParentTransformChange);
            parent.onColorTransformChange.add(onParentColorChange);
        }

        onParentColorChange();
        onParentTransformChange();
    }

    function onParentColorChange()
    {
        invalidateColorTransform = true;
        onColorTransformChange.dispatch();
    }

    function onParentTransformChange()
    {
        invalidateWorldTransform = true;
        onWorldTransformChange.dispatch();
    }

    function setScene(s:Scene2D):Void
    {
        if (Reflect.hasField(this, "onScene")) onScene.dispatch(scene, scene = s);

        if (Reflect.hasField(this, "onWorld")) onWorld.dispatch(world, world = s != null ? s.world : null);

        if (children != null) for (i in children) i.setScene(s);
    }

    function setWorld(w:World2D):Void
    {
        if (Reflect.hasField(this, "onWorld")) onWorld.dispatch(world, world = w);
        else world = w;
        if (children != null) for (i in children) i.setWorld(w);
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

        #if debug
        var p = parent;
        while (p != null)
        {
            if (p == c) throw "can't add parent node as child";
            p = p.parent;
        }
        #end

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

        mouseTransform.copyFrom(worldTransform);
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
                if (i.mouseChildren)
                {
                    var subRes = i.mouseStep(pos, camera, md);
                    if (subRes != null) res = subRes;
                }
            }

        if (onTransformChange == null) res = null; // destrucred test
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
                    if (mouseOver)
                    {
                        mouseDown = true;
                        onMouseDown.dispatch(res, md);
//                        trace("mouse down " + res + " " + this);
                    }

                case MouseEvent.MOUSE_UP:
                    if (mouseDown)
                    {
                        mouseDown = false;
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
        mouseOver = false;
    }

    public function updateStep()
    {
        for (i in children) if (i.visible) i.updateStep();
    }

    // render

    public function drawStep(camera:Camera2D):Void
    {
        for (i in children) if (i.visible) i.drawStep(camera);
    }

    function get_worldTransform():Matrix3D
    {
        if (invalidateTransform || invalidateWorldTransform)
        {
            worldTransform.rawData = transform.rawData;
            if (parent != null) worldTransform.append(parent.worldTransform);

            invalidateWorldTransform = false;
        }
        return worldTransform;
    }

    // transform

    function get_transform():Matrix3D
    {
        if (invalidateTransform)
        {
            transform.identity();

            var moved = x != 0 || y != 0;
            var scaled = scaleX != 1 || scaleY != 1;

            if (usePivot) transform.appendTranslation(-pivot.x, -pivot.y, -pivot.z);
            if (scaled) transform.appendScale(scaleX, scaleY, 1);
            if (rotation != 0) transform.appendRotation(rotation, Vector3D.Z_AXIS);
            if (moved) transform.appendTranslation(x, y, 0);
            if (usePivot) transform.appendTranslation(pivot.x, pivot.y, pivot.z);

            invalidateTransform = false;
            invalidateWorldTransform = true;
        }

        return transform;
    }

    public var pivot(default, set_pivot):Vector3D;
    public var usePivot(default, null):Bool;

    function set_pivot(v:Vector3D):Vector3D
    {
        if (v != null && v.x == 0 && v.y == 0 && v.z == 0) v = null;

        pivot = v;
        usePivot = v != null;
        invalidateTransform = true;
        onTransformChange.dispatch();
        return v;
    }

    public var x(default, set_x):Float = 0;
    public var y(default, set_y):Float = 0;

    public var rotation(default, set_rotation):Float = 0;

    public var scaleX(default, set_scaleX):Float = 1;
    public var scaleY(default, set_scaleY):Float = 1;

    function set_x(v:Float)
    {
        x = v;
        invalidateTransform = true;
        onTransformChange.dispatch();
        onWorldTransformChange.dispatch();
        return v;
    }

    function set_y(v:Float)
    {
        y = v;
        invalidateTransform = true;
        onTransformChange.dispatch();
        onWorldTransformChange.dispatch();
        return v;
    }

    function set_rotation(v:Float)
    {
        rotation = v;
        invalidateTransform = true;
        onTransformChange.dispatch();
        onWorldTransformChange.dispatch();
        return v;
    }

    function set_scaleX(v:Float)
    {
        scaleX = v;
        invalidateTransform = true;
        onTransformChange.dispatch();
        onWorldTransformChange.dispatch();
        return v;
    }

    function set_scaleY(v:Float)
    {
        scaleY = v;
        invalidateTransform = true;
        onTransformChange.dispatch();
        onWorldTransformChange.dispatch();
        return v;
    }


    // color transform

    function get_worldColorTransform()
    {
        if (invalidateColorTransform)
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
        }

        return worldColorTransform;
    }

    function set_colorTransform(c)
    {
        if (c == null) c = new Color(1, 1, 1, 1);

        colorTransform = c;
        alpha = c.a;
        invalidateColorTransform = true;
        onColorTransformChange.dispatch();

        return c;
    }

    function set_alpha(v:Float):Float
    {
        v = Color.clamp(v);
        if (v != colorTransform.a)
        {
            alpha = colorTransform.a = v;
            invalidateColorTransform = true;
            onColorTransformChange.dispatch();
        }

        return v;
    }
	
	private function getAABB(boundRect:Rectangle = null):Rectangle
	{
		if (boundRect == null)	boundRect = new Rectangle();
		boundRect.x = boundRect.y = boundRect.width = boundRect.height = 0;
		return boundRect;
	}
	
	public function getBounds(boundRect:Rectangle = null):Rectangle
	{
		if (boundRect == null)	boundRect = new Rectangle();
		if (numChildren == 0)	return getAABB(boundRect);
		
		boundRect.x = boundRect.y = boundRect.width = boundRect.height = 0;
		for (c in children) 
		{
			_boundRect2.x = _boundRect2.y = _boundRect2.width = _boundRect2.height = 0;
			_boundRect2 = c.getBounds(_boundRect2);
			
			var x0:Float = (boundRect.x > _boundRect2.x) ? _boundRect2.x : boundRect.x;
			var x1:Float = (boundRect.right < _boundRect2.right) ? _boundRect2.right : boundRect.right;
			var y0:Float = (boundRect.y > _boundRect2.y) ? _boundRect2.y : boundRect.y;
			var y1:Float = (boundRect.bottom < _boundRect2.bottom) ? _boundRect2.bottom : boundRect.bottom;
			boundRect.x = x0;
			boundRect.y = y0;
			boundRect.width = x1 - x0;
			boundRect.height = y1 - y0;
		}
		return boundRect;
	}
	
	public var width(get_width, null):Float;
	
	private function get_width():Float
	{
		return getBounds(_boundRect).width;
	}
	
	public var height(get_height, null):Float;
	
	private function get_height():Float
	{
		return getBounds(_boundRect).height;
	}

    public function toString()
    {
        var ref = Type.getClassName(Type.getClass(this)).split(".").pop();

        return Std.format("{$ref: $name, visible:$visible}");
    }
}