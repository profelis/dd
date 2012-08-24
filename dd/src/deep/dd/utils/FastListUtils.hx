package deep.dd.utils;

import haxe.rtti.Generic;
import haxe.FastList;
import haxe.FastList.FastCell;

class FastListUtils<T> implements Generic
{
    var l:FastList<T>;

    public function new(list:FastList<T>)
    {
        l = list;
        #if debug
        if (l.head != null) throw "list must be empty";
        #end
    }

    public var tail:FastCell<T>;

    public function push(v:T)
    {
        if (tail != null)
        {
            var i = new FastCell<T>(v, null);
            tail.next = i;
            tail = i;
        }
        else
        {
            l.add(v);
            tail = l.head;
        }
        length++;
    }

    public var length(default, null):UInt = 0;

    public function indexOf(v:T):Int
    {
        var h = l.head;
        var idx = 0;
        while (h != null)
        {
            if (h.elt == v) return idx;
            h = h.next;
            idx ++;
        }
        return -1;
    }

    public function remove(v:T):Bool
    {
        if (tail.elt == v)
        {
            l.remove(v);
            if (l.head != null)
            {
                var h = l.head;
                while (h != null)
                {
                    tail = h;
                    h = h.next;
                }
            }
            else
            {
                tail = null;
            }
            length --;
            return true;
        }
        untyped trace(l.head.elt.extra);
        var res = l.remove(v);

        trace("remove " + res);
        untyped trace(l.head.elt.extra);
        if (res) length --;
        return res;
    }

    public function getAt(pos:UInt):Null<T>
    {
        #if debug
        if (pos >= length) throw "out of bounds";
        #end
        if (pos == 0) return l.first();
        if (pos == untyped length-1) return tail != null ? tail.elt : null;

        var h = l.head;
        while (h != null)
        {
            if (pos == 0) return h.elt;
            h = h.next;
            pos --;
        }
        return null;
    }

    public function putAt(v:T, pos:UInt)
    {
        #if debug
        if (pos > length) throw "out of bounds";
        #end

        if (pos == length)   // 0==0 correct
        {
            push(v);
            return;
        }
        if (pos == 0)
        {
            l.add(v);
            length ++;
            return;
        }

        pos --;
        var h = l.head;
        while (h != null)
        {
            if (pos == 0) break;
            h = h.next;
            pos --;
        }

        var i = new FastCell<T>(v, h.next);
        h.next = i;
        length ++;
    }

}