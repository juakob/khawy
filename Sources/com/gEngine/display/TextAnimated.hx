package com.gEngine.display;

import com.panelUI.Component;
import com.panelUI.ComponentLinker;
import com.panelUI.ITransition;
import com.panelUI.Transition;
import com.panelUI.TransitionPlayer;

/**
 * ...
 * @author Joaquin
 */
class TextAnimated extends Text {
	private var player:TransitionPlayer;

	public function new(type:String, text:String, aWidth:Float, aHeigthSeparation:Float = 10, aSeparation:Float = 1,
			transitionFunction:Component->Int->Array<ITransition>) {
		super(type, aWidth, aHeigthSeparation, aSeparation);
		this.text = text;
		player = new TransitionPlayer();
		for (i in 0...this.mLetters.length) {
			var sprite = getLetter(i);
			var transitions = transitionFunction(new ComponentLinker(sprite), i);

			for (transition in transitions) {
				player.addTransition(transition);
			}
		}
	}

	override public function update(passedTime:Float):Void {
		player.update(passedTime);
		super.update(passedTime);
	}
}
