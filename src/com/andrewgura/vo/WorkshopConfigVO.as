package com.andrewgura.vo {
import flash.desktop.NativeApplication;

[Bindable]
public class WorkshopConfigVO {

    public var projectClass:Class;
    public var editorClass:Class;
    public var projectSettingsPanelClass:Class;
    public var workshopSettingsPanelClass:Class;
    public var appName:String;
    public var appVersion:String;

    public var importTypes:Array = [];
    public var projectFileType:FileTypeVO;

    public function get allSupportedImportTypes():FileTypeVO {
        if (!importTypes || importTypes.length == 0) {
            return null;
        }
        var output:FileTypeVO = new FileTypeVO('All supported formats');
        var extensions:Array = [];
        for each (var type:FileTypeVO in importTypes) {
            extensions = extensions.concat(type.extensions);
        }
        output.extensions = extensions;
        return output;
    }

    public function WorkshopConfigVO() {
        var descriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
        var ns:Namespace = descriptor.namespace();
        appName = descriptor.ns::filename[0];
        appVersion = descriptor.ns::versionNumber[0];
    }

}

}
