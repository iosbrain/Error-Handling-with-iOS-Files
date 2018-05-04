//: Playground - noun: a place where people can play

//  Created by Andrew L. Jaffee on 4/16/18.
//
/*
 
 Copyright (c) 2018 Andrew L. Jaffee, microIT Infrastructure, LLC, and iosbrain.com.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
*/

import Foundation

struct FileSystemError : Error
{
    enum Category
    {
        case Read
        case Write
        case Rename
        case Move
        case Delete
    }
    
    let type: Category
    let verboseDescription: String
    let inMethodName: String
    let inFileName: String
    let atLineNumber: Int
    
    static func handle(error: FileSystemError) -> String
    {
        let readableError = """
                            \nERROR - operation: [\(error.type)];
                            reason: [\(error.verboseDescription)];
                            in method: [\(error.inMethodName)];
                            in file: [\(error.inFileName)];
                            at line: [\(error.atLineNumber)]\n
                            """
        print(readableError)
        return readableError
    }
    
} // end struct FileSystemError

enum AppDirectories : String
{
    case Documents = "Documents"
    case Inbox = "Inbox"
    case Library = "Library"
    case Temp = "tmp"
}

protocol AppDirectoryNames
{
    func documentsDirectoryURL() -> URL
    
    func inboxDirectoryURL() -> URL
    
    func libraryDirectoryURL() -> URL
    
    func tempDirectoryURL() -> URL
    
    func getURL(for directory: AppDirectories) -> URL
    
    func buildFullPath(forFileName name: String, inDirectory directory: AppDirectories) -> URL
} // end protocol AppDirectoryNames

extension AppDirectoryNames
{
    func documentsDirectoryURL() -> URL
    {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        //return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func inboxDirectoryURL() -> URL
    {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(AppDirectories.Inbox.rawValue) // "Inbox")
    }
    
    func libraryDirectoryURL() -> URL
    {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.libraryDirectory, in: .userDomainMask).first!
    }
    
    func tempDirectoryURL() -> URL
    {
        return FileManager.default.temporaryDirectory
        //urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(AppDirectories.Temp.rawValue) //"tmp")
    }
    
    func getURL(for directory: AppDirectories) -> URL
    {
        switch directory
        {
        case .Documents:
            return documentsDirectoryURL()
        case .Inbox:
            return inboxDirectoryURL()
        case .Library:
            return libraryDirectoryURL()
        case .Temp:
            return tempDirectoryURL()
        }
    }
    
    func buildFullPath(forFileName name: String, inDirectory directory: AppDirectories) -> URL
    {
        return getURL(for: directory).appendingPathComponent(name)
    }
} // end extension AppDirectoryNames

protocol AppFileStatusChecking
{
    func isWritable(file at: URL) -> Bool
    
    func isReadable(file at: URL) -> Bool
    
    func exists(file at: URL) -> Bool
}

extension AppFileStatusChecking
{
    func isWritable(file at: URL) -> Bool
    {
        if FileManager.default.isWritableFile(atPath: at.path)
        {
            print(at.path)
            return true
        }
        else
        {
            print(at.path)
            return false
        }
    }
    
    func isReadable(file at: URL) -> Bool
    {
        if FileManager.default.isReadableFile(atPath: at.path)
        {
            print(at.path)
            return true
        }
        else
        {
            print(at.path)
            return false
        }
    }
    
    func exists(file at: URL) -> Bool
    {
        if FileManager.default.fileExists(atPath: at.path)
        {
            return true
        }
        else
        {
            return false
        }
    }
} // end extension AppFileStatusChecking

protocol AppFileSystemMetaData
{
    func list(directory at: URL) -> Bool
    
    func attributes(ofFile atFullPath: URL) -> [FileAttributeKey : Any]
}

extension AppFileSystemMetaData
{
    func list(directory at: URL) -> Bool
    {
        let listing = try! FileManager.default.contentsOfDirectory(atPath: at.path)
        
        if listing.count > 0
        {
            print("\n----------------------------")
            print("LISTING: \(at.path)")
            print("")
            for file in listing
            {
                print("File: \(file.debugDescription)")
            }
            print("")
            print("----------------------------\n")
            
            return true
        }
        else
        {
            return false
        }
    }
    
