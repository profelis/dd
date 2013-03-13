package deep.dd.utils;

import haxe.ds.GenericStack;

@:generic class FastListUtils<T>
{
    var l:GenericStack<T>;

    public function new(list:GenericStack<T>)
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
        if (length == 0) return false;

        if (tail.elt == v)
        {
            if (length == 1)
            {
                l.head = tail = null;
            }
            else
            {
                var prev = null;
                var h = l.head;
                while (h != null)
                {
                    tail = prev;
                    prev = h;
                    h = h.next;
                }
            }
            length --;
            return true;
        }
        var res = l.remove(v);
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