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
	public var timeScale(default,set):Float=1;

	var subStates:Array<State>;
	var resources:Resources;

	public function new() {
		super();
	}

	public function load(resources:Resources):Void {}

	public function init():Void {}

	public function addSubState(state:State):Void {
		addChild(state);
		state.subStageInit(stage);
	}
	
	
	function subStageInit(parentStage:Stage){
		resources=new Resources();
		load(resources);
		this.stage=new Stage();
		parentStage.addSubStage(this.stage);
		resources.load(init);
		
	}

	public function changeState(state:State):Void {
		Simulation.i.changeState(state);
	}

	public function stageColor(r:Float = 0, g:Float = 0, b:Float = 0, a:Float = 1) {
		stage.color=Color.fromFloats(r,g,b,a);
	}

	public function draw(framebuffer:Canvas):Void {}

	public function onActivate() {}

	public function onDesactivate() {}

	public function onMessage(message:Dynamic) {
		
	}

	override public function destroy():Void {
		
		if(Std.is(parent,State)){
			(cast parent).stage.removeSubStage(stage);
		}
		if(resources!=null){
			resources.unload();
		}
		super.destroy();
	}
	override function update(dt:Float) {
		super.update(TimeManager.delta*timeScale);
	}
	public function set_timeScale(scale:Float):Float {
		timeScale=scale;
		stage.timeScale=scale;
		return scale;
	}
}
