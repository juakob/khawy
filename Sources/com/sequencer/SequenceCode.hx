package com.sequencer;

/**
 * ...
 * @author Joaquin
 */
typedef Function = Dynamic->Bool;

class SequenceCode {
	private var functions:Array<Function>;
	private var waitTimes:Array<Float>;
	private var doForFunctions:Array<Function>;
	private var instant:Array<Bool>;
	private var condition:Array<Function>;
	private var anyFunctions:Array<Dynamic>;
	private var currentFunction:Function;

	public function new() {
		functions = new Array();
		waitTimes = new Array();
		doForFunctions = new Array();
		condition = new Array();
		instant = new Array();
		anyFunctions = new Array();
	}

	public function pushInstantFunction(func:Function, instant:Bool = false):Void {
		if (currentFunction != null) {
			functions.unshift(currentFunction);
			this.instant.unshift(instant);
		}
		currentFunction = func;
	}

	public function addFunction(func:Function, instant:Bool = false):Void {
		functions.push(func);
		this.instant.push(instant);
	}

	public function addFunctionDynamic(func:Dynamic, instant:Bool = false):Void {
		anyFunctions.push(func);
		addFunction(executeFunctionSingle, instant);
	}

	private function executeFunctionSingle(aDt:Float):Bool {
		(cast anyFunctions.shift())();
		return true;
	}

	public function addDoFor(func:Function, time:Float):Void {
		waitTimes.push(time);
		doForFunctions.push(func);
		addFunction(doFor);
	}

	private function doFor(aDt:Float):Bool {
		waitTimes[0] -= aDt;
		if (waitTimes[0] <= 0) {
			waitTimes.shift();
			doForFunctions.shift();
			return true;
		}
		doForFunctions[0](aDt);
		return false;
	}

	public function addWaitCondition(aCondition:Function):Void {
		condition.push(aCondition);
		addFunction(doWhileCondition);
	}

	private function doWhileCondition(aDt:Float):Bool {
		if (!condition[0](aDt)) {
			return false;
		}
		condition.shift();
		return true;
	}

	public function addWhile(aWhile:Function, aDo:Function):Void {
		doForFunctions.push(aDo);
		condition.push(aWhile);
		addFunction(doWhile);
	}

	private function doWhile(aDt:Float):Bool {
		if (condition[0](aDt)) {
			doForFunctions[0](aDt);
			return false;
		}
		condition.shift();
		doForFunctions.shift();
		return true;
	}

	public static var execute:Bool;

	public function update(aDt:Float):Void {
		do {
			execute = false;
			if ((currentFunction == null && functions.length > 0) || (currentFunction != null && currentFunction(aDt))) {
				currentFunction = null;
				if (functions.length > 0) {
					currentFunction = functions.shift();
					execute = instant.shift();
				}
			}
		} while (execute);
	}

	public function addIf(aCondition:Function, aDo:Function, aInstant:Bool = false):Void {
		condition.push(aCondition);
		addFunction(_if, true);
		addFunction(aDo, aInstant);
	}

	public function addIfelse(aCondition:Function, aDo:Function, aElse:Function, aInstant:Bool = false, aInstantElse:Bool = false):Void {
		condition.push(aCondition);
		addFunction(_if_else, true);
		addFunction(aDo, aInstant);
		addFunction(aElse, aInstantElse);
	}

	public function addWait(time:Float, breakCond:Function = null):Void {
		if (breakCond == null) {
			waitTimes.push(time);
			addFunction(wait);
		} else {
			waitTimes.push(time);
			condition.push(breakCond);
			addFunction(waitBreak);
		}
	}

	private function _if(aDt:Float):Bool {
		if (condition[0](aDt)) {
			condition.shift();
			return true;
		}
		condition.shift();
		functions.shift(); // delete if
		instant.shift();
		return true;
	}

	private function _if_else(aDt:Float):Bool {
		if (condition[0](aDt)) {
			condition.shift();
			functions.splice(1, 1); // delete else
			instant.splice(1, 1);
			return true;
		}
		condition.shift();
		functions.shift(); // delete if
		instant.shift();
		return true;
	}

	private function waitBreak(aDt:Float):Bool {
		waitTimes[0] -= aDt;
		if (waitTimes[0] <= 0 || condition[0](aDt)) {
			waitTimes.shift();
			condition.shift();
			return true;
		}
		return false;
	}

	private function wait(aDt:Float):Bool {
		waitTimes[0] -= aDt;
		if (waitTimes[0] <= 0) {
			waitTimes.shift();
			return true;
		}
		return false;
	}

	public function dispose():Void {
		flush();
	}

	public function flush():Void {
		functions.splice(0, functions.length);
		waitTimes.splice(0, waitTimes.length);
		doForFunctions.splice(0, doForFunctions.length);
		instant.splice(0, instant.length);
		condition.splice(0, condition.length);
		anyFunctions.splice(0, anyFunctions.length);
		currentFunction = null;
	}

	public function active():Bool {
		return functions.length + waitTimes.length > 0;
	}
}
