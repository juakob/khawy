package com.framework;

import haxe.io.BytesBuffer;
import haxe.io.Bytes;
#if INPUT_REC
import com.framework.utils.SaveFile;
#end
import com.framework.utils.Random;
import com.loading.ResourceHandler;
import com.framework.utils.Input;
import com.gEngine.GEngine;
import com.gEngine.helpers.Screen;
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
	var finishLoading:Bool;

	public var startingSeed:Float;

	public static var i:Simulation;

	public var manualLoad(get, set):Bool;
	public var noUnload(default, default):Bool;

	var mManualLoad:Bool;
	var iterationRest:Float = 0;
	var needRender:Bool;

	public function new(initialState:Class<State>, virtualWidth:Int, virtualHeight:Int, oversample:Float = 1, antiAlias:Int = 0) {
		startingSeed = 50;
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
		System.notifyOnApplicationState(
			onForeground, 
			onResume,     
			onPause,     
			onBackground, 
			onShutdown    
		);
	}

	private function onForeground() {
		//isPause = false;
        if (currentState != null) {
			currentState.onForeground();
		}
    }

    public function onResume() {
		//isPause = false;
        if (currentState != null) {
			currentState.onResume();
		}
    }

    public function onPause() {
		//isPause = true;
        if (currentState != null) {
			currentState.onPause();
		}
    }

    private function onBackground() {
		//isPause = true;
        if (currentState != null) {
			currentState.onBackground();
		}
    }

    private function onShutdown() {
        if (currentState != null) {
			currentState.onShutdown();
		}
    }

	private var mFrameByFrameTime:Float = 0;
	private var mLastFrameTime:Float = 0;
	private var mLastRealFrameTime:Float = 0;
	#if INPUT_REC
	var frameByFrame:Bool=false;
	function playRecord() {
		this.changeState(Type.createInstance(initialState, []));
		TimeManager.reset();
		Random.init(50);
		Input.i.playRecord();
		TimeManager.fixedTime=true;
	}
	#end

	private function onEnterFrame():Void {
		needRender=true;
		var time = Scheduler.time();
		mFrameByFrameTime = time - mLastFrameTime;
		mLastFrameTime = time;
		#if INPUT_REC
		if (Input.i.isKeyCodePressed(kha.input.KeyCode.F2) && Input.i.isKeyCodeDown(kha.input.KeyCode.Shift)) {
			playRecord();
			SaveFile.saveBytes(Input.i.serializeInputRecord().getBytes(),"savePlay","replay");
		}
		if(Input.i.isKeyCodePressed(kha.input.KeyCode.F3)&& Input.i.isKeyCodeDown(kha.input.KeyCode.Shift)){
			TimeManager.fixedTime=true;
			Input.i.startRecord();
		}
		if(Input.i.isKeyCodePressed(kha.input.KeyCode.F4)&& Input.i.isKeyCodeDown(kha.input.KeyCode.Shift)){
			SaveFile.openFile(function(stream:StreamReader) {
				Input.i.loadRecord(stream);
				playRecord();
			});
		}
		if(Input.i.isKeyCodePressed(kha.input.KeyCode.F1)){
			frameByFrame=!frameByFrame;
			TimeManager.fixedTime=!frameByFrame;
		}
		if(frameByFrame){
			if(Input.i.isKeyCodePressed(kha.input.KeyCode.F2)){
				mFrameByFrameTime=1/60;
			}else{
				mFrameByFrameTime=0;
			}
		}
		#end
		
		
		TimeManager.setDelta(mFrameByFrameTime);
		update(mFrameByFrameTime);
		
	
	}
	var skip_fame =true;
	function onRender(framebuffers:Array<Framebuffer>) {
		if (requestChangeState) {
			if(skip_fame){
				skip_fame =false;
				return;
			}
			requestChangeState = false;
			loadState(nextState);
			nextState = null;
		}
		if (!initialized){
			resources.update();
		}
		com.debug.Profiler.startMeasure("renderSim");
		var framebuffer = framebuffers[0];
		Input.i.screenScale.setTo(virtualWidth / framebuffer.width, virtualHeight / framebuffer.height);
		if (initialized) currentState.render();
		GEngine.i.draw(framebuffer,true,needRender);
		currentState.draw(framebuffer);
		if (isPause) {
			var g2:Graphics = framebuffer.g2;
			g2.begin(false);

			var width = framebuffer.width;
			var height = framebuffer.height;

			// Fondo gris semitransparente
			g2.color = Color.fromFloats(0.5, 0.5, 0.5, 0.5);
			g2.fillRect(0, 0, width, height); // Ahora cubre toda la pantalla correctamente

			// Dibujar triángulo de "play" en el centro
			g2.color = Color.fromFloats(1, 1, 1, 1);

			var centerX = width / 2;
			var centerY = height / 2;
			var size = 100; // Tamaño del triángulo

			g2.fillTriangle(
				centerX - size / 2, centerY - size,  // Punto izquierdo
				centerX + size / 2, centerY,         // Punta derecha
				centerX - size / 2, centerY + size   // Punto inferior izquierdo
			);

			g2.end();
		}
		needRender=false;
		com.debug.Profiler.endMeasure("renderSim");
	}

	private function update(dt:Float):Void {
		if (!initialized){
			if(finishLoading){
				initialized = true;
				currentState.init();
				GEngine.i.update();
				return;
			}
			if(currentState!=null){
				currentState.loading(resources.percentage());
			}	
			//resources.update();
			return;
		}
			
		var fullIterations = Math.floor(TimeManager.multiplier + iterationRest);
		if (!isPause) {
			for (i in 0...fullIterations) {
				#if INPUT_REC
				Input.i.updatePlayeback();
				#end
				Input.i.update();
				currentState.update(dt);
				GEngine.i.update();
				
			}
		}
		iterationRest = (TimeManager.multiplier + iterationRest) - fullIterations;
	}

	private function loadState(state:State):Void {
		initialized = false;
		if (currentState != null) {
			Input.i.clearInput();
			currentState.destroy();
			GEngine.i.unload();
			if(!noUnload){
				SM.reset();
				resources.unload();
				unloadResourceHandlers();
				
			}else{
				resources=new Resources();
			}
		}
		currentState = state;
		currentState.stage = GEngine.i.getStage();
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
		finishLoading = true;
	}

	public function changeState(state:State):Void {
		requestChangeState = true;
		nextState = state;
	}

}
