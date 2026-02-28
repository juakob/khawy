package com.debug;

import kha.Scheduler;
import StringTools;

class Profiler {
	#if (profile || profile_light || profile_deep)
	static inline var TARGET_FRAME_TIME:Float = 1 / 60;
	static inline var SMOOTH_FACTOR:Float = 0.18;
	static inline var HISTORY_LIMIT:Int = 180;
	static inline var RENDER_BREAKDOWN_LIMIT:Int = 8;

	static var functionsNames:Array<String> = new Array();
	static var functionsTimes:Array<Float> = new Array();
	static var functionsCalls:Array<Int> = new Array();

	static var displayTimes:Array<Float> = new Array();
	static var displayCalls:Array<Int> = new Array();
	static var smoothTimes:Array<Float> = new Array();

	static var lifetimeTimes:Array<Float> = new Array();
	static var lifetimeCalls:Array<Int> = new Array();

	static var openTimes:Array<Array<Float>> = new Array();

	static var frameTime:Float = 0;
	static var smoothFrameTime:Float = 0;
	static var maxFrameTime:Float = 0;
	static var lastFrameTimestamp:Float = 0;

	static var overlayVisible:Bool = true;
	static var overlayCompact:Bool = true;
	static var graphVisible:Bool = true;
	static var clearPending:Bool = false;

	static var frameHistoryMs:Array<Float> = new Array();
	static var updateHistoryMs:Array<Float> = new Array();
	static var renderHistoryMs:Array<Float> = new Array();
	static var idleHistoryMs:Array<Float> = new Array();

	static var profilerBeginCostMs:Float = 0;
	static var profilerOverlayCostMs:Float = 0;
	static var profilerSmoothCostMs:Float = 0;
	static var captureFrozen:Bool = false;
	static var renderBreakdownIndices:Array<Int> = new Array();
	static var renderTotalMs:Float = 0;

	static var counter:Int = 0;
	#end

	#if (profile || profile_light || profile_deep)
	static inline function round2(value:Float):Float {
		return Math.round(value * 100) / 100;
	}

	static inline function profileModeLabel():String {
		#if profile_light
		return "LIGHT";
		#elseif profile_deep
		return "DEEP";
		#elseif profile
		return "DEEP";
		#else
		return "OFF";
		#end
	}

	static inline function shouldTrack(name:String):Bool {
		#if profile_light
		return name == "enterFrame" || name == "updateSim" || name == "renderSim" || name == "gengineDraw" || name == "stateRender"
			|| name == "stateDraw" || name == "swfUpdate" || name == "swfFrameJump" || name == "swfFrameChange" || name == "resourcesUpdate";
		#else
		return true;
		#end
	}

	static function getFunctionIndex(name:String):Int {
		var index = functionsNames.indexOf(name);
		if (index < 0) {
			index = functionsNames.push(name) - 1;
			functionsTimes.push(0);
			functionsCalls.push(0);
			displayTimes.push(0);
			displayCalls.push(0);
			smoothTimes.push(0);
			lifetimeTimes.push(0);
			lifetimeCalls.push(0);
			openTimes.push(new Array());
		}
		return index;
	}

	static function sortedIndicesByFrameTime():Array<Int> {
		var ids:Array<Int> = new Array();
		for (i in 0...functionsNames.length) {
			ids.push(i);
		}
		ids.sort(function(a:Int, b:Int):Int {
			var diff = displayTimes[b] - displayTimes[a];
			if (diff > 0) {
				return 1;
			}
			if (diff < 0) {
				return -1;
			}
			return 0;
		});
		return ids;
	}

	static function buildBar(ratio:Float, size:Int):String {
		var safeRatio = ratio;
		if (safeRatio < 0) {
			safeRatio = 0;
		}
		if (safeRatio > 1.5) {
			safeRatio = 1.5;
		}
		var fill:Int = Std.int(Math.round(safeRatio * size));
		if (fill > size) {
			fill = size;
		}
		var bar = "";
		for (i in 0...size) {
			bar += i < fill ? "|" : ".";
		}
		return bar;
	}

	static inline function resetData():Void {
		functionsNames.splice(0, functionsNames.length);
		functionsTimes.splice(0, functionsTimes.length);
		functionsCalls.splice(0, functionsCalls.length);
		displayTimes.splice(0, displayTimes.length);
		displayCalls.splice(0, displayCalls.length);
		smoothTimes.splice(0, smoothTimes.length);
		lifetimeTimes.splice(0, lifetimeTimes.length);
		lifetimeCalls.splice(0, lifetimeCalls.length);
		openTimes.splice(0, openTimes.length);
		frameTime = 0;
		smoothFrameTime = 0;
		maxFrameTime = 0;
		lastFrameTimestamp = 0;
		counter = 0;
		frameHistoryMs.splice(0, frameHistoryMs.length);
		updateHistoryMs.splice(0, updateHistoryMs.length);
		renderHistoryMs.splice(0, renderHistoryMs.length);
		idleHistoryMs.splice(0, idleHistoryMs.length);
		renderBreakdownIndices.splice(0, renderBreakdownIndices.length);
		renderTotalMs = 0;
	}

