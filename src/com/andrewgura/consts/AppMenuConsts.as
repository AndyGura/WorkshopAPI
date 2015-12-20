package com.andrewgura.consts {
public class AppMenuConsts {

    public static const FILE:String = 'File';
    public static const NEW:String = 'New';
    public static const OPEN:String = 'Open';
    public static const SAVE:String = 'Save';
    public static const SAVE_AS:String = 'Save as';
    public static const CLOSE:String = 'Close';
    public static const EXIT:String = 'Exit';

    public static const EDIT:String = 'Edit';
    public static const PROJECT_SETTINGS:String = 'Project Settings';

    public function AppMenuConsts() {
        throw new Error('AppMenuConsts is a static class and shouldn\'t be instantiated');
    }
}
}
