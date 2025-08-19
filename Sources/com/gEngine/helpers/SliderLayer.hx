package com.gEngine.helpers;

import com.framework.utils.Input;
import com.gEngine.display.Layer;

class SliderLayer extends Layer {
    var startMouseY: Float = 0; // Posición inicial del mouse
    var startY: Float = 0; // Posición inicial de la capa
    var velocity: Float = 0; // Velocidad del scroll
    public var limitMin: Float = 0; // Límite superior
    public var limitMax: Float = 500; // Límite inferior
    var damping: Float = 0.6; // Amortiguación del movimiento
    var elasticity: Float = 0.1; // Fuerza de elasticidad
    var resistanceFactor: Float = 4; // Factor de resistencia progresiva
    var isDragging: Bool = false; // Para saber si estamos arrastrando

    public function new(limitMin: Float, limitMax: Float) {
        super();
        this.limitMin = limitMin;
        this.limitMax = limitMax;
    }

    override public function update(dt: Float) {
        var skip1Frame:Bool=false;
        if (Input.i.isMouseDown()) { // Si el mouse está presionado
            if (Input.i.isMousePressed()) { // Si recién lo presionamos
                startMouseY = Input.i.getMouseY();
                startY = y;
                velocity = 0; // Detenemos el movimiento
                
            } else { // Mientras lo arrastramos
                var last= isDragging;
                isDragging = isDragging ||Math.abs(Input.i.getMouseY()-startMouseY)>33;
                if(!last&&isDragging){//avoid jump
                    startMouseY = Input.i.getMouseY();
                }
                if(isDragging){
                    var deltaY = Input.i.getMouseY() - startMouseY;
                    var newY = startY + deltaY;

                    if (newY < limitMin) { // Si nos pasamos del límite superior
                        var excess = limitMin - newY;
                        newY = limitMin - applyResistance(excess);
                    } else if (newY > limitMax) { // Si nos pasamos del límite inferior
                        var excess = newY - limitMax;
                        newY = limitMax + applyResistance(excess);
                    }
                    y = newY;
                }
            }
        } else { // Si soltamos el mouse
            skip1Frame = isDragging && Input.i.isMouseReleased();

            isDragging = false;
            if (y < limitMin) { // Rebote superior
                velocity += (limitMin - y) * elasticity;
            } else if (y > limitMax) { // Rebote inferior
                velocity += (limitMax - y) * elasticity;
            }
            y += velocity;
            velocity *= damping; // Amortiguación
        }
        if(!skip1Frame){
            super.update(dt);
        }
        
        
    }

    function applyResistance(excess: Float): Float {
        return Math.sqrt(excess) * resistanceFactor;
    }
}
