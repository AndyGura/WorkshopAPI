package com.andrewgura.vo {
import flash.events.Event;
import flash.utils.ByteArray;

[Bindable]
public class ProjectVO {

    public var name:String = 'UnnamedProject';
    private var _isChangesSaved:Boolean = true;
    public var fileName:String;

    public function serialize():ByteArray {
        var output:ByteArray = new ByteArray();
        return output;
    }

    public function deserialize(name:String, fileName:String, data:ByteArray):void {
        this.name = name;
        this.fileName = fileName;
    }

    [Bindable(event="isChangesSavedChanged")]
    public function get isChangesSaved():Boolean {
        return _isChangesSaved;
    }

    public function set isChangesSaved(value:Boolean):void {
        if (_isChangesSaved == value) return;
        _isChangesSaved = value;
        dispatchEvent(new Event("isChangesSavedChanged"));
    }

    public function applySettingsChanges(changes:*):void {
        var atLeastOnePropertyChanged:Boolean = false;
        for (var key:String in changes) {
            if (!this.hasOwnProperty(key)) {
                continue;
            }
            var value:* = changes[key];
            if (this[key] != value) {
                this[key] = value;
                atLeastOnePropertyChanged = true;
            }
        }
        if (atLeastOnePropertyChanged) {
            isChangesSaved = false;
        }
    }
}
}