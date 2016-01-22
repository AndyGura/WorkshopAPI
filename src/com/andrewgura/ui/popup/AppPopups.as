package com.andrewgura.ui.popup {
import flash.utils.Dictionary;

public class AppPopups {
    public static const CONFIRM_POPUP:String = "CONFIRM_POPUP";
    public static const INFO_POPUP:String = "INFO_POPUP";
    public static const ERROR_POPUP:String = "ERROR_POPUP";
    public static const SETTINGS_POPUP:String = "SETTINGS_POPUP";

    public static const POPUPS_MAP:Dictionary = preparePopupsDictionary();

    private static function preparePopupsDictionary():Dictionary {
        var output:Dictionary = new Dictionary();
        output[CONFIRM_POPUP] = ConfirmPopup;
        output[INFO_POPUP] = InfoPopup;
        output[ERROR_POPUP] = ErrorPopup;
        output[SETTINGS_POPUP] = SettingsPopup;
        return output;
    }
}

}