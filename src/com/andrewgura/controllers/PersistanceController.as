package com.andrewgura.controllers {
import flash.data.EncryptedLocalStore;
import flash.utils.ByteArray;

public class PersistanceController {

    public static function getEncryptedResource(name:String):* {
        var data:ByteArray = EncryptedLocalStore.getItem(name);
        var output:Array = new Array();
        while (data && data.bytesAvailable > 0) {
            output.push(data.readObject());
        }
        if (output.length>1) {
            return output;
        } else if (output.length==1) {
            return output[0];
        } else {
            return null;
        }
    }

    public static function setEncryptedResource(name:String, data:*):void {
        var ba:ByteArray = new ByteArray();
        ba.writeObject(data);
        EncryptedLocalStore.setItem(name, ba);
    }

}
}
