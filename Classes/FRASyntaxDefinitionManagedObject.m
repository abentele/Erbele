/*
 Fraise version 3.7 - Based on Smultron by Peter Borg
 
 Current Maintainer (since 2016): 
 Andreas Bentele: abentele.github@icloud.com (https://github.com/abentele/Fraise)
 
 Maintainer before macOS Sierra (2010-2016): 
 Jean-François Moy: jeanfrancois.moy@gmail.com (http://github.com/jfmoy/Fraise)

 Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

#import "FRASyntaxDefinitionManagedObject.h"
#import "FRAApplicationDelegate.h"
#import "FRAVariousPerformer.h"

@implementation FRASyntaxDefinitionManagedObject

- (void)didChangeValueForKey:(NSString *)key
{	
	[super didChangeValueForKey:key];
	
	if ([[FRAApplicationDelegate sharedInstance] hasFinishedLaunching] == NO) {
		return;
	}
	
	if ([FRAVarious isChangingSyntaxDefinitionsProgrammatically] == YES) {
		return;
	}

	NSDictionary *changedObject = @{@"name": [self valueForKey:@"name"], @"extensions": [self valueForKey:@"extensions"]};
	if ([FRADefaults valueForKey:@"ChangedSyntaxDefinitions"]) {
		NSMutableArray *changedSyntaxDefinitionsArray = [NSMutableArray arrayWithArray:[FRADefaults valueForKey:@"ChangedSyntaxDefinitions"]];
		NSArray *array = [NSArray arrayWithArray:changedSyntaxDefinitionsArray];
		for (id item in array) {
			if ([[item valueForKey:@"name"] isEqualToString:[self valueForKey:@"name"]]) {
				[changedSyntaxDefinitionsArray removeObject:item];
			}					
		}
		[changedSyntaxDefinitionsArray addObject:changedObject];
		[FRADefaults setValue:changedSyntaxDefinitionsArray forKey:@"ChangedSyntaxDefinitions"];
	} else {
		[FRADefaults setValue:@[changedObject] forKey:@"ChangedSyntaxDefinitions"];		
	}
}
@end
