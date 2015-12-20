package com.andrewgura.ui.popup {
import mx.managers.PopUpManager;

import spark.components.Group;
import spark.components.SkinnablePopUpContainer;
import spark.components.VGroup;
import spark.layouts.VerticalAlign;

public class BasePopup extends SkinnablePopUpContainer {
    public function BasePopup() {
        super();
        //addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, onMouseDownOutside);
    }

    [SkinPart(required="false")]
    public var buttonsGroup:Group;

    private var _popupContent:Array = [];
    private var _buttonContent:Array = [];

    [ArrayElementType("mx.core.IVisualElement")]
    public function get popupContent():Array {
        return _popupContent;
    }

    public function set popupContent(value:Array):void {
        _popupContent = value;
        if (contentGroup) {
            contentGroup.mxmlContent = value;
        }
    }

    [ArrayElementType("mx.core.IVisualElement")]
    public function get buttonContent():Array {
        return _buttonContent;
    }

    public function set buttonContent(value:Array):void {
        _buttonContent = value;
        if (buttonsGroup) {
            buttonsGroup.mxmlContent = value;
        }
    }

    override protected function partAdded(partName:String, instance:Object):void {
        super.partAdded(partName, instance);
        if (instance == contentGroup) {
            contentGroup.mxmlContent = popupContent;
            VGroup(contentGroup).paddingBottom = 40;
            VGroup(contentGroup).paddingLeft = 8;
            VGroup(contentGroup).paddingRight = 8;
            VGroup(contentGroup).paddingTop = 40;
        } else if (instance == buttonsGroup) {
            buttonsGroup.mxmlContent = buttonContent;
        }
    }

    override protected function partRemoved(partName:String, instance:Object):void {
        super.partRemoved(partName, instance);
        if (instance == contentGroup) {
            contentGroup.mxmlContent = null;
        } else if (instance == buttonsGroup) {
            buttonsGroup.mxmlContent = null;
        }
    }

    public var okHandler:Function;

    public var cancelHandler:Function;

    [Inspectable(enumeration="middle,bottom", defaultValue="middle")]
    public var verticalPopupAlign:String = VerticalAlign.MIDDLE;

    [Bindable]
    public var message:String;

    [Bindable]
    public var extData:Object;

    protected function removePopup():void {
        okHandler = null;
        cancelHandler = null;
        close();
    }

    override public function updatePopUpPosition():void {
        super.updatePopUpPosition();
        PopUpManager.centerPopUp(this);
    }


}
}