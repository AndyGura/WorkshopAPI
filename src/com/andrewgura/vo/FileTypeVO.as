package com.andrewgura.vo {
import flash.net.FileFilter;

public class FileTypeVO {

    public var extensions:Array;
    public var description:String;

    public function FileTypeVO(description:String, ...extensions) {
        while (extensions.length == 1 && extensions[0] is Array) {
            extensions = extensions[0];
        }
        this.extensions = extensions;
        this.description = description;
    }

    public function get fileFilter():FileFilter {
        var extensionsString:String = '';
        for each (var extString:String in extensions) {
            extensionsString += '*.' + extString + ';';
        }
        extensionsString = extensionsString.substring(0, extensionsString.length - 1);
        return new FileFilter(description, extensionsString);
    }

}

}
