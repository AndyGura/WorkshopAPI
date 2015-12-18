package com.andrewgura.controllers {
import com.andrewgura.models.MainModel;
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
        updateAppTitle();
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
        f.addEventListener(Event.SELECT, onFileSelected);
        f.browse([mainModel.config.projectFileFilter]);

        function onFileSelected(event:Event):void {
            f.addEventListener(Event.COMPLETE, onFileLoaded);
            f.addEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
            f.load();
        }

        function onFileLoaded(event:Event):void {
            var data:ByteArray = f.data;
            var name:String = f.name.substr(0, f.name.length - mainModel.config.projectFileExtension.length - 1);
            mainModel.currentProject = new mainModel.config.projectClass();
            mainModel.currentProject.deserialize(name, f.nativePath, data);
            updateAppTitle();
            f.removeEventListener(Event.COMPLETE, onFileLoaded);
            f.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
            mainModel.currentProject.addEventListener(
                    "isChangesSavedChanged",
                    function handle(e:Event):void {
                        updateAppTitle();
                    }
            );
        }

        function onFileLoadError(event:Event):void {
            f.removeEventListener(Event.COMPLETE, onFileLoaded);
            f.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
            trace("File load error");
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
        f.addEventListener(Event.COMPLETE, onSaveAsComplete);
        f.save(project.serialize(), project.name + '.' + mainModel.config.projectFileExtension);
    }

    private static function onSaveAsComplete(event:Event):void {
        var newProjectName:String = File(event.target).name;
        newProjectName = newProjectName.substr(0, newProjectName.lastIndexOf('.'));
        mainModel.currentProject.name = newProjectName;
        mainModel.currentProject.fileName = File(event.target).nativePath;
        mainModel.currentProject.isChangesSaved = true;
        updateAppTitle();
    }

    public static function closeCurrentProject():void {
        mainModel.currentProject = null;
        updateAppTitle();
    }

    public static function exitEditor():void {
        NativeApplication.nativeApplication.exit();
    }

    public function MainController() {
        throw new Error('MainController is a static class and shouldn\'t be instantiated');
    }
}
}
