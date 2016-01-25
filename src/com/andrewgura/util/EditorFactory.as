package com.andrewgura.util {
import com.andrewgura.ui.components.Editor;
import com.andrewgura.vo.ProjectVO;

import flash.utils.Dictionary;

public class EditorFactory {

    private var editorClass:Class;

    public function EditorFactory(editorClass:Class) {
        this.editorClass = editorClass;
    }

    private var editorsMap:Dictionary = new Dictionary();

    public function createEditor(project:ProjectVO):Editor {
        editorsMap[project] = new editorClass();
        Editor(editorsMap[project]).project = project;
        return editorsMap[project];
    }

    public function getEditor(project:ProjectVO):Editor {
        return editorsMap[project];
    }

    public function disposeEditor(project:ProjectVO):void {
        if (editorsMap[project]) {
            delete editorsMap[project];
        }
    }

}
}
