package com.andrewgura.ui.popup {
import com.andrewgura.util.UIUtil;

import flash.utils.Dictionary;

import spark.events.PopUpEvent;

public class PopupFactory {
    private static var _instance:PopupFactory;

    public function PopupFactory(se:SingletonEnforcer) {
        popupMap = new Dictionary();
    }

    public static function get instance():PopupFactory {
        if (!_instance) {
            _instance = new PopupFactory(new SingletonEnforcer);
        }
        return _instance;
    }

    private var popupMap:Dictionary;

    private var popupMapLength:Number = 0;

    public function showPopup(alias:String, message:String, modal:Boolean = true, extData:Object = null, okHandler:Function = null, cancelHandler:Function = null):BasePopup {
        var popupType:Class = AppPopups.POPUPS_MAP[alias];
        if (popupType) {
            return showPopupByClass(popupType, message, modal, extData, okHandler, cancelHandler);
        }
        return null;
    }

    public function centerAllPopups():void {
        var popup:BasePopup;
        for (var item:* in popupMap) {
            popup = popupMap[item];
            popup.updatePopUpPosition();
        }
    }

    private function showPopupByClass(popupClass:Class, message:String, modal:Boolean = true, extData:Object = null, okHandler:Function = null, cancelHandler:Function = null):BasePopup {
        var popup:BasePopup = new popupClass();
        popup.okHandler = okHandler;
        popup.cancelHandler = cancelHandler;
        popup.message = message;
        popup.extData = extData;
        popupMap[popup] = popup;
        popupMapLength++;
        popup.addEventListener(PopUpEvent.CLOSE, onClosePopup);
        popup.open(UIUtil.getApplication(), modal);
        return popup;
    }

    private function onClosePopup(event:PopUpEvent):void {
        var popup:BasePopup = event.target as BasePopup;
        popup.removeEventListener(PopUpEvent.CLOSE, onClosePopup);
        delete popupMap[popup];
        popupMapLength--;
    }
}
}
class SingletonEnforcer {
}