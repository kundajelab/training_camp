#!/usr/bin/env python
###
# BUNCH OF FUNCTIONS COPIED FROM av_scripts/fileProcessing.py
###
import re;
import os;

def printProgress(progressUpdate, i, fileName=None):
    if progressUpdate is not None:
        if (i%progressUpdate == 0):
            print("Processed "+str(i)+" lines"+str("" if fileName is None else " of "+fileName));

def defaultTabSeppd(s):
    s = trimNewline(s);
    s = splitByTabs(s);
    return s;

def defaultWhitespaceSeppd(s):
    s = trimNewline(s);
    s = s.split();
    return s;

def trimNewline(s):
    return s.rstrip('\r\n');

def appendNewline(s):
    return s+"\n"; #aargh O(n) aargh FIXME if you can

def splitByDelimiter(s,delimiter):
    return s.split(delimiter);

def splitByTabs(s):
    return splitByDelimiter(s,"\t");
def getCoreFileName(fileName):
    return getFileNameParts(fileName).coreFileName;

def getFileNameParts(fileName):
    p = re.compile(r"^(.*/)?([^\./]+)(\.[^/]*)?$");
    m = p.search(fileName);
    return FileNameParts(m.group(1), m.group(2), m.group(3));

class FileNameParts:
    def __init__(self, directory, coreFileName, extension):
        self.directory = directory if (directory is not None) else os.getcwd();
        self.coreFileName = coreFileName;
        self.extension = extension;
    def getFullPath(self):
        return self.directory+"/"+self.fileName;
    def getCoreFileNameAndExtension(self):
        return self.coreFileName+self.extension;
    def getCoreFileNameWithTransformation(self, transformation=lambda x: x):
        return transformation(self.coreFileName);
    def getFileNameWithTransformation(self,transformation,extension=None):
        toReturn = self.getCoreFileNameWithTransformation(transformation);
        if (extension is not None):
            toReturn = toReturn+extension;
        else:
            if (self.extension is not None):
                toReturn = toReturn+self.extension;
        return toReturn;
    def getFilePathWithTransformation(self,transformation=lambda x: x,extension=None):
        return self.directory+"/"+self.getFileNameWithTransformation(transformation,extension=extension);

def getFileHandle(filename,mode="r"):
    if (re.search('.gz$',filename) or re.search('.gzip',filename)):
        if (mode=="r"):
            mode="rb";
        return gzip.open(filename,mode)
    else:
        return open(filename,mode) 

def readColIntoArr(fileHandle,col=0,titlePresent=True):
    arr = [];
    def action(inp, lineNumber):
        arr.append(inp[col]);
    performActionOnEachLineOfFile(
        fileHandle
        , transformation=defaultWhitespaceSeppd
        , action=action
        , ignoreInputTitle=titlePresent
    );
    return arr;

def simpleDictionaryFromFile(fileHandle, keyIndex=0, valIndex=1, titlePresent=False, transformation=defaultTabSeppd):
    from collections import OrderedDict
    toReturn = OrderedDict();
    def action(inp, lineNumber):
        toReturn[inp[keyIndex]] = inp[valIndex];
    performActionOnEachLineOfFile(
        fileHandle=fileHandle
        ,action=action
        ,transformation=transformation
        ,ignoreInputTitle=titlePresent
    );
    return toReturn;

def performActionOnEachLineOfFile(fileHandle
    , action=None #should be a function that accepts the preprocessed/filtered line and the line number
    , transformation=lambda x: x
    , ignoreInputTitle=False
    , filterFunction=None
    , preprocessing=None #the preprocessing step is performed before both 'filterFunction' and 'transformation'. Originally I just had 'transformation'. 
    , actionFromTitle=None
    , progressUpdate=None
    , progressUpdateFileName=None
    ):
    if (actionFromTitle is None and action is None):
        raise ValueError("One of actionFromTitle or action should not be None");
    if (actionFromTitle is not None and action is not None):
        raise ValueError("Only one of actionFromTitle or action can be non-None");
    if (actionFromTitle is not None and ignoreInputTitle == False):
        raise ValueError("If actionFromTitle is not None, ignoreInputTitle should probably be True because it implies a title is present");
    
    i = 0;
    for line in fileHandle:
        i += 1;
        if (i == 1 and actionFromTitle is not None):
            action = actionFromTitle(line);
        processLine(line,i,ignoreInputTitle,preprocessing,filterFunction,transformation,action, progressUpdate);
        printProgress(progressUpdate, i, progressUpdateFileName);

    fileHandle.close();

def processLine(line,i,ignoreInputTitle,preprocessing,filterFunction,transformation,action, progressUpdate=None):
    if (i > 1 or (ignoreInputTitle==False)):
        if progressUpdate is not None:
            if i%progressUpdate == 0:
                print("Done ",i,"lines");
        if (preprocessing is not None):
            line = preprocessing(line);
        if (filterFunction is None or filterFunction(line,i)):
            action(transformation(line),i)
###
# END COPIED FUNCTIONS 
###

def mapToNearestPeak(options):
    peaksToGenesMapping = simpleDictionaryFromFile(getFileHandle(options.peaks2genesFile)
                            ,keyIndex=options.peakColumnInPeaks2GenesFile
                            ,valIndex=options.geneColumnInPeaks2GenesFile
                            ,transformation=defaultWhitespaceSeppd);  
    for sigPeakInputFile in options.sigPeakInputFiles:
        sigPeaks = readColIntoArr(getFileHandle(sigPeakInputFile),col=0,titlePresent=False);
        outputFile = getFileNameParts(sigPeakInputFile).getFilePathWithTransformation(lambda x: "nearestGenes_"+x);
        ofh = getFileHandle(outputFile,'w');
        for peak in sigPeaks:
            ofh.write(peaksToGenesMapping[peak]+"\n");
        ofh.close();     

if __name__ == "__main__":
    import argparse;
    parser = argparse.ArgumentParser();
    parser.add_argument("--sigPeakInputFiles", nargs="+");
    parser.add_argument("--peaks2genesFile", required=True);
    parser.add_argument("--peakColumnInPeaks2GenesFile", type=int, default=3);
    parser.add_argument("--geneColumnInPeaks2GenesFile", type=int, default=7);
    options = parser.parse_args();
    
    mapToNearestPeak(options); 
