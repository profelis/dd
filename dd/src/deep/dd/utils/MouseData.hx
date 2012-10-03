package deep.dd.utils;

class MouseData
{
    public var touch:Bool = false;
    public var pointId:Null<Int> = null;

    public var shift:Bool = false;
    public var alt:Bool = false;
    public var ctrl:Bool = false;

    public var type:String;

    public function new() {
    }

    public function toString()
    {
        var s = Std.format("{MouseData: $type shift: $shift, alt: $alt, ctrl: $ctrl");
        if (touch) s += "touchIdx: " + pointId;
        return s + "}";
    }
}


