package com.andrewgura.models {
import com.andrewgura.vo.ProjectVO;

import flash.events.Event;

import mx.collections.ArrayCollection;
import mx.events.CollectionEvent;

[Bindable]
public class MainModel {

    public var menuDataProvider:Array;

    public var config:WorkshopConfig;
    public var defaultProjectPath:String;

    public var recentProjectFileNames:ArrayCollection;

    private var _currentProjectIndex:Number;
    private var _openedProjects:ArrayCollection = new ArrayCollection();

    [Bindable(event="currentProjectChange")]
    public function get currentProject():ProjectVO {
        if (isNaN(_currentProjectIndex) || _currentProjectIndex<0 || _currentProjectIndex>=_openedProjects.length) {
            return null;
        } else {
            return ProjectVO(_openedProjects.getItemAt(_currentProjectIndex));
        }
    }

    public function set currentProject(value:ProjectVO):void {
        if (!value && currentProject) {
            openedProjects.removeItemAt(currentProjectIndex);
            currentProjectIndex = Math.min(Math.max(currentProjectIndex, 0), openedProjects.length-1);
            return;
        }
        if (openedProjects.getItemIndex(value)==-1) {
            openedProjects.addItem(value);
        }
        currentProjectIndex = openedProjects.getItemIndex(value);
    }

    [Bindable(event="openedProjectsChanged")]
    public function get openedProjects():ArrayCollection {
        return _openedProjects;
    }

    [Bindable(event="currentProjectIndexChanged")]
    public function get currentProjectIndex():Number {
        return _currentProjectIndex;
    }

    public function set currentProjectIndex(value:Number):void {
        if (_currentProjectIndex == value) return;
        _currentProjectIndex = value;
        dispatchEvent(new Event("currentProjectIndexChanged"));
        dispatchEvent(new Event("currentProjectChange"));
    }

    public function MainModel() {
        _openedProjects.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
    }

    private function onCollectionChange(event:CollectionEvent):void {
        dispatchEvent(new Event("openedProjectsChanged"));
        dispatchEvent(new Event("currentProjectChange"));
    }

}
}
