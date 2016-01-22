package com.andrewgura.controllers {
import com.andrewgura.consts.AppMenuConsts;

import flash.ui.Keyboard;
import flash.utils.Dictionary;

public class ShortcutsController {

    private static var MENU_ACTIONS_MAP:Dictionary;
    private static var CTRL_KEY_ACTIONS_MAP:Dictionary;

    private static function prepareMenuActionsMap():void {
        MENU_ACTIONS_MAP = new Dictionary();
        MENU_ACTIONS_MAP[AppMenuConsts.NEW] = MainController.createNewFile;
        MENU_ACTIONS_MAP[AppMenuConsts.OPEN] = MainController.openFile;
        MENU_ACTIONS_MAP[AppMenuConsts.SAVE] = MainController.saveCurrentProject;
        MENU_ACTIONS_MAP[AppMenuConsts.SAVE_AS] = MainController.saveCurrentProjectAs;
        MENU_ACTIONS_MAP[AppMenuConsts.CLOSE] = MainController.closeCurrentProject;
        MENU_ACTIONS_MAP[AppMenuConsts.EXIT] = MainController.exitEditor;
        MENU_ACTIONS_MAP[AppMenuConsts.PROJECT_SETTINGS] = MainController.openProjectSettings;
        MENU_ACTIONS_MAP[AppMenuConsts.WORKSHOP_SETTINGS] = MainController.openWorkshopSettings;
    }

    private static function prepareCtrlKeyActionsMap():void {
        CTRL_KEY_ACTIONS_MAP = new Dictionary();
        CTRL_KEY_ACTIONS_MAP[Keyboard.N] = MainController.createNewFile;
        CTRL_KEY_ACTIONS_MAP[Keyboard.O] = MainController.openFile;
        CTRL_KEY_ACTIONS_MAP[Keyboard.S] = MainController.saveCurrentProject;
        CTRL_KEY_ACTIONS_MAP[Keyboard.X] = MainController.exitEditor;
    }

    public static function doMenuItemAction(item:*):void {
        var label:String = item.label;
        if (item.type == "recentFile") {
            MainController.openFileByName(item.fullFileName);
            return;
        }
        if (item.type == "importEntry") {
            MainController.importFiles(item.importTypeVO);
        }
        if (!MENU_ACTIONS_MAP) {
            prepareMenuActionsMap();
        }
        if (MENU_ACTIONS_MAP[label]) {
            MENU_ACTIONS_MAP[label]();
        }
    }

    public static function doCtrlShortcutAction(keyCode:uint):void {
        if (!CTRL_KEY_ACTIONS_MAP) {
            prepareCtrlKeyActionsMap();
        }
        if (CTRL_KEY_ACTIONS_MAP[keyCode]) {
            CTRL_KEY_ACTIONS_MAP[keyCode]();
        }
    }


    public function ShortcutsController() {
        throw new Error('AppMenuController is a static class and shouldn\'t be instantiated');
    }
}
}
