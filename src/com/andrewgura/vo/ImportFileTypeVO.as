package com.andrewgura.vo {
public class ImportFileTypeVO extends FileTypeVO {

    public var appropriateProjectType:FileTypeVO;

    public function ImportFileTypeVO(appropriateProjectType:FileTypeVO, description:String, ...extensions) {
        super(description, extensions);
        this.appropriateProjectType = appropriateProjectType;
    }

}
}
