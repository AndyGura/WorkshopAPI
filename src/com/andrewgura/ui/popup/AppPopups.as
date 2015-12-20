package com.andrewgura.ui.popup {
import flash.utils.Dictionary;

public class AppPopups {
    public static const CONFIRM_POPUP:String = "CONFIRM_POPUP";
    public static const INFO_POPUP:String = "INFO_POPUP";
    public static const PROCESS_ERROR_POPUP:String = "PROCESS_ERROR_POPUP";
    public static const PROJECT_SETTINGS_POPUP:String = "PROJECT_SETTINGS_POPUP";

    public static const POPUPS_MAP:Dictionary = preparePopupsDictionary();

    private static function preparePopupsDictionary():Dictionary {
        var output:Dictionary = new Dictionary();
        output[CONFIRM_POPUP] = ConfirmPopup;
        output[INFO_POPUP] = InfoPopup;
        output[PROCESS_ERROR_POPUP] = ProcessErrorPopup;
        output[PROJECT_SETTINGS_POPUP] = ProjectSettingsPopup;
        return output;
    }
}

}