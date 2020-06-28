/*
Erbele - Based on Fraise 3.7.3 based on Smultron by Peter Borg

Current Maintainer (since 2016):
Andreas Bentele: abentele.github@icloud.com (https://github.com/abentele/Erbele)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

import Foundation

class FRAHelpMenuController : NSObject {
    
    @IBAction func installCommandLineUtilityAction(_ sender: Any) {
        if let attachedSheet = FRACurrentWindow()?.attachedSheet {
            attachedSheet.close();
        }
        
        let alert = NSAlert();
        
        alert.messageText = NSLocalizedString("Are you sure you want to install the command-line utility?", comment: "Ask if they are sure they want to install the command-line utility in Install-command-line-utility sheet");
        alert.informativeText = NSLocalizedString("If you choose Install erbele will be installed in /usr/bin and its man page in /usr/share/man/man1 and you can use it directly in the Terminal (you may need to authenticate twice with an administrators username and password). Otherwise you can choose to place all the files you need on the Desktop and install it manually.", comment: "Indicate that if you choose Install erbele will be installed in /usr/bin and its man page in /usr/share/man/man1 and you can use it directly in the Terminal (you may need to authenticate twice with an administrators username and password). Otherwise you can choose to place all the files you need on the desktop and install it manually. in Install-command-line-utility sheet");
        alert.addButton(withTitle: NSLocalizedString("Install", comment: "Install-button in Install-command-line-utility sheet"));
        alert.addButton(withTitle: NSLocalizedString("Put On Desktop", comment: "Put On Desktop-button in Install-command-line-utility sheet"));
        alert.addButton(withTitle: CANCEL_BUTTON());
        alert.alertStyle = NSAlert.Style.informational;
        
        alert.beginSheetModal(for: FRACurrentWindow()!) { (response) in
            do {
                if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
                    try FRAAuthenticationController.sharedInstance().installCommandLineUtility()
                } else if (response == NSApplication.ModalResponse.alertSecondButtonReturn) {
                    let fileManager = FileManager.default;
                    let pathToFolder = URL(fileURLWithPath: NSHomeDirectory())
                        .appendingPathComponent("Desktop")
                        .appendingPathComponent("Erbele command-line utility")
                    try fileManager.createDirectory(at: pathToFolder, withIntermediateDirectories: true, attributes: nil)
                    try self.copyResource(resource: "erbele", pathToFolder: pathToFolder)
                    try self.copyResource(resource: "erbele.1", pathToFolder: pathToFolder)
                }
            } catch {
                // TODO error handling
            }
        }
    }
    
    func copyResource(resource: String, pathToFolder: URL) throws {
        let fileManager = FileManager.default;
        let toURL = pathToFolder.appendingPathComponent(resource)
        let item = Bundle.main.url(forResource: resource, withExtension: "")!
        try fileManager.copyItem(at: item, to: toURL)
    }

    @IBAction func erbeleHelp(_ sender: Any) {
        NSWorkspace.shared.openFile(Bundle.main.path(forResource: "Erbele-Manual", ofType: "pdf")!)
    }
}




