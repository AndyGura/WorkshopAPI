package com.andrewgura.vo {
import flash.desktop.NativeApplication;

[Bindable]
public class WorkshopConfigVO {

    public var editorClass:Class;
    public var appName:String;
    public var appVersion:String;

    public var projectFileTypes:Array = [];         //FileTypeVO
    public var settingsPanelClasses:Array = [];    //Class extends SettingsPanel
    public var projectClasses:Array = [];          //Class extends ProjectVO

    public var importTypes:Array = [];

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

    public function get projectsFileTypeFilters():Array {
        var output:Array = [];
        for each (var fileType:FileTypeVO in projectFileTypes) {
            output.push(fileType.fileFilter);
        }
        return output;
    }

    public function getProjectClassByExtension(extension:String):Class {
        for (var i:Number = 0; i < projectFileTypes.length; i++) {
            if (FileTypeVO(projectFileTypes[i]).extensions.indexOf(extension) > -1) {
                return Class(projectClasses[i]);
            }
        }
        return null;
    }

    public function getSettingsPanelClassByExtension(extension:String):Class {
        for (var i:Number = 0; i < projectFileTypes.length; i++) {
            if (FileTypeVO(projectFileTypes[i]).extensions.indexOf(extension) > -1) {
                return Class(settingsPanelClasses[i]);
            }
        }
        return null;
    }

    public function WorkshopConfigVO() {
        var descriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
        var ns:Namespace = descriptor.namespace();
        appName = descriptor.ns::filename[0];
        appVersion = descriptor.ns::versionNumber[0];
    }

}

}
