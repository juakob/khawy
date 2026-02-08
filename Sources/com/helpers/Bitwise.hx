package com.helpers;

class Bitwise {

    /** Devuelve true si el flag está activo */
    public static inline function has(value:Int, flag:Int):Bool {
        return (value & flag) != 0;
    }

    /** Activa un flag */
    public static inline function set(value:Int, flag:Int):Int {
        return value | flag;
    }

    /** Desactiva un flag */
    public static inline function clear(value:Int, flag:Int):Int {
        return value & ~flag;
    }

    /** Toggle (invierte el flag) */
    public static inline function toggle(value:Int, flag:Int):Int {
        return value ^ flag;
    }

    /** Setea o limpia según un Bool */
    public static inline function write(value:Int, flag:Int, enabled:Bool):Int {
        return enabled ? (value | flag) : (value & ~flag);
    }

    /** Devuelve true si TODOS los bits del mask están activos */
    public static inline function hasAll(value:Int, mask:Int):Bool {
        return (value & mask) == mask;
    }

    /** Devuelve true si ALGUNO está activo */
    public static inline function hasAny(value:Int, mask:Int):Bool {
        return (value & mask) != 0;
    }

    /** Limpia varios bits de una */
    public static inline function clearMask(value:Int, mask:Int):Int {
        return value & ~mask;
    }

    /** Crea un flag desde un índice (0-31) */
    public static inline function bit(index:Int):Int {
        return 1 << index;
    }
}
