package com.andrewgura.util {

import flash.display.DisplayObjectContainer;
import flash.display.Stage;

import mx.core.FlexGlobals;
import mx.core.UIComponent;
import mx.styles.CSSStyleDeclaration;

import spark.components.Application;

public class UIUtil {


    public static function getApplication():Application {
        return Application(FlexGlobals.topLevelApplication);
    }

    public static function getSplashScreen():Object {
        return Object(getApplication()).splashScreen;
    }

    public static function getStyleDeclaration(selector:String):CSSStyleDeclaration {
        return UIComponent(getApplication()).styleManager.getStyleDeclaration(selector);
    }

    public static function getStage():Stage {
        return UIComponent(getApplication()).systemManager.stage;
    }
}
}