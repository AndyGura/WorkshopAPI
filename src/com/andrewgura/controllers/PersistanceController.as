package com.andrewgura.controllers {
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

public class PersistanceController {

//    public static function getEncryptedResource(name:String):* {
//        var data:ByteArray = EncryptedLocalStore.getItem(name);
//        var output:Array = new Array();
//        while (data && data.bytesAvailable > 0) {
//            output.push(data.readObject());
//        }
//        if (output.length>1) {
//            return output;
//        } else if (output.length==1) {
//            return output[0];
//        } else {
//            return null;
//        }
//    }
//
//    public static function setEncryptedResource(name:String, data:*):void {
//        var ba:ByteArray = new ByteArray();
//        ba.writeObject(data);
//        EncryptedLocalStore.setItem(name, ba);
//    }

    public static function getResource(name:String):* {
        var file:File = File.applicationStorageDirectory.resolvePath(name);
        if (!file.exists) {
            return null;
        }
        var fileStream:FileStream = new FileStream();
        fileStream.open(file, FileMode.READ);
        var o:* = fileStream.readObject();
        fileStream.close();
        return o;
    }

    public static function setResource(name:String, data:*):void {
        var file:File = File.applicationStorageDirectory.resolvePath(name);
        var fileStream:FileStream = new FileStream();
        fileStream.open(file, FileMode.WRITE);
        fileStream.writeObject(data);
        fileStream.close();
    }

}
}