	static inline function flushPendingClear():Void {
		if (clearPending && counter == 0) {
			clearPending = false;
			resetData();
		}
	}

	static inline function pushHistory(target:Array<Float>, value:Float):Void {
		target.push(value);
		if (target.length > HISTORY_LIMIT) {
			target.shift();
		}
	}

	static inline function getDisplayMs(name:String):Float {
		var index = functionsNames.indexOf(name);
		if (index < 0) {
			return 0;
		}
		return displayTimes[index] * 1000;
	}

	static inline function isRenderMeasure(name:String):Bool {
		if (name == "renderSim" || name == "gengineDraw" || name == "stateRender" || name == "stateDraw" || name == "pauseOverlay") {
			return true;
		}
		if (StringTools.startsWith(name, "swf")) {
			return true;
		}
		return StringTools.startsWith(name, "render");
	}

	static function updateRenderBreakdown():Void {
		renderBreakdownIndices.splice(0, renderBreakdownIndices.length);
		renderTotalMs = getDisplayMs("renderSim");
		var candidates:Array<Int> = new Array();
		for (i in 0...functionsNames.length) {
			var name = functionsNames[i];
			if (!isRenderMeasure(name) || displayTimes[i] <= 0 || name == "renderSim") {
				continue;
			}
			candidates.push(i);
		}
		candidates.sort(function(a:Int, b:Int):Int {
			var diff = displayTimes[b] - displayTimes[a];
			if (diff > 0) {
				return 1;
			}
			if (diff < 0) {
				return -1;
			}
			return 0;
		});
		for (i in 0...candidates.length) {
			if (i >= RENDER_BREAKDOWN_LIMIT) {
				break;
			}
			renderBreakdownIndices.push(candidates[i]);
		}
		if (renderBreakdownIndices.length == 0) {
			var renderIndex = functionsNames.indexOf("renderSim");
			if (renderIndex >= 0 && displayTimes[renderIndex] > 0) {
				renderBreakdownIndices.push(renderIndex);
			}
		}
	}

	static function recordFrameHistory():Void {
		if (frameTime <= 0) {
			return;
		}
		var frameMs = frameTime * 1000;
		var updateMs = getDisplayMs("updateSim");
		var renderMs = getDisplayMs("renderSim");
		if (updateMs < 0) {
			updateMs = 0;
		}
		if (renderMs < 0) {
			renderMs = 0;
		}
		var tracked = updateMs + renderMs;
		if (tracked > frameMs && tracked > 0) {
			var factor = frameMs / tracked;
			updateMs *= factor;
			renderMs *= factor;
			tracked = frameMs;
		}
		var idleMs = frameMs - tracked;
		if (idleMs < 0) {
			idleMs = 0;
		}
		pushHistory(frameHistoryMs, frameMs);
		pushHistory(updateHistoryMs, updateMs);
		pushHistory(renderHistoryMs, renderMs);
		pushHistory(idleHistoryMs, idleMs);
	}
	#end

	public inline static function startMeasure(name:String) {
		#if (profile || profile_light || profile_deep)
		if (!shouldTrack(name)) {
			return;
		}
		flushPendingClear();
		var index = getFunctionIndex(name);
		openTimes[index].push(Scheduler.realTime());
		++counter;
		#end
	}

	public inline static function endMeasure(name:String) {
		#if (profile || profile_light || profile_deep)
		if (!shouldTrack(name)) {
			return;
		}
		var time = Scheduler.realTime();
		var index = functionsNames.indexOf(name);
		if (index >= 0) {
			var times = openTimes[index];
			var endIndex = times.length - 1;
			if (endIndex < 0) {
				throw "call startMeasure before ending it";
			}
			var startTime = times[endIndex];
			times.pop();
			var duration = time - startTime;
			functionsTimes[index] += duration;
			functionsCalls[index] += 1;
			lifetimeTimes[index] += duration;
			lifetimeCalls[index] += 1;
		}else{
			throw "call startMeasure before ending it";
		}
		--counter;
		flushPendingClear();
		#end
	}

