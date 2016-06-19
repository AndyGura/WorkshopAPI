package com.andrewgura.vo {
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;

import mx.events.DragEvent;

import mx.events.PropertyChangeEvent;
import mx.events.PropertyChangeEventKind;

[Bindable]
public class ProjectVO extends EventDispatcher {

    private var _name:String = 'UnnamedProject';
    private var _isChangesSaved:Boolean = true;
    public var fileName:String;

    public function serialize():ByteArray {
        var output:ByteArray = new ByteArray();
        return output;
    }

    public function deserialize(name:String, fileName:String, data:ByteArray):void {
        this._name = name;
        this.fileName = fileName;
    }

    public function importFiles(fileReferences:Array):void {
    }

    public function processDragDrop(event:DragEvent):void {
    }

    [Bindable(event="isChangesSavedChanged")]
    public function get isChangesSaved():Boolean {
        return _isChangesSaved;
    }

    public function set isChangesSaved(value:Boolean):void {
        if (_isChangesSaved == value) return;
        var oldDisplayName:String = displayName;
        _isChangesSaved = value;
        dispatchEvent(new Event("isChangesSavedChanged"));
        dispatchEvent(new Event("displayNameChanged"));
        dispatchEvent(new PropertyChangeEvent(
                PropertyChangeEvent.PROPERTY_CHANGE, true, false,
                PropertyChangeEventKind.UPDATE, "displayName", oldDisplayName, displayName, this));
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

    public function get displayName():String {
        return name + (isChangesSaved ? '' : '*');
    }

    [Bindable(event="displayNameChanged")]
    public function get displayFullName():String {
        return (fileName || name) + (isChangesSaved ? '' : '*');
    }

    [Bindable(event="nameChanged")]
    public function get name():String {
        return _name;
    }

    public function set name(value:String):void {
        if (_name == value) return;
        var oldDisplayName:String = displayName;
        _name = value;
        dispatchEvent(new Event("nameChanged"));
        dispatchEvent(new Event("displayNameChanged"));
        dispatchEvent(new PropertyChangeEvent(
                PropertyChangeEvent.PROPERTY_CHANGE, true, false,
                PropertyChangeEventKind.UPDATE, "displayName", oldDisplayName, displayName, this));
    }
}
}