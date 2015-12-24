package com.andrewgura.controllers {
import com.andrewgura.consts.SharedObjectConsts;
import com.andrewgura.models.MainModel;
import com.andrewgura.ui.popup.AppPopups;
import com.andrewgura.ui.popup.PopupFactory;
import com.andrewgura.vo.ProjectVO;

import flash.desktop.NativeApplication;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

public class MainController {

    private static var mainModel:MainModel;

    public static function initApplication(model:MainModel):void {
        mainModel = model;
        mainModel.defaultProjectPath = PersistanceController.getEncryptedResource(SharedObjectConsts.DEFAULT_PATH);
        updateAppTitle();
        mainModel.addEventListener(
                "currentProjectChange",
                function handle(e:Event):void {
                    updateAppTitle();
                }
        );
    }

    public static function updateAppTitle():void {
        var newTitle:String = '';
        if (mainModel.currentProject) {
            newTitle = mainModel.currentProject.name;
            if (!mainModel.currentProject.isChangesSaved) {
                newTitle += "*";
            }
            newTitle += " - ";
        }
        newTitle += mainModel.config.appName + " v" + mainModel.config.appVersion;
        if (!NativeApplication.nativeApplication || !NativeApplication.nativeApplication.activeWindow) {
            return;
        }
        NativeApplication.nativeApplication.activeWindow.title = newTitle;
    }

    public static function createNewFile():void {
        mainModel.currentProject = new mainModel.config.projectClass();
        updateAppTitle();
        mainModel.currentProject.addEventListener(
                "isChangesSavedChanged",
                function handle(e:Event):void {
                    updateAppTitle();
                }
        );
    }

    public static function openFile():void {
        var f:File = new File();
        if (mainModel.defaultProjectPath) {
            f = f.resolvePath(mainModel.defaultProjectPath);
        }
        f.addEventListener(Event.SELECT, onFileSelected);
        f.addEventListener(Event.CANCEL, onFileSelectionCancelled);
        f.browse([mainModel.config.projectFileFilter]);

        function onFileSelected(event:Event):void {
            f.removeEventListener(Event.SELECT, onFileSelected);
            f.removeEventListener(Event.CANCEL, onFileSelectionCancelled);
            f.addEventListener(Event.COMPLETE, onFileLoaded);
            f.addEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
            f.load();
        }

        function onFileSelectionCancelled(event:Event):void {
            f.removeEventListener(Event.SELECT, onFileSelected);
            f.removeEventListener(Event.CANCEL, onFileSelectionCancelled);
        }

        function onFileLoaded(event:Event):void {
            f.removeEventListener(Event.COMPLETE, onFileLoaded);
            f.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
            var data:ByteArray = f.data;
            var name:String = f.name.substr(0, f.name.length - mainModel.config.projectFileExtension.length - 1);
            mainModel.currentProject = new mainModel.config.projectClass();
            mainModel.currentProject.deserialize(name, f.nativePath, data);
            updateAppTitle();
            mainModel.currentProject.addEventListener(
                    "isChangesSavedChanged",
                    function handle(e:Event):void {
                        updateAppTitle();
                    }
            );
            mainModel.defaultProjectPath = f.nativePath.substr(
                    0,
                    Math.max(
                            f.nativePath.lastIndexOf('/'),
                            f.nativePath.lastIndexOf('\\')
                    )
            );
            PersistanceController.setEncryptedResource(SharedObjectConsts.DEFAULT_PATH, mainModel.defaultProjectPath);
        }

        function onFileLoadError(event:IOErrorEvent):void {
            f.removeEventListener(Event.COMPLETE, onFileLoaded);
            f.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
            PopupFactory.instance.showPopup(AppPopups.INFO_POPUP, "Can't load project!\n" + event.text);
        }
    }

    public static function saveCurrentProject():void {
        var project:ProjectVO = mainModel.currentProject;
        if (project.isChangesSaved) {
            return;
        }
        if (!project.fileName) {
            saveCurrentProjectAs();
            return;
        }
        var fs:FileStream = new FileStream();
        var targetFile:File = (new File()).resolvePath(project.fileName);
        fs.open(targetFile, FileMode.WRITE);
        fs.writeBytes(project.serialize());
        fs.close();
        project.isChangesSaved = true;
        updateAppTitle();
    }

    public static function saveCurrentProjectAs():void {
        var project:ProjectVO = mainModel.currentProject;
        var f:File = new File();
        if (mainModel.defaultProjectPath) {
            f = f.resolvePath(mainModel.defaultProjectPath);
        }
        f.addEventListener(Event.COMPLETE, onSaveAsComplete);
        f.addEventListener(Event.CANCEL, onSaveAsCancel);
        f.addEventListener(IOErrorEvent.IO_ERROR, onSaveIOError);
        f.save(project.serialize(), project.name + '.' + mainModel.config.projectFileExtension);
    }

    private static function onSaveAsComplete(event:Event):void {
        var f:File = File(event.target);
        f.removeEventListener(Event.COMPLETE, onSaveAsComplete);
        f.removeEventListener(Event.CANCEL, onSaveAsCancel);
        f.removeEventListener(IOErrorEvent.IO_ERROR, onSaveIOError);
        var newProjectName:String = f.name;
        newProjectName = newProjectName.substr(0, newProjectName.lastIndexOf('.'));
        mainModel.currentProject.name = newProjectName;
        mainModel.currentProject.fileName = f.nativePath;
        mainModel.currentProject.isChangesSaved = true;
        mainModel.defaultProjectPath = f.nativePath.substr(
            0,
            Math.max(
                f.nativePath.lastIndexOf('/'),
                f.nativePath.lastIndexOf('\\')
            )
        );
        PersistanceController.setEncryptedResource(SharedObjectConsts.DEFAULT_PATH, mainModel.defaultProjectPath);
        updateAppTitle();
    }

    private static function onSaveAsCancel(event:Event):void {
        File(event.target).removeEventListener(Event.COMPLETE, onSaveAsComplete);
        File(event.target).removeEventListener(Event.CANCEL, onSaveAsCancel);
        File(event.target).removeEventListener(IOErrorEvent.IO_ERROR, onSaveIOError);
    }

    private static function onSaveIOError(event:IOErrorEvent):void {
        File(event.target).removeEventListener(Event.COMPLETE, onSaveAsComplete);
        File(event.target).removeEventListener(Event.CANCEL, onSaveAsCancel);
        File(event.target).removeEventListener(IOErrorEvent.IO_ERROR, onSaveIOError);
        PopupFactory.instance.showPopup(AppPopups.INFO_POPUP, "Can't save project!\n" + event.text);
    }

    public static function closeCurrentProject():void {
        if (!mainModel.currentProject.isChangesSaved) {
            PopupFactory.instance.showPopup(AppPopups.CONFIRM_POPUP, "All unsaved data will be lost! Are you sure?", true, null, onProceed);
        } else {
            onProceed();
        }
        function onProceed(...args):void {
            mainModel.currentProject = null;
            updateAppTitle();
        }
    }

    public static function exitEditor():void {
        NativeApplication.nativeApplication.exit();
    }

    public static function openProjectSettings():void {
        if (!mainModel.config.settingsPanelClass) {
            return;
        }
        PopupFactory.instance.showPopup(
                AppPopups.PROJECT_SETTINGS_POPUP,
                '', true,
                {
                    project: mainModel.currentProject,
                    settingsPanelClass: mainModel.config.settingsPanelClass
                },
                onProjectSettingsChange
        );

        function onProjectSettingsChange(data:*):void {
            mainModel.currentProject.applySettingsChanges(data);
        }
    }

    public function MainController() {
        throw new Error('MainController is a static class and shouldn\'t be instantiated');
    }
}
}
