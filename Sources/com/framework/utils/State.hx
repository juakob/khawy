package com.framework.utils;

import com.gEngine.display.Stage;
import com.framework.Simulation;
import com.gEngine.GEngine;
import com.loading.Resources;
import kha.Canvas;
import kha.Color;
import kha.Framebuffer;

class State extends Entity {
	public var stage:Stage;
	public var timeScale(default, set):Float = 1;

	var subStates:Array<State>;
	var parentState:State;
	var resources:Resources;

	public function new() {
		super();
		subStates = new Array();
	}

	public function load(resources:Resources):Void {}

	public function init():Void {}

	public function addSubState(state:State):Void {
		#if debug
		if (state.resources == null)
			throw "call initSubState from parent befour adding";
		#end
		subStates.push(state);
		state.parentState = this;
		stage.addSubStage(state.stage);
	}

	public function removeSubState(state:State):Void {
		subStates.remove(state);
		stage.removeSubStage(state.stage);
		state.parentState = null;
		state.die();
		state.destroy();
	}

	public function initSubState(state:State) {
		state.resources = new Resources();
		state.load(state.resources);
		state.stage = new Stage();
		state.resources.load(function() {
			state.init();
		});
	}

	public function changeState(state:State):Void {
		Simulation.i.changeState(state);
	}

	public function stageColor(r:Float = 0, g:Float = 0, b:Float = 0, a:Float = 1) {
		stage.color = Color.fromFloats(r, g, b, a);
	}

	public function draw(framebuffer:Canvas):Void {
		for (state in subStates) {
			state.draw(framebuffer);
		}
	}

	public function onActivate() {}

	public function onDesactivate() {}

	public function onMessage(message:Dynamic) {}

	override public function destroy():Void {
		if (resources != null) {
			resources.unload();
		}

		while(subStates.length>0){
			removeSubState(subStates[0]);
		}
		stage.destroy();
		if (parentState != null) {
			parentState.removeSubState(this);
		}
		super.destroy();
	}

	override function update(dt:Float) {
		var dt=TimeManager.delta * timeScale;
		super.update(dt);
		for(state in subStates){
			state.update(dt);
		}
	}

	public function set_timeScale(scale:Float):Float {
		timeScale = scale;
		stage.timeScale = scale;
		return scale;
	}
}
