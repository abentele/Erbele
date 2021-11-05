/*
Erbele - Based on Fraise 3.7.3 based on Smultron by Peter Borg

Current Maintainer (since 2016):
Andreas Bentele: abentele.github@icloud.com (https://github.com/abentele/Erbele)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/


import Foundation

private var _sharedInstance: FRAAuthenticationController? = nil;

// TODO features will not work any more after switching on the app sandbox feature
class FRAAuthenticationController : NSObject {
    @objc class func sharedInstance() -> FRAAuthenticationController {
        if (_sharedInstance == nil) {
            return FRAAuthenticationController();
        }
        
        return _sharedInstance!;
    }
    
    override init() {
        super.init()
        _sharedInstance = self;
    }

    // TODO replace type of parameter with String.Encoding (not compatible to Objective-C!)
    @objc public func performAuthenticatedOpen(ofPath path: String, withEncoding encoding: UInt) {
        let process = Process()
        let pipe = Pipe()
        let fileHandle = pipe.fileHandleForReading

        if #available(OSX 10.13, *) {
            process.executableURL = URL(fileURLWithPath: "/usr/libexec/authopen")
        } else {
            // Fallback on earlier versions
            process.launchPath = "/usr/libexec/authopen"
        }
        process.arguments = [ path ]
        process.standardOutput = pipe
        
        process.launch()
        
        let data = Data.init(fileHandle.readDataToEndOfFile())

        process.waitUntilExit()
        
        let status = process.terminationStatus
        
        if (status != 0) {
            let title = String(format: NSLocalizedString("There was a unknown error when trying to open the file %@ with authentication",
                                                         comment: "Indicate that there was a unknown error when trying to open the file %@ with authentication in Unknown-error-when-opening-with-authentication sheet"),
                               path);
            
            FRAVariousPerformer.sharedInstance().standardAlertSheet(withTitle: title,
                                                                     message: NSLocalizedString("Please check the permissions for the file and the enclosing folder and try again",
                                                                                                comment: "Indicate that they should please check the permissions for the file and the enclosing folder and try again in Unknown-error-when-opening-with-authentication sheet"),
                                                                     window: FRACurrentWindow())
        } else {
            FRAOpenSavePerformer.sharedInstance().shouldOpenPartTwo(path, withEncoding: encoding, data: data)
        }
    }
    
    @objc public func performAuthenticatedSave(ofDocument document: Any, data: Data, path: String, fromSaveAs: Bool, aCopy: Bool) {
        let process = Process()
        let pipe = Pipe()
        let writeHandle = pipe.fileHandleForWriting

        if #available(OSX 10.13, *) {
            process.executableURL = URL(fileURLWithPath: "/usr/libexec/authopen")
        } else {
            // Fallback on earlier versions
            process.launchPath = "/usr/libexec/authopen"
        }
        process.arguments = [ "-c", "-w", path]
        process.standardInput = pipe

        process.launch()
        writeHandle.write(data)
        
        
        close(writeHandle.fileDescriptor); // Close it manually

        process.waitUntilExit()

        let status = process.terminationStatus
        
        if (status != 0) {
            let title = String(format: NSLocalizedString("There was a unknown error when trying to save the file %@ with authentication",
                                                         comment: "Indicate that there was a unknown error when trying to save the file %@ with authentication in Unknown-error-when-saving-with-authentication sheet"),
                               path)
            FRAVariousPerformer.sharedInstance().standardAlertSheet(withTitle: title,
                                                                     message: NSLocalizedStringFromTable("Please check if the file is locked, on a media that is unwritable or if you can save it in another location", "Localizable3", "Please check if the file is locked, on a media that is unwritable or if you can save it in another location"),
                                                                     window: FRACurrentWindow())
        } else {
            if (!aCopy) {
                FRAOpenSavePerformer.sharedInstance().updateAfterSave(forDocument: document, path: path)
            }
        }

    }

}


