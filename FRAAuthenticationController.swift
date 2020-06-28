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

        process.executableURL = URL(fileURLWithPath: "/usr/libexec/authopen")
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

        process.executableURL = URL(fileURLWithPath: "/usr/libexec/authopen")
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

    func installCommandLineUtility() throws {
        let erbelePath = Bundle.main.resourceURL!.appendingPathComponent("erbele")
        let erbeleData = try Data.init(contentsOf: erbelePath)
        let erbeleManPagePath = Bundle.main.resourceURL!.appendingPathComponent("erbele.1")
        let erbeleManPageData = try Data.init(contentsOf: erbeleManPagePath)

        var status = installCommandLineUtilityErbele(erbeleData)

        if (status == 0) {
            status = installCommandLineUtilityManpage(erbeleManPageData)
        }
        
        if (status != 0) {
            FRAVariousPerformer.sharedInstance().standardAlertSheet(withTitle: NSLocalizedString("There was a unknown error when trying to install the command-line utility",
                                                                                                  comment: "Indicate that there was a unknown error when trying to install the command-line utility in Unknown-error-when-installing-comman-line-utility sheet"),
                                                                     message: "",
                                                                     window: FRACurrentWindow())
        }

    }
    
    private func installCommandLineUtilityErbele(_ erbeleData: Data) -> Int32 {
        let process = Process()
        let pipe = Pipe()
        let writeHandle = pipe.fileHandleForWriting

        process.executableURL = URL(fileURLWithPath: "/usr/libexec/authopen")
        process.arguments = [ "-c", "-m", "0755", "-w", "/usr/local/bin/erbele"]
        process.standardInput = pipe

        process.launch()

        signal(SIGPIPE, SIG_IGN); // One seems to need this code if someone writes the wrong password three times, otherwise it crashes the application
        writeHandle.write(erbeleData)
        close(writeHandle.fileDescriptor)
        
        process.waitUntilExit()

        let status = process.terminationStatus
        return status
    }
    
    private func installCommandLineUtilityManpage(_ erbeleManPageData: Data) -> Int32 {
        let process = Process()
        let pipe = Pipe()
        let writeHandle = pipe.fileHandleForWriting

        process.executableURL = URL(fileURLWithPath: "/usr/libexec/authopen")
        process.arguments = [ "-c", "-w", "/usr/local/share/man/man1/erbele.1"]
        process.standardInput = pipe

        process.launch()

        writeHandle.write(erbeleManPageData)
        close(writeHandle.fileDescriptor)
        
        process.waitUntilExit()

        let status = process.terminationStatus
        return status
    }

}


