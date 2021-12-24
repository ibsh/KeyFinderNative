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

- (void)writeTagsWithResultString:(NSString *)resultString
                   prependToTitle:(BOOL)prependToTitle
                    appendToTitle:(BOOL)appendToTitle
                  prependToArtist:(BOOL)prependToArtist
                   appendToArtist:(BOOL)appendToArtist
                   prependToAlbum:(BOOL)prependToAlbum
                    appendToAlbum:(BOOL)appendToAlbum
                 prependToComment:(BOOL)prependToComment
                  appendToComment:(BOOL)appendToComment
                 overwriteComment:(BOOL)overwriteComment
                prependToGrouping:(BOOL)prependToGrouping
                 appendToGrouping:(BOOL)appendToGrouping
                overwriteGrouping:(BOOL)overwriteGrouping
                     overwriteKey:(BOOL)overwriteKey
                     tagDelimiter:(NSString *)tagDelimiter;

@end

NS_ASSUME_NONNULL_END