    func attributes(ofFile atFullPath: URL) -> [FileAttributeKey : Any]
    {
        return try! FileManager.default.attributesOfItem(atPath: atFullPath.path)
    }
} // end extension AppFileSystemMetaData

protocol AppFileManipulation : AppDirectoryNames
{
    func writeFile(containing: String, to path: AppDirectories, withName name: String) -> Bool
    
    func readFile(at path: AppDirectories, withName name: String) -> String
    
    func deleteFile(at path: AppDirectories, withName name: String) -> Bool
    
    func renameFile(at path: AppDirectories, with oldName: String, to newName: String) -> Bool
    
    func moveFile(withName name: String, inDirectory: AppDirectories, toDirectory directory: AppDirectories) -> Bool
    
    func copyFile(withName name: String, inDirectory: AppDirectories, toDirectory directory: AppDirectories) -> Bool
    
    func changeFileExtension(withName name: String, inDirectory: AppDirectories, toNewExtension newExtension: String) -> Bool
}

extension AppFileManipulation
{
    func writeFile(containing: String, to path: AppDirectories, withName name: String) -> Bool
    {
        let filePath = getURL(for: path).path + "/" + name
        let rawData: Data? = containing.data(using: .utf8)
        return FileManager.default.createFile(atPath: filePath, contents: rawData, attributes: nil)
    }
    
    func readFile(at path: AppDirectories, withName name: String) -> String
    {
        let filePath = getURL(for: path).path + "/" + name
        let fileContents = FileManager.default.contents(atPath: filePath)
        let fileContentsAsString = String(bytes: fileContents!, encoding: .utf8)
        print(fileContentsAsString!)
        return fileContentsAsString!
    }
    
    func deleteFile(at path: AppDirectories, withName name: String) -> Bool
    {
        let filePath = buildFullPath(forFileName: name, inDirectory: path)
        try! FileManager.default.removeItem(at: filePath)
        return true
    }
    
    func renameFile(at path: AppDirectories, with oldName: String, to newName: String) -> Bool
    {
        let oldPath = getURL(for: path).appendingPathComponent(oldName)
        let newPath = getURL(for: path).appendingPathComponent(newName)
        try! FileManager.default.moveItem(at: oldPath, to: newPath)
        
        // highlights the limitations of using return values
        return true
    }
    
    func moveFile(withName name: String, inDirectory: AppDirectories, toDirectory directory: AppDirectories) -> Bool
    {
        let originURL = buildFullPath(forFileName: name, inDirectory: inDirectory)
        let destinationURL = buildFullPath(forFileName: name, inDirectory: directory)
        // warning: constant 'success' inferred to have type '()', which may be unexpected
        // let success =
        try! FileManager.default.moveItem(at: originURL, to: destinationURL)
        return true
    }
    
    func copyFile(withName name: String, inDirectory: AppDirectories, toDirectory directory: AppDirectories) -> Bool
    {
        let originURL = buildFullPath(forFileName: name, inDirectory: inDirectory)
        let destinationURL = buildFullPath(forFileName: name+"1", inDirectory: directory)
        try! FileManager.default.copyItem(at: originURL, to: destinationURL)
        return true
    }
    
    func changeFileExtension(withName name: String, inDirectory: AppDirectories, toNewExtension newExtension: String) -> Bool
    {
        var newFileName = NSString(string:name)
        newFileName = newFileName.deletingPathExtension as NSString
        newFileName = (newFileName.appendingPathExtension(newExtension) as NSString?)!
        let finalFileName:String =  String(newFileName)
        
        let originURL = buildFullPath(forFileName: name, inDirectory: inDirectory)
        let destinationURL = buildFullPath(forFileName: finalFileName, inDirectory: inDirectory)
        
        try! FileManager.default.moveItem(at: originURL, to: destinationURL)
        
        return true
    }
    
