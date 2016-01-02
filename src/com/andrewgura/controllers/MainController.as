package com.andrewgura.controllers {
import com.andrewgura.consts.AppMenuConsts;
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

import mx.collections.ArrayCollection;

public class MainController {

    private static var mainModel:MainModel;

    public static function initApplication(model:MainModel):void {
        mainModel = model;
        mainModel.defaultProjectPath = PersistanceController.getEncryptedResource(SharedObjectConsts.DEFAULT_PATH);
        mainModel.recentProjectFileNames = new ArrayCollection(PersistanceController.getResource(SharedObjectConsts.RECENT_PROJECTS));
        updateAppTitle();
        updateMainMenu();
        mainModel.addEventListener(
                "currentProjectChange",
                function handle(e:Event):void {
                    updateAppTitle();
                    updateMainMenu();
                }
        );
        updateMainMenu();
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
        updateMainMenu();
        mainModel.currentProject.addEventListener(
                "isChangesSavedChanged",
                function handle(e:Event):void {
                    updateAppTitle();
                    updateMainMenu();
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
            openFileByName(f.nativePath);
        }

        function onFileSelectionCancelled(event:Event):void {
            f.removeEventListener(Event.SELECT, onFileSelected);
            f.removeEventListener(Event.CANCEL, onFileSelectionCancelled);
        }

    }

    public static function openFileByName(fileName:String):void {
        for each (var project:ProjectVO in mainModel.openedProjects) {
            if (project.fileName == fileName) {
                mainModel.currentProject = project;
                PersistanceController.setEncryptedResource(SharedObjectConsts.DEFAULT_PATH, mainModel.defaultProjectPath);
                addProjectToRecent(mainModel.currentProject.fileName);
                return;
            }
        }

        var f:File = File.applicationDirectory.resolvePath(fileName);
        f.addEventListener(Event.COMPLETE, onFileLoaded);
        f.addEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
        f.load();

        function onFileLoaded(event:Event):void {
            f.removeEventListener(Event.COMPLETE, onFileLoaded);
            f.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
            var data:ByteArray = f.data;
            var name:String = f.name.substr(0, f.name.length - mainModel.config.projectFileType.extension.length - 1);
            mainModel.currentProject = new mainModel.config.projectClass();
            mainModel.currentProject.deserialize(name, f.nativePath, data);
            updateAppTitle();
            updateMainMenu();
            mainModel.currentProject.addEventListener(
                    "isChangesSavedChanged",
                    function handle(e:Event):void {
                        updateAppTitle();
                        updateMainMenu();
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
            addProjectToRecent(mainModel.currentProject.fileName);
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
        updateMainMenu();
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
        f.save(project.serialize(), project.name + '.' + mainModel.config.projectFileType.extension);
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
        addProjectToRecent(mainModel.currentProject.fileName);
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
            updateMainMenu();
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

    private static function addProjectToRecent(fileName:String):void {
        if (!mainModel.recentProjectFileNames) {
            mainModel.recentProjectFileNames = new ArrayCollection();
        }
        if (mainModel.recentProjectFileNames.getItemIndex(fileName)>=0) {
            mainModel.recentProjectFileNames.removeItemAt(mainModel.recentProjectFileNames.getItemIndex(fileName));
        }
        mainModel.recentProjectFileNames.addItemAt(fileName, 0);
        while (mainModel.recentProjectFileNames.length > 5) {
            mainModel.recentProjectFileNames.removeItemAt(mainModel.recentProjectFileNames.length - 1);
        }
        PersistanceController.setResource(SharedObjectConsts.RECENT_PROJECTS, mainModel.recentProjectFileNames.source);
        updateMainMenu();
    }

    private static function updateMainMenu():void {
        var data:Array = [
            {
                label: AppMenuConsts.FILE, children: [
                {label: AppMenuConsts.NEW},
                {label: AppMenuConsts.OPEN},
                {
                    label: AppMenuConsts.SAVE,
                    enabled: (mainModel.currentProject != null && !mainModel.currentProject.isChangesSaved)
                },
                {label: AppMenuConsts.SAVE_AS, enabled: mainModel.currentProject != null},
                {label: AppMenuConsts.CLOSE, enabled: mainModel.currentProject != null},
                {type: "separator"},
                {label: AppMenuConsts.EXIT}
            ]
            },
            {
                label: AppMenuConsts.EDIT, children: [
                {label: AppMenuConsts.PROJECT_SETTINGS, enabled: mainModel.currentProject != null}
            ]
            }
        ];

        if (mainModel.recentProjectFileNames && mainModel.recentProjectFileNames.length > 0) {

            var a:Array = data[0].children;
            var lastElement:* = a.pop();
            for each (var recentFileName:String in mainModel.recentProjectFileNames) {
                a.push({label: recentFileName.substring(Math.max(recentFileName.lastIndexOf('/'), recentFileName.lastIndexOf('\\')) + 1, recentFileName.length - 4), type: "recentFile", fullFileName: recentFileName});
            }
            a.push({type: "separator"});
            a.push(lastElement);
        }
        mainModel.menuDataProvider = data;
    }

    public function MainController() {
        throw new Error('MainController is a static class and shouldn\'t be instantiated');
    }
}
}