	public inline static function beginFrame() {
		#if (profile || profile_light || profile_deep)
		var profilerStart = Scheduler.realTime();
		flushPendingClear();
		if (captureFrozen) {
			for (i in 0...functionsNames.length) {
				functionsTimes[i] = 0;
				functionsCalls[i] = 0;
			}
			var frozenCost = (Scheduler.realTime() - profilerStart) * 1000;
			profilerBeginCostMs = frozenCost;
			if (profilerSmoothCostMs == 0) {
				profilerSmoothCostMs = frozenCost;
			} else {
				profilerSmoothCostMs += (frozenCost - profilerSmoothCostMs) * 0.2;
			}
			return;
		}
		var now = Scheduler.realTime();
		if (lastFrameTimestamp > 0) {
			frameTime = now - lastFrameTimestamp;
			if (smoothFrameTime == 0) {
				smoothFrameTime = frameTime;
			} else {
				smoothFrameTime += (frameTime - smoothFrameTime) * SMOOTH_FACTOR;
			}
			if (frameTime > maxFrameTime) {
				maxFrameTime = frameTime;
			}
		}
		lastFrameTimestamp = now;

		for (i in 0...functionsNames.length) {
			displayTimes[i] = functionsTimes[i];
			displayCalls[i] = functionsCalls[i];
			if (displayTimes[i] > 0) {
				if (smoothTimes[i] == 0) {
					smoothTimes[i] = displayTimes[i];
				} else {
					smoothTimes[i] += (displayTimes[i] - smoothTimes[i]) * SMOOTH_FACTOR;
				}
			} else {
				smoothTimes[i] *= 0.94;
			}
			functionsTimes[i] = 0;
			functionsCalls[i] = 0;
		}
		updateRenderBreakdown();
		recordFrameHistory();
		var profilerCost = (Scheduler.realTime() - profilerStart) * 1000;
		profilerBeginCostMs = profilerCost;
		if (profilerSmoothCostMs == 0) {
			profilerSmoothCostMs = profilerCost;
		} else {
			profilerSmoothCostMs += (profilerCost - profilerSmoothCostMs) * 0.2;
		}
		#end
	}

	public inline static function getOverlayLines(maxRows:Int = 8, barSize:Int = 18):Array<String> {
		#if (!worker && (profile || profile_light || profile_deep))
		var overlayStart = Scheduler.realTime();
		var lines:Array<String> = new Array();
		if (!overlayVisible) {
			return lines;
		}
		lines.push("profile[" + profileModeLabel() + "] F6:show F7:clear F8:compact F9:graph F10:freeze");
		if (captureFrozen) {
			lines.push("CAPTURE FROZEN");
		}

		var frameMs = frameTime * 1000;
		var smoothFrameMs = smoothFrameTime * 1000;
		var framePercent60 = TARGET_FRAME_TIME > 0 ? (frameTime / TARGET_FRAME_TIME) * 100 : 0;
		var framePercent30 = TARGET_FRAME_TIME > 0 ? (frameTime / (TARGET_FRAME_TIME * 2)) * 100 : 0;
		if (overlayCompact) {
			lines.push("frame " + round2(frameMs) + "ms avg " + round2(smoothFrameMs) + "ms 60:" + round2(framePercent60) + "% 30:" + round2(framePercent30) + "%");
		} else {
			lines.push("frame " + round2(frameMs) + "ms 60:" + round2(framePercent60) + "% 30:" + round2(framePercent30) + "% avg " + round2(smoothFrameMs) + "ms max " + round2(maxFrameTime * 1000) + "ms");
		}
		lines.push("profiler begin:" + round2(profilerBeginCostMs) + "ms ui:" + round2(profilerOverlayCostMs) + "ms avg:" + round2(profilerSmoothCostMs) + "ms");

		#if profile_light
		var updateMs = getDisplayMs("updateSim");
		var renderMs = getDisplayMs("renderSim");
		var idleMs = frameMs - updateMs - renderMs;
		if (idleMs < 0) {
			idleMs = 0;
		}
		var pUpdate = frameMs > 0 ? (updateMs / frameMs) * 100 : 0;
		var pRender = frameMs > 0 ? (renderMs / frameMs) * 100 : 0;
		var pIdle = frameMs > 0 ? (idleMs / frameMs) * 100 : 0;
		lines.push("update " + round2(updateMs) + "ms (" + round2(pUpdate) + "%) render " + round2(renderMs) + "ms (" + round2(pRender) + "%) idle " + round2(idleMs) + "ms (" + round2(pIdle) + "%)");
		profilerOverlayCostMs = (Scheduler.realTime() - overlayStart) * 1000;
		return lines;
		#end

		var sortedIndices = sortedIndicesByFrameTime();
		var added:Int = 0;
		for (index in sortedIndices) {
			if (displayCalls[index] == 0 && smoothTimes[index] <= 0) {
				continue;
			}
			var frameCostMs = displayTimes[index] * 1000;
			var avgCallMs = displayCalls[index] > 0 ? frameCostMs / displayCalls[index] : 0;
			if (overlayCompact) {
				lines.push(functionsNames[index] + " " + round2(frameCostMs) + "ms");
			} else {
				var ratio = TARGET_FRAME_TIME > 0 ? displayTimes[index] / TARGET_FRAME_TIME : 0;
				lines.push(functionsNames[index] + " " + round2(frameCostMs) + "ms x" + displayCalls[index] + " avg " + round2(avgCallMs) + " " + buildBar(ratio, barSize));
			}
			++added;
			if (added >= maxRows) {
				break;
			}
		}

		if (added == 0) {
			lines.push("no samples yet");
		}
		profilerOverlayCostMs = (Scheduler.realTime() - overlayStart) * 1000;
		return lines;
		#else
		return [];
		#end
	}

