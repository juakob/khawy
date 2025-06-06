package com.gEngine.helpers;

import kha.math.FastMatrix4;
import kha.math.FastMatrix3;

class FastMatrix {
	public inline static function from4x4To3x3(t:FastMatrix4):FastMatrix3 {
		return new FastMatrix3(t._00, t._10, t._30, t._01, t._11, t._31, t._02, t._12, t._33);
	}

	public inline static function from3x3To4x4(t:FastMatrix3):FastMatrix4 {
		return new FastMatrix4(t._00, t._10, 0, t._20, t._01, t._11, 0, t._21, t._02, t._12, 0, 0, 0, 0, 0, t._22);
	}

	public static inline function fromMatrix3(m: FastMatrix3): FastMatrix4 {
		return new FastMatrix4(
			m._00, m._10, 0, m._20,
			m._01, m._11, 0, m._21,
			0,    0,    1, 0,
			m._02, m._12, 0, m._22
		);
	}
}
