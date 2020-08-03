/*
Erbele - Based on Fraise 3.7.3 based on Smultron by Peter Borg

Current Maintainer (since 2016):
Andreas Bentele: abentele.github@icloud.com (https://github.com/abentele/Erbele)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

import Foundation

private var _sharedInstance: FRADocumentsMenuController? = nil;

class FRADocumentsMenuController : NSObject, NSMenuDelegate {
    @IBOutlet var documentsMenu: NSMenu?;
    

    @objc class func sharedInstance() -> FRADocumentsMenuController {
        if (_sharedInstance == nil) {
            return FRADocumentsMenuController();
        }
        
        return _sharedInstance!;
    }
    
    override init() {
        super.init()
        _sharedInstance = self;
    }

    override func awakeFromNib() {
        documentsMenu!.delegate = self;
    }

    @IBAction @objc func nextDocumentAction(_ sender: Any?) {
        let currentProject = FRACurrentProject()!;
        let documentsArrayController = currentProject.documentsArrayController!;
        let currentDocument = documentsArrayController.selectionIndex;
        let arrangedObjects: [ Any ] = documentsArrayController.arrangedObjects as! [ Any ]
        if (currentDocument + 2 > currentProject.documents()!.count) {
            documentsArrayController.setSelectedObjects([arrangedObjects[0]])
        } else {
            documentsArrayController.setSelectedObjects([arrangedObjects[currentDocument + 1]])
        }
    }


    @IBAction @objc func previousDocumentAction(_ sender: Any?) {
        let currentProject = FRACurrentProject()!;
        let documentsArrayController = currentProject.documentsArrayController!;
        let currentDocument = documentsArrayController.selectionIndex;
        let arrangedObjects: [ Any ] = documentsArrayController.arrangedObjects as! [ Any ]
        if (currentDocument == 0) {
            documentsArrayController.setSelectedObjects([arrangedObjects[currentProject.documents().count - 1]])
        } else {
            documentsArrayController.setSelectedObjects([arrangedObjects[currentDocument - 1]])
        }
    }


    func buildDocumentsMenu() {
        var menuItem: NSMenuItem
        let menuItemsArray = documentsMenu!.items
        for menuItem in menuItemsArray {
            if (menuItem.action != #selector(self.nextDocumentAction(_:)) &&
                menuItem.action != #selector(self.previousDocumentAction(_:)) &&
                menuItem.isSeparatorItem == false) {
                documentsMenu?.removeItem(menuItem)
            }
        }
        
        let documentsArray = FRACurrentProject()!.documentsArrayController.arrangedObjects as! [ FRADocumentManagedObject ]
        var index = 1
        
        for document in documentsArray {
            let title = document.value(forKey: "name") as! String
            let action = #selector(self.changeSelectedDocument(sender:))
            if (index < 10) {
                menuItem = NSMenuItem(title: title, action: action, keyEquivalent: "\(index)")
            } else if (index == 10) {
                menuItem = NSMenuItem(title: title, action: action, keyEquivalent: "0")
            } else {
                menuItem = NSMenuItem(title: title, action: action, keyEquivalent: "")
            }

            menuItem.target = self
            menuItem.representedObject = document
            documentsMenu!.insertItem(menuItem, at: index + 2)
            index += 1;
        }

        let projectsArray = FRAProjectsController.shared.documents as! [ FRAProject ]
        for project in projectsArray {
            if (project == FRACurrentProject()) {
                continue;
            }
            var menu: NSMenu
            if (project.value(forKey: "name") == nil) {
                menu = NSMenu(title: UNTITLED_PROJECT_NAME())
            } else {
                menu = NSMenu(title: project.value(forKey: "name") as! String)
            }

            let documentsEnumerator = (project.documents().allObjects as NSArray).reverseObjectEnumerator().allObjects as! [ FRADocumentManagedObject ]
            for document in documentsEnumerator {
                menuItem = NSMenuItem(title: document.value(forKey: "name") as! String, action: #selector(self.changeSelectedDocument(sender:)), keyEquivalent: "")
                menuItem.target = self
                menuItem.representedObject = document
                menu.insertItem(menuItem, at: 0);
            }
            
            let subMenuItem = NSMenuItem(title: menu.title, action: nil, keyEquivalent: "")
            subMenuItem.submenu = menu
            documentsMenu!.addItem(subMenuItem)
        }

    }

    @objc func changeSelectedDocument(sender: NSMenuItem) {
        (FRAProjectsController.shared as! FRAProjectsController).selectDocument(sender.representedObject)
    }


    func validateMenuItem(anItem: NSMenuItem) -> Bool {
        var enableMenuItem = true
        if (FRACurrentProject()!.documents()!.count < 2) {
            if (anItem.action == #selector(self.nextDocumentAction(_:)) || anItem.action == #selector(self.previousDocumentAction(_:))) {
                enableMenuItem = false;
            }
        }
        
        return enableMenuItem;
    }


    func menuNeedsUpdate(_ menu: NSMenu) {
        self.buildDocumentsMenu()
    }

}
