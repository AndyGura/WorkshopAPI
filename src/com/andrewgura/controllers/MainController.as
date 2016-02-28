package com.andrewgura.controllers {
import com.andrewgura.consts.AppMenuConsts;
import com.andrewgura.consts.SharedObjectConsts;
import com.andrewgura.models.MainModel;
import com.andrewgura.ui.popup.AppPopups;
import com.andrewgura.ui.popup.PopupFactory;
import com.andrewgura.vo.FileTypeVO;
import com.andrewgura.vo.ProjectVO;

import flash.desktop.NativeApplication;
import flash.events.Event;
import flash.events.FileListEvent;
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
        mainModel.defaultProjectPath = PersistanceController.getResource(SharedObjectConsts.DEFAULT_PATH);
        mainModel.recentProjectFileNames = new ArrayCollection(PersistanceController.getResource(SharedObjectConsts.RECENT_PROJECTS));
        mainModel.workshopSettings = PersistanceController.getResource(SharedObjectConsts.WORKSHOP_SETTINGS);
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
        var newTitle:String = mainModel.currentProject ? mainModel.currentProject.displayFullName + " - " : '';
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
        f.browse([mainModel.config.projectFileType.fileFilter]);

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

    public static function importFiles(fileType:FileTypeVO = null):void {
        if (!fileType) {
            fileType = mainModel.config.allSupportedImportTypes;
        }
        var f:File = new File();
        f.addEventListener(FileListEvent.SELECT_MULTIPLE, onFilesSelected);
        f.addEventListener(Event.CANCEL, onFilesSelectionCanceled);
        f.browseForOpenMultiple('Select files to import', [fileType.fileFilter]);

        function onFilesSelected(event:FileListEvent):void {
            f.removeEventListener(FileListEvent.SELECT_MULTIPLE, onFilesSelected);
            f.removeEventListener(Event.CANCEL, onFilesSelectionCanceled);
            importSelectedFiles(event.files);
        }

        function onFilesSelectionCanceled(event:Event):void {
            f.removeEventListener(FileListEvent.SELECT_MULTIPLE, onFilesSelected);
            f.removeEventListener(Event.CANCEL, onFilesSelectionCanceled);
        }
    }

    public static function importSelectedFiles(fileList:Array):void {
        if (!mainModel.currentProject) {
            MainController.createNewFile();
        }
        mainModel.currentProject.importFiles(fileList);
    }

    public static function openFiles(files:Array):void {
        for each (var file:File in files) {
            openFileByName(file.nativePath);
        }
    }

    public static function openFileByName(fileName:String):void {
        var extension:String = fileName.substr(fileName.lastIndexOf('.') + 1);
        if (mainModel.config.projectFileType.extensions.indexOf(extension.toLowerCase()) > -1) {
            for each (var project:ProjectVO in mainModel.openedProjects) {
                if (project.fileName == fileName) {
                    mainModel.currentProject = project;
                    PersistanceController.setResource(SharedObjectConsts.DEFAULT_PATH, mainModel.defaultProjectPath);
                    addProjectToRecent(mainModel.currentProject.fileName);
                    return;
                }
            }
            var f:File = File.applicationDirectory.resolvePath(fileName);
            f.addEventListener(Event.COMPLETE, onFileLoaded);
            f.addEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
            f.load();
        } else {
            for each (var type:FileTypeVO in mainModel.config.importTypes) {
                if (type.extensions.indexOf(extension.toLowerCase()) > -1) {
                    importFileByName(fileName);
                }
            }
        }

        function onFileLoaded(event:Event):void {
            f.removeEventListener(Event.COMPLETE, onFileLoaded);
            f.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
            var data:ByteArray = f.data;
            var name:String = f.name.substr(0, f.name.lastIndexOf('.'));
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
            PersistanceController.setResource(SharedObjectConsts.DEFAULT_PATH, mainModel.defaultProjectPath);
            addProjectToRecent(mainModel.currentProject.fileName);
        }

        function onFileLoadError(event:IOErrorEvent):void {
            f.removeEventListener(Event.COMPLETE, onFileLoaded);
            f.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
            PopupFactory.instance.showPopup(AppPopups.INFO_POPUP, "Can't load project!\n" + event.text);
        }

    }

    public static function importFileByName(fileName:String):void {

        var f:File = File.applicationDirectory.resolvePath(fileName);
        f.addEventListener(Event.COMPLETE, onFileLoaded);
        f.addEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
        f.load();

        function onFileLoaded(event:Event):void {
            f.removeEventListener(Event.COMPLETE, onFileLoaded);
            f.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
            var name:String = f.name.substr(0, f.name.lastIndexOf('.'));
            mainModel.currentProject = new mainModel.config.projectClass();
            mainModel.currentProject.name = name;
            mainModel.currentProject.importFiles([event.target]);
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
            PersistanceController.setResource(SharedObjectConsts.DEFAULT_PATH, mainModel.defaultProjectPath);
        }

        function onFileLoadError(event:IOErrorEvent):void {
            f.removeEventListener(Event.COMPLETE, onFileLoaded);
            f.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
            PopupFactory.instance.showPopup(AppPopups.INFO_POPUP, "Can't open file!\n" + event.text);
        }

    }

    public static function saveCurrentProject():void {
        var project:ProjectVO = mainModel.currentProject;
        if (!project || project.isChangesSaved) {
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
        f.save(project.serialize(), project.name + '.' + mainModel.config.projectFileType.extensions[0]);
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
        PersistanceController.setResource(SharedObjectConsts.DEFAULT_PATH, mainModel.defaultProjectPath);
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

    public static function closeProjectByIndex(index:Number):void {
        if (isNaN(index) || index < 0 || index >= mainModel.openedProjects.length) {
            return;
        }
        closeProject(ProjectVO(mainModel.openedProjects.getItemAt(index)));
    }

    public static function closeCurrentProject():void {
        closeProject(mainModel.currentProject);
    }

    public static function closeProject(project:ProjectVO):void {
        var decrementIndexIfRemove:Boolean = false;
        if (!project || mainModel.openedProjects.getItemIndex(project) == -1) {
            return;
        }
        if (!project.isChangesSaved) {
            var returnAfterIndex:Number = mainModel.currentProjectIndex;
            mainModel.currentProject = project;
            decrementIndexIfRemove = mainModel.currentProjectIndex < returnAfterIndex;
            PopupFactory.instance.showPopup(AppPopups.CONFIRM_POPUP, "All unsaved data will be lost! Are you sure?", true, null, onProceed, onCancel);
        } else {
            onProceed();
        }
        function onProceed(...args):void {
            mainModel.openedProjects.removeItem(project);
            if (isNaN(returnAfterIndex)) {
                returnAfterIndex = mainModel.currentProjectIndex;
            } else if (decrementIndexIfRemove) {
                returnAfterIndex--;
            }
            mainModel.currentProjectIndex = Math.min(Math.max(returnAfterIndex, 0), mainModel.openedProjects.length - 1);
        }
        function onCancel(...args):void {
            mainModel.currentProjectIndex = Math.min(Math.max(returnAfterIndex, 0), mainModel.openedProjects.length - 1);
        }
    }

    public static function switchToNextProject():void {
        if (mainModel.openedProjects.length < 2) {
            return;
        }
        mainModel.currentProjectIndex++;
    }

    public static function switchToPrevProject():void {
        if (mainModel.openedProjects.length < 2) {
            return;
        }
        mainModel.currentProjectIndex--;
    }

    public static function exitEditor():void {
        var isAllChangesSaved:Boolean = true;
        for each (var project:ProjectVO in mainModel.openedProjects) {
            if (!project.isChangesSaved) {
                isAllChangesSaved = false;
                break;
            }
        }
        if (!isAllChangesSaved) {
            PopupFactory.instance.showPopup(AppPopups.CONFIRM_POPUP, "You have unsaved changes in some of opened projects, all unsaved data will be lost! Are you sure?", true, null, onProceed);
        } else {
            onProceed();
        }
        function onProceed(...args):void {
            NativeApplication.nativeApplication.exit();
        }
    }

    public static function openProjectSettings():void {
        if (!mainModel.config.projectSettingsPanelClass) {
            return;
        }
        PopupFactory.instance.showPopup(
                AppPopups.SETTINGS_POPUP,
                '', true,
                {
                    data: {project: mainModel.currentProject},
                    settingsPanelClass: mainModel.config.projectSettingsPanelClass
                },
                onProjectSettingsChange
        );

        function onProjectSettingsChange(data:*):void {
            mainModel.currentProject.applySettingsChanges(data);
        }
    }

    public static function openWorkshopSettings():void {
        if (!mainModel.config.workshopSettingsPanelClass) {
            return;
        }
        PopupFactory.instance.showPopup(
                AppPopups.SETTINGS_POPUP,
                '', true,
                {
                    data: mainModel.workshopSettings,
                    settingsPanelClass: mainModel.config.workshopSettingsPanelClass
                },
                onWorkshopSettingsChange
        );

        function onWorkshopSettingsChange(data:*):void {
            mainModel.workshopSettings = data;
            PersistanceController.setResource(SharedObjectConsts.WORKSHOP_SETTINGS, data);
        }
    }

    private static function addProjectToRecent(fileName:String):void {
        if (!mainModel.recentProjectFileNames) {
            mainModel.recentProjectFileNames = new ArrayCollection();
        }
        if (mainModel.recentProjectFileNames.getItemIndex(fileName) >= 0) {
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

        var fileEntries:Array = [
            {label: AppMenuConsts.NEW},
            {label: AppMenuConsts.OPEN}];
        if (mainModel.config.importTypes && mainModel.config.importTypes.length > 0) {
            var importEntries:Array = [];
            for each (var importTypeVO:FileTypeVO in mainModel.config.importTypes) {
                importEntries.push({label: importTypeVO.description, type: "importEntry", importTypeVO: importTypeVO});
            }
            fileEntries.push({label: AppMenuConsts.IMPORT, children: importEntries});
        }
        fileEntries = fileEntries.concat([
            {
                label: AppMenuConsts.SAVE,
                enabled: (mainModel.currentProject != null && !mainModel.currentProject.isChangesSaved)
            },
            {label: AppMenuConsts.SAVE_AS, enabled: mainModel.currentProject != null},
            {label: AppMenuConsts.CLOSE, enabled: mainModel.currentProject != null},
            {type: "separator"}
        ]);
        if (mainModel.recentProjectFileNames && mainModel.recentProjectFileNames.length > 0) {
            for each (var recentFileName:String in mainModel.recentProjectFileNames) {
                fileEntries.push({
                    label: recentFileName,
                    type: "recentFile"
                });
            }
            fileEntries.push({type: "separator"});
        }
        fileEntries.push({label: AppMenuConsts.EXIT});

        var editEntries:Array = [
            {label: AppMenuConsts.PROJECT_SETTINGS, enabled: mainModel.currentProject != null},
            {label: AppMenuConsts.WORKSHOP_SETTINGS}
        ];

        var data:Array = [
            {label: AppMenuConsts.FILE, children: fileEntries},
            {label: AppMenuConsts.EDIT, children: editEntries}
        ];

        mainModel.menuDataProvider = data;
    }

    public function MainController() {
        throw new Error('MainController is a static class and shouldn\'t be instantiated');
    }
}
}
