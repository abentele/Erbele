/*
 Erbele - Based on Fraise 3.7.3 based on Smultron by Peter Borg
 
 Current Maintainer (since 2016):
 Andreas Bentele: abentele.github@icloud.com (https://github.com/abentele/Erbele)
 
 Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

import Foundation

class FRALineNumbersScrollView : NSScrollView {
    
    override init(frame: NSRect) {
        super.init(frame: frame);
        initDefaultAttributes();
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
        initDefaultAttributes();
    }
    
    func initDefaultAttributes() {
        self.borderType = .noBorder;
        hasVerticalScroller = false;
        hasHorizontalScroller = false;
        autoresizingMask = .height;
        contentView.autoresizesSubviews = true;
    }

    
    // disable scrollability of line numbers scroll view
    // TODO could be changed in future to scroll the view synchronous to text view
    override func scrollWheel(with event: NSEvent) {
        // do nothing
    }
    
}
