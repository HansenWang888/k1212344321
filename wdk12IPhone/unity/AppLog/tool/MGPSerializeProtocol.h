//
//  MGPSerializeProtocol.h
//  MobileGateWay
//
//  Created by macapp on 17/3/17.
//  Copyright © 2017年 macapp. All rights reserved.
//

#ifndef MGPSerializeProtocol_h
#define MGPSerializeProtocol_h

#import "Object+PluginSerialize.h"
@protocol PluginSerialize <NSObject>


+(id)unserializeFromJsonValue:(id)obj Class:(Class)cls;
-(id)serializeToJsonValue;

@end

#endif /* MGPSerializeProtocol_h */

