//
//  TagLibWrapper.h
//  KeyFinder
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
                       key:(NSString * _Nullable)key NS_SWIFT_NAME(writeTags(title:artist:album:comment:grouping:key:));

- (NSString * _Nullable)getTitle;
- (NSString * _Nullable)getArtist;
- (NSString * _Nullable)getAlbum;
- (NSString * _Nullable)getComment;
- (NSString * _Nullable)getGrouping;
- (NSString * _Nullable)getKey;

@end

NS_ASSUME_NONNULL_END
