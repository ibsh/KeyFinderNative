//
//  TagLibWrapper.h
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 22/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PreferencesWrapperObjC;

NS_ASSUME_NONNULL_BEGIN

@interface TagLibWrapper : NSObject

- (instancetype)initWithURL:(NSURL *)url;

- (void)writeTagsWithTitle:(NSString * _Nullable)title
                    artist:(NSString * _Nullable)artist
                     album:(NSString * _Nullable)album
                   comment:(NSString * _Nullable)comment
                  grouping:(NSString * _Nullable)grouping
                       key:(NSString * _Nullable)key;

- (NSString *)getTitle;
- (NSString *)getArtist;
- (NSString *)getAlbum;
- (NSString *)getComment;
- (NSString *)getGrouping;
- (NSString *)getKey;

@end

NS_ASSUME_NONNULL_END
