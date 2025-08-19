package com.gEngine.helpers;

import com.gEngine.display.Camera;
import kha.Display;
import com.gEngine.helpers.UIComponent.VerticalAlign;
import com.gEngine.helpers.UIComponent.HorizontalAlign;
import com.gEngine.display.DisplayObject;
import com.gEngine.painters.PaintMode;
import kha.math.FastMatrix4;
import com.gEngine.display.StaticLayer;

class UIContainer extends StaticLayer {
    var components:Array<UIComponent> = new Array();
    public var scaleFactor:Float = 1.0; // Valor inicial por seguridad

    public function new() {
        super();
    }

    function updateScaleFactor(camera:Camera) {
        var baseDPI = 96; // DPI estándar (referencia)
        var baseWidth = 1280; // Resolución de referencia
        var baseHeight = 720;

        var dpiScale = Display.primary.pixelsPerInch / baseDPI;
        var resolutionScale = Math.min(camera.width / baseWidth, camera.height / baseHeight); // FIX

        // Combinamos DPI y resolución, asegurando un rango adecuado
        scaleFactor =Math.min(dpiScale * resolutionScale, 2.0);
    }

    public function addComponent(sprite:DisplayObject, offsetX:Float, offsetY:Float, alignH:HorizontalAlign, alignV:VerticalAlign) {
        var component = new UIComponent();
        component.display = sprite;
        component.horizontalAlign = alignH;
        component.verticalAlign = alignV;
        component.offsetX = offsetX * scaleFactor; // Aplicamos escala aquí
        component.offsetY = offsetY * scaleFactor;
        
        addChild(sprite);
        components.push(component);
        return component;
    }

    override function render(paintMode:PaintMode, transform:FastMatrix4) {
        var camera = paintMode.camera;
        updateScaleFactor(camera); // Recalcula en caso de cambio de tamaño

        for (component in components) {
            if (component.horizontalAlign == HorizontalAlign.Right) {
                component.display.x = camera.width - component.offsetX*scaleFactor;
            } else if (component.horizontalAlign == HorizontalAlign.Left) {
                component.display.x = component.offsetX*scaleFactor;
            } else if (component.horizontalAlign == HorizontalAlign.Center) {
                component.display.x = camera.width * 0.5 + component.offsetX*scaleFactor;
            } else if (component.horizontalAlign == HorizontalAlign.OutRight) {
                component.display.x = camera.width * 1.5 + component.offsetX*scaleFactor;
            } else if (component.horizontalAlign == HorizontalAlign.OutLeft) {
                component.display.x = -camera.width * 0.5 + component.offsetX*scaleFactor;
            }
            if (component.verticalAlign == VerticalAlign.Bottom) {
                component.display.y = camera.height - component.offsetY*scaleFactor;
            } else if (component.verticalAlign == VerticalAlign.Top) {
                component.display.y = component.offsetY*scaleFactor;
            } else if (component.verticalAlign == VerticalAlign.Center) {
                component.display.y = camera.height * 0.5 + component.offsetY*scaleFactor;
            }
            component.display.scaleX = scaleFactor;
            component.display.scaleY = scaleFactor;
        }

        super.render(paintMode, transform);
    }
}
