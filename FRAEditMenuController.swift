/*
Erbele - Based on Fraise 3.7.3 based on Smultron by Peter Borg

Current Maintainer (since 2016):
Andreas Bentele: abentele.github@icloud.com (https://github.com/abentele/Erbele)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

import Foundation

class FRAEditMenuController : NSObject, NSMenuItemValidation {
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool
    {
        var enableMenuItem = true
        let tag = menuItem.tag
        if (tag == 1 || tag == 11 || tag == 111) { // All items that should only be active when there's text to select/delete
            
            if (FRACurrentTextView() == nil) {
                enableMenuItem = false;
            }
        } else if (tag == 2) { // Live Find
            if (FRACurrentProject()?.areThereAnyDocuments() == false) {
                enableMenuItem = false;
            }
        }
        
        return enableMenuItem;
    }

    @IBAction func advancedFindReplaceAction(_ sender: Any) {
        FRAAdvancedFindController.sharedInstance()?.showAdvancedFindWindow()
    }
    
    @IBAction func liveFindAction(_ sender: Any) {
        let firstResponder = FRACurrentWindow()?.firstResponder
        FRACurrentWindow()?.makeFirstResponder(FRACurrentProject()?.liveFindSearchField());
        let fieldEditor = FRACurrentProject()?.liveFindSearchField()?.window?.firstResponder;
        
        if (firstResponder == fieldEditor) {
            FRACurrentWindow()?.makeFirstResponder(FRACurrentProject()?.lastTextViewInFocus) // If the search field is already in focus switch it back to the text, this allows the user to use the same key command to get to the search field and get back to the selected text after the search is complete
        } else {
            FRACurrentProject()?.prepareForLiveFind();
        }

    }
}
