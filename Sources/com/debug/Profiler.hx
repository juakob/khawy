package com.debug;

import kha.Scheduler;

class Profiler {
	#if profile
	static var functionsTimes:Array<Array<Float>> = new Array();
	static var functionsNames:Array<String> = new Array();
	static var counter:Int=0;
	#end

	public inline static function startMeasure(name:String) {
		#if profile
		var index = functionsNames.indexOf(name);
		if (index < 0) {
			index = functionsNames.push(name) - 1;
			functionsTimes.push(new Array());
		}
		functionsTimes[index].push(Scheduler.realTime());
		++counter;
		#end
	}

	public inline static function endMeasure(name:String) {
		#if profile
		var time = Scheduler.realTime();
		var index = functionsNames.indexOf(name);
		if (index >= 0) {
			var times = functionsTimes[index];
			var endIndex = times.length - 1;
			var startTime = times[endIndex];
			times[endIndex] = time - startTime;
		}else{
			throw "call startMeasure before ending it";
		}
		--counter;
		#end
	}

	public inline static function show() {
		#if (!worker && profile)
		if(counter!=0){
			throw  "close all measures before calling show";
		}
		trace("Profiler///////////////////////////////");
		var i:Int = 0;
		for (name in functionsNames) {
			var activeTime:Float = 0;
			var times:Array<Float> = functionsTimes[i];
			for (time in times) {
				activeTime += time;
			}
			trace(name + " total: " + activeTime + " avg: " + activeTime / times.length + " frame% " + (activeTime / times.length) / (1 / 60));
			++i;
		}
		#end
	}

	public inline static function clear() {
		#if profile
		functionsNames.splice(0, functionsNames.length);
		functionsTimes.splice(0, functionsTimes.length);
		#end
	}
}