	public inline static function toggleOverlay():Bool {
		#if (profile || profile_light || profile_deep)
		overlayVisible = !overlayVisible;
		return overlayVisible;
		#else
		return false;
		#end
	}

	public inline static function toggleCompact():Bool {
		#if (profile || profile_light || profile_deep)
		overlayCompact = !overlayCompact;
		return overlayCompact;
		#else
		return false;
		#end
	}

	public inline static function toggleGraph():Bool {
		#if (profile || profile_light || profile_deep)
		graphVisible = !graphVisible;
		return graphVisible;
		#else
		return false;
		#end
	}

	public inline static function isGraphVisible():Bool {
		#if (profile || profile_light || profile_deep)
		return graphVisible;
		#else
		return false;
		#end
	}

	public inline static function toggleFreeze():Bool {
		#if (profile || profile_light || profile_deep)
		captureFrozen = !captureFrozen;
		return captureFrozen;
		#else
		return false;
		#end
	}

	public inline static function isFrozen():Bool {
		#if (profile || profile_light || profile_deep)
		return captureFrozen;
		#else
		return false;
		#end
	}

	public inline static function getRenderBreakdownCount():Int {
		#if (profile || profile_light || profile_deep)
		return renderBreakdownIndices.length;
		#else
		return 0;
		#end
	}

	public inline static function getRenderBreakdownName(index:Int):String {
		#if (profile || profile_light || profile_deep)
		if (index < 0 || index >= renderBreakdownIndices.length) {
			return "";
		}
		return functionsNames[renderBreakdownIndices[index]];
		#else
		return "";
		#end
	}

	public inline static function getRenderBreakdownMs(index:Int):Float {
		#if (profile || profile_light || profile_deep)
		if (index < 0 || index >= renderBreakdownIndices.length) {
			return 0;
		}
		return displayTimes[renderBreakdownIndices[index]] * 1000;
		#else
		return 0;
		#end
	}

	public inline static function getRenderBreakdownPercent(index:Int):Float {
		#if (profile || profile_light || profile_deep)
		if (renderTotalMs <= 0) {
			return 0;
		}
		return getRenderBreakdownMs(index) * 100 / renderTotalMs;
		#else
		return 0;
		#end
	}

	public inline static function getRenderTotalMs():Float {
		#if (profile || profile_light || profile_deep)
		return renderTotalMs;
		#else
		return 0;
		#end
	}

	public inline static function getFrameHistory():Array<Float> {
		#if (profile || profile_light || profile_deep)
		return frameHistoryMs;
		#else
		return [];
		#end
	}

	public inline static function getUpdateHistory():Array<Float> {
		#if (profile || profile_light || profile_deep)
		return updateHistoryMs;
		#else
		return [];
		#end
	}

	public inline static function getRenderHistory():Array<Float> {
		#if (profile || profile_light || profile_deep)
		return renderHistoryMs;
		#else
		return [];
		#end
	}

	public inline static function getIdleHistory():Array<Float> {
		#if (profile || profile_light || profile_deep)
		return idleHistoryMs;
		#else
		return [];
		#end
	}

	public inline static function getBudget60Ms():Float {
		#if (profile || profile_light || profile_deep)
		return TARGET_FRAME_TIME * 1000;
		#else
		return 16.6667;
		#end
	}

	public inline static function getBudget30Ms():Float {
		#if (profile || profile_light || profile_deep)
		return TARGET_FRAME_TIME * 2000;
		#else
		return 33.3334;
		#end
	}

	public inline static function show() {
		#if (!worker && (profile || profile_light || profile_deep))
		if(counter!=0){
			throw  "close all measures before calling show";
		}
		trace("Profiler///////////////////////////////");
		var i:Int = 0;
		for (name in functionsNames) {
			var activeTime:Float = lifetimeTimes[i];
			var calls:Int = lifetimeCalls[i];
			if (calls > 0) {
				trace(name + " total: " + activeTime + " avg: " + activeTime / calls + " frame% " + 100 * ((activeTime / calls) / TARGET_FRAME_TIME));
			}
			++i;
		}
		#end
	}

	public inline static function clear() {
		#if (profile || profile_light || profile_deep)
		if (counter > 0) {
			clearPending = true;
			return;
		}
		resetData();
		#end
	}
}