    func readBytes(_ bytes: Int, startingAt offset: Int = 0, from file: String, at directory: AppDirectories) throws -> String? // STEP 0
    {
        
        var textRead: String? = nil
        var fileHandle: FileHandle
        // STEP 1
        var url: URL = buildFullPath(forFileName: file, inDirectory: directory)
        
        // STEP 2
        do
        {
            // STEP 3
            fileHandle = try FileHandle(forReadingFrom: url) // the only throw
            // STEP 4
            defer
            {
                fileHandle.closeFile()
                print("Defer: file closed.")
            }
            
            // STEP 5: this CAN push the pointer in file to EOF
            let totalBytes = fileHandle.availableData
            
            // STEP 6
            if (bytes > totalBytes.count) || ((bytes + offset) > totalBytes.count)
            {
                print("Cannot read out of bounds.")
                textRead = nil
            }
            else // STEP 7
            {
                // print("Introduce read error.")
                
                // after calling availableData, it's always
                // a good idea to reset the offset
                fileHandle.seek(toFileOffset: UInt64(offset))
                let data = fileHandle.readData(ofLength: bytes)
                textRead = String(bytes: data, encoding: .utf8)
                print("Finished reading file.")
            }
        }
        catch // STEP 8
        {
            // propagate the error to the caller
            throw FileSystemError(type: .Read, verboseDescription: "Error during read file.", inMethodName: #function, inFileName: #file, atLineNumber: #line)
        }
        
        return textRead
        
    } // end func readBytes

} // end extension AppFileManipulation

struct AppFile : AppFileManipulation, AppFileStatusChecking, AppFileSystemMetaData
{
    
    let fileName: String
    var currentAppDirectory: AppDirectories
    var currentFullPath: URL?
    
    init(fileName: String, currentAppDirectory: AppDirectories)
    {
        self.fileName = fileName
        self.currentAppDirectory = currentAppDirectory
        self.currentFullPath = buildFullPath(forFileName: fileName, inDirectory: currentAppDirectory)
    }
    
    func moveToDocuments()
    {
        _ = moveFile(withName: fileName, inDirectory: .Inbox, toDirectory: .Documents)
    }
    
    func deleteTempFile()
    {
        _ = deleteFile(at: .Temp, withName: fileName)
    }
    
    func write()
    {
        writeFile(containing: "We were talking\nAbout the space\nBetween us all", to: currentAppDirectory, withName: "karma.txt")
        writeFile(containing: "And the people\nWho hide themselves\nBehind a wall", to: currentAppDirectory, withName: fileName)
    }
    
    func list() -> Bool
    {
        return list(directory: getURL(for: .Documents))
    }
    
    func getAttribs()
    {
        let attribs = attributes(ofFile: buildFullPath(forFileName: "karma.txt", inDirectory: .Documents))
        for (key, value) in attribs
        {
            if key.rawValue == "NSFileExtendedAttributes"
            {
            }
            print("\(key.rawValue) value is \(value)")
        }
    }
    
    func read(at:Int) throws -> String?
    {
        do
        {
            let fileContents = try readBytes(48, startingAt: at, from: fileName, at: currentAppDirectory)
            return fileContents
        }
        catch let error as FileSystemError
        {
            // propagate the error to the caller
            throw error
        }
    }
}

// 1) create an instance of AppFile for the duration of use of this playground
let file = AppFile(fileName: "dharma.txt", currentAppDirectory: .Documents)
// 2) get the current directory being used for output from this playground;
// it's a temporary path and changes between Xcode sessions
let url = file.getURL(for: .Documents)
// 3) copy the output of this print, open a Finder window, click
// the ⌘ ⇧ G keys (command shift G), paste the path, and click [Go]
print("path: \(url.path)")
// 4) write out some files and then comment out this line
file.write()
// 5) test to your heart's content
do
{
    if let contents = try file.read(at: 0)
    {
        print(contents)
    }
    else
    {
        print("Returned nil.")
    }
}
catch let error as FileSystemError
{
    FileSystemError.handle(error: error)
}


