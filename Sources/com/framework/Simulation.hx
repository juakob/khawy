package com.framework;

import com.loading.ResourceHandler;
import com.framework.utils.Input;
import com.gEngine.GEngine;
import com.gEngine.helper.Screen;
import com.loading.Resources;
import com.soundLib.SoundManager.SM;
import kha.Color;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.graphics2.Graphics;
import kha.math.FastMatrix3;
import com.framework.utils.State;

class Simulation {
	public var currentState(default, null):State;

	var isPause:Bool;
	var nextState:State;
	var requestChangeState:Bool;
	var virtualWidth:Int;
	var virtualHeight:Int;
	var initialState:Class<State>;
	var initialized:Bool = false;
	var initState:Bool = false;
	var resources:Resources;
	var resourcesHandlers:Array<ResourceHandler>;
	public var startingSeed:Float;

	public static var i:Simulation;

	public var manualLoad(get, set):Bool;

	var mManualLoad:Bool;
	var iterationRest:Float = 0;

	public function new(initialState:Class<State>, virtualWidth:Int, virtualHeight:Int, oversample:Float = 1, antiAlias:Int = 0) {
		startingSeed=Math.random()*3000;
		com.framework.utils.Random.init(Std.int(startingSeed));
		this.initialState = initialState;
		resourcesHandlers = new Array();
		i = this;

		this.virtualHeight = virtualHeight;
		this.virtualWidth = virtualWidth;

		resources = new Resources();

		Input.init();
		Input.i.screenScale.x = virtualWidth / Screen.getWidth();
		Input.i.screenScale.y = virtualHeight / Screen.getHeight();

		GEngine.init(virtualWidth, virtualHeight, oversample, antiAlias);
		GEngine.i.createDefaultPainters();
		SM.init();
		init();
	}

	function get_manualLoad():Bool {
		return mManualLoad;
	}

	function set_manualLoad(aValue:Bool):Bool {
		mManualLoad = aValue;
		resources.keepData = aValue;
		return mManualLoad;
	}

	private function init():Void {
		this.changeState(Type.createInstance(initialState, []));

		Scheduler.addTimeTask(onEnterFrame, 0, 1 / 60);
		System.notifyOnFrames(onRender);
	}

	private function onDeactivate():Void {
		if (currentState != null) {
			currentState.onDesactivate();
		}
	}

	private function onActive():Void {
		if (currentState != null) {
			currentState.onActivate();
		}
	}

	private var mFrameByFrameTime:Float = 0;
	private var mLastFrameTime:Float = 0;
	private var mLastRealFrameTime:Float = 0;

	private function onEnterFrame():Void {
		#if debug
		if (Input.i.isKeyCodePressed(kha.input.KeyCode.F2) && Input.i.isKeyCodeDown(kha.input.KeyCode.Shift)) {
			this.changeState(Type.createInstance(initialState, []));
		}
		#end
		Input.i.screenScale.setTo(virtualWidth / System.windowWidth(0), virtualHeight / System.windowHeight(0));
		var time = Scheduler.time();
		mFrameByFrameTime = time - mLastFrameTime;
		mLastFrameTime = time;
		if (!isPause) {
			TimeManager.setDelta(mFrameByFrameTime, Scheduler.realTime());
			update(mFrameByFrameTime);
		}
		if (requestChangeState) {
			requestChangeState = false;
			loadState(nextState);
			nextState = null;
			return;
		}
	}

	function onRender(framebuffers:Array<Framebuffer>) {
		var framebuffer = framebuffers[0];

		if (!initialized)
			return;
		currentState.render();
		GEngine.i.draw(framebuffer);
		currentState.draw(framebuffer);
		if (isPause) {
			var g2:Graphics = framebuffer.g2;
			g2.begin(false);

			g2.transformation = FastMatrix3.scale(0.75, 0.75);
			g2.color = Color.fromFloats(0.5, 0.5, 0.5, 0.5);
			g2.fillRect(0, 0, 1280, 720);

			g2.color = Color.fromFloats(1, 1, 1, 1);
			g2.fillTriangle(485, 270, 740, 390, 485, 510);

			g2.end();
		}
	}

	private function update(dt:Float):Void {
		if (!initialized)
			return;
		var fullIterations = Math.floor(TimeManager.multiplier + iterationRest);
		for (i in 0...fullIterations) {
			currentState.update(dt);
			GEngine.i.update();
			Input.i.update();
		}
		iterationRest = (TimeManager.multiplier + iterationRest) - fullIterations;
	}

	private function loadState(state:State):Void {
		initialized = false;
		if (currentState != null) {
			SM.reset();
			Input.i.clearInput();
			currentState.destroy();
			resources.unload();
			unloadResourceHandlers();
			GEngine.i.unload();
		}
		currentState = state;
		currentState.load(resources);
		if (manualLoad) {
			resources.loadLocal(finishUpload);
		} else {
			resources.load(finishUpload);
		}
	}

	public function addResourceHandler(resourceHandler:ResourceHandler) {
		resourcesHandlers.push(resourceHandler);
	}

	function unloadResourceHandlers() {
		for (resourceHandler in resourcesHandlers) {
			resourceHandler.clear();
		}
	}

	private function finishUpload():Void {
		initialized = true;
		currentState.stage = GEngine.i.getStage();
		currentState.init();
	}

	public function changeState(state:State):Void {
		requestChangeState = true;
		nextState = state;
	}

	public function pause():Void {
		isPause = true;
		if (currentState != null) {
			currentState.onDesactivate();
		}
	}

	public function unpause():Void {
		isPause = false;
		if (currentState != null) {
			currentState.onActivate();
		}
	}
}
