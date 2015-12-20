package com.andrewgura.controllers {
import com.andrewgura.consts.AppMenuConsts;

public class AppMenuController {

    public static function doMenuItemAction(item:String):void {
        switch (item) {
            case AppMenuConsts.NEW:
                MainController.createNewFile();
                break;
            case AppMenuConsts.OPEN:
                MainController.openFile();
                break;
            case AppMenuConsts.SAVE:
                MainController.saveCurrentProject();
                break;
            case AppMenuConsts.SAVE_AS:
                MainController.saveCurrentProjectAs();
                break;
            case AppMenuConsts.CLOSE:
                MainController.closeCurrentProject();
                break;
            case AppMenuConsts.EXIT:
                MainController.exitEditor();
                break;
            case AppMenuConsts.PROJECT_SETTINGS:
                MainController.openProjectSettings();
                break;
        }
    }

    public function AppMenuController() {
        throw new Error('AppMenuController is a static class and shouldn\'t be instantiated');
    }
}
}
