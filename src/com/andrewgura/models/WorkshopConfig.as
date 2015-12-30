package com.andrewgura.models {
import com.andrewgura.vo.FileTypeVO;

import flash.desktop.NativeApplication;
import flash.net.FileFilter;

[Bindable]
public class WorkshopConfig {

    public var projectClass:Class;
    public var editorClass:Class;
    public var settingsPanelClass:Class;
    public var appName:String;
    public var appVersion:String;

    public var projectFileType:FileTypeVO;

    public function get projectFileFilter():FileFilter {
        return new FileFilter(projectFileType.description, "*." + projectFileType.extension);
    }

    public function WorkshopConfig() {
        var descriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
        var ns:Namespace = descriptor.namespace();
        appName = descriptor.ns::filename[0];
        appVersion = descriptor.ns::versionNumber[0];
    }

}

}
