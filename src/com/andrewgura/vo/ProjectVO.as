package com.andrewgura.vo {
import flash.utils.ByteArray;

[Bindable]
public class ProjectVO {

    public var name:String = 'UnnamedProject';
    public var isChangesSaved:Boolean = true;
    public var fileName:String;

    public function serialize():ByteArray {
        var output:ByteArray = new ByteArray();
        return output;
    }

    public function deserialize(name:String, fileName:String, data:ByteArray):void {
        this.name = name;
        this.fileName = fileName;
    }

}
}