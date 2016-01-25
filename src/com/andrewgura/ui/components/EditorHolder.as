package com.andrewgura.ui.components {
import com.andrewgura.util.EditorFactory;
import com.andrewgura.vo.ProjectVO;

import flash.events.Event;

import mx.collections.ArrayCollection;
import mx.events.CollectionEvent;
import mx.events.ResizeEvent;

import spark.components.Group;

public class EditorHolder extends Group {

    private var _editorClass:Class;

    public function set editorClass(value:Class):void {
        if (_editorClass == value) return;
        _editorClass = value;
        editorFactory = new EditorFactory(_editorClass);
        updateCurrentProject();
    }

    [Bindable]
    private var _projects:ArrayCollection;

    [Bindable(event="projectsChanged")]
    public function get projects():ArrayCollection {
        return _projects;
    }

    public function set projects(value:ArrayCollection):void {
        if (_projects == value) return;
        _projects = value;
        _projects.addEventListener(CollectionEvent.COLLECTION_CHANGE, onProjectsCollectionChange);
        dispatchEvent(new Event("projectsChanged"));
    }

    [Bindable]
    private var _currentProjectIndex:Number;

    [Bindable(event="currentProjectIndexChanged")]
    public function get currentProjectIndex():Number {
        return _currentProjectIndex;
    }

    public function set currentProjectIndex(value:Number):void {
        if (_currentProjectIndex == value) return;
        _currentProjectIndex = value;
        updateCurrentProject();
        dispatchEvent(new Event("currentProjectIndexChanged"));
    }

    [Bindable]
    private var _currentEditor:Editor;

    [Bindable(event="currentEditorChanged")]
    public function get currentEditor():Editor {
        return _currentEditor;
    }

    public function set currentEditor(value:Editor):void {
        if (_currentEditor == value) return;
        if (_currentEditor) {
            _currentEditor.visible = false;
        }
        _currentEditor = value;
        if (_currentEditor) {
            _currentEditor.visible = true;
            _currentEditor.width = width - 10;
            _currentEditor.height = height - 10;
        }
        dispatchEvent(new Event("currentEditorChanged"));
    }

    private var editorFactory:EditorFactory;

    public function EditorHolder() {
        super();
        addEventListener(ResizeEvent.RESIZE, onResize);
    }

    private function updateCurrentProject():void {
        if (!editorFactory) {
            return;
        }
        var currentProject:ProjectVO;
        if (!projects || isNaN(currentProjectIndex) || currentProjectIndex < 0 || projects.length <= currentProjectIndex || !projects.getItemAt(currentProjectIndex)) {
            currentProject = null;
        } else {
            currentProject = ProjectVO(projects.getItemAt(currentProjectIndex));
        }
        currentEditor = editorFactory.getEditor(currentProject);
        if (!currentEditor) {
            currentEditor = editorFactory.createEditor(currentProject);
            currentEditor.includeInLayout = false;
            currentEditor.x = 5;
            currentEditor.y = 5;
            addElement(currentEditor);
        }
    }

    private function onProjectsCollectionChange(event:CollectionEvent):void {
        if (event.kind == "remove") {
            for each (var project:ProjectVO in event.items) {
                var editorToRemove:Editor = editorFactory.getEditor(project);
                if (editorToRemove) {
                    removeElement(editorToRemove);
                    editorFactory.disposeEditor(project);
                }
            }
        }
        updateCurrentProject();
    }

    private function onResize(event:ResizeEvent):void {
        if (currentEditor) {
            currentEditor.width = width - 10;
            currentEditor.height = height - 10;
        }
    }
}
}
