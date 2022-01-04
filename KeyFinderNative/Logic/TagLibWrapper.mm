//
//  TagLibWrapper.m
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 22/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

#import "TagLibWrapper.h"

#import "TagLib/tag.h"
#import "TagLib/taglib.h"
#import "TagLib/fileref.h"
#import "TagLib/tfile.h"
#import "TagLib/id3v1tag.h"
#import "TagLib/id3v2tag.h"
#import "TagLib/textidentificationframe.h"
#import "TagLib/commentsframe.h"
#import "TagLib/asftag.h"
#import "TagLib/apetag.h"
#import "TagLib/mp4tag.h"
#import "TagLib/apefile.h"
#import "TagLib/asffile.h"
#import "TagLib/flacfile.h"
#import "TagLib/mp4file.h"
#import "TagLib/mpcfile.h"
#import "TagLib/mpegfile.h"
#import "TagLib/oggfile.h"
#import "TagLib/oggflacfile.h"
#import "TagLib/speexfile.h"
#import "TagLib/vorbisfile.h"
#import "TagLib/rifffile.h"
#import "TagLib/aifffile.h"
#import "TagLib/wavfile.h"
#import "TagLib/trueaudiofile.h"
#import "TagLib/wavpackfile.h"

#pragma mark - AVFileMetadata header

class AVFileMetadata {
public:
    AVFileMetadata(TagLib::FileRef* fr, TagLib::File* f);
    virtual ~AVFileMetadata();
    virtual NSString * getTitle() const;
    virtual NSString * getArtist() const;
    virtual NSString * getAlbum() const;
    virtual NSString * getComment() const;
    virtual NSString * getGrouping() const;
    virtual NSString * getKey() const;
    virtual bool setTitle(NSString *);
    virtual bool setArtist(NSString *);
    virtual bool setAlbum(NSString *);
    virtual bool setComment(NSString *);
    virtual bool setGrouping(NSString *);
    virtual bool setKey(NSString *);
protected:
    TagLib::FileRef * fr;
    TagLib::File * genericFile;
};

#pragma mark - NullFileMetadata header

class NullFileMetadata : public AVFileMetadata {
public:
    NullFileMetadata(TagLib::FileRef* fr, TagLib::File* f);
    virtual ~NullFileMetadata();
    virtual NSString * getTitle() const;
    virtual NSString * getArtist() const;
    virtual NSString * getAlbum() const;
    virtual NSString * getComment() const;
    virtual bool setTitle(NSString *);
    virtual bool setArtist(NSString *);
    virtual bool setAlbum(NSString *);
    virtual bool setComment(NSString *);
};

#pragma mark - FlacFileMetadata header

class FlacFileMetadata : public AVFileMetadata {
public:
    FlacFileMetadata(TagLib::FileRef* fr, TagLib::File* g, TagLib::FLAC::File* s);
    virtual NSString * getComment() const;
    virtual NSString * getKey() const;
    virtual bool setComment(NSString *);
    virtual bool setKey(NSString *);
    TagLib::FLAC::File* flacFile;
};

#pragma mark - MpegID3FileMetadata header

class MpegID3FileMetadata : public AVFileMetadata {
public:
    MpegID3FileMetadata(TagLib::FileRef* fr, TagLib::File* g, TagLib::MPEG::File* s);
    virtual NSString * getGrouping() const;
    virtual NSString * getKey() const;
    bool hasId3v1Tag() const;
    bool hasId3v2Tag() const;
    bool hasId3v2_3Tag() const;
    bool hasId3v2_4Tag() const;
    virtual bool setTitle(NSString *);
    virtual bool setArtist(NSString *);
    virtual bool setAlbum(NSString *);
    virtual bool setComment(NSString *);
    virtual bool setGrouping(NSString *);
    virtual bool setKey(NSString *);
protected:
    TagLib::MPEG::File* mpegFile;
    NSString * getGroupingId3(const TagLib::ID3v2::Tag* tag) const;
    NSString * getKeyId3(const TagLib::ID3v2::Tag* tag) const;
    void setITunesCommentId3(TagLib::ID3v2::Tag* tag, NSString *value);
    bool setGroupingId3(TagLib::ID3v2::Tag* tag, NSString *value);
    bool setKeyId3(TagLib::ID3v2::Tag* tag, NSString *value);
};

#pragma mark - AiffID3FileMetadata header

class AiffID3FileMetadata : public MpegID3FileMetadata {
public:
    AiffID3FileMetadata(TagLib::FileRef* fr, TagLib::File* g, TagLib::RIFF::AIFF::File* s);
    virtual NSString * getGrouping() const;
    virtual NSString * getKey() const;
    virtual bool setTitle(NSString *);
    virtual bool setArtist(NSString *);
    virtual bool setAlbum(NSString *);
    virtual bool setComment(NSString *);
    virtual bool setGrouping(NSString *);
    virtual bool setKey(NSString *);
protected:
    TagLib::RIFF::AIFF::File* aiffFile;
};

#pragma mark - WavID3FileMetadata header

class WavID3FileMetadata : public AiffID3FileMetadata {
public:
    WavID3FileMetadata(TagLib::FileRef* fr, TagLib::File* g, TagLib::RIFF::WAV::File* s);
    virtual NSString * getGrouping() const;
    virtual NSString * getKey() const;
    virtual bool setTitle(NSString *);
    virtual bool setArtist(NSString *);
    virtual bool setAlbum(NSString *);
    virtual bool setComment(NSString *);
    virtual bool setGrouping(NSString *);
    virtual bool setKey(NSString *);
protected:
    TagLib::RIFF::WAV::File* wavFile;
};

#pragma mark - Mp4FileMetadata header

class Mp4FileMetadata : public AVFileMetadata {
public:
    Mp4FileMetadata(TagLib::FileRef* fr, TagLib::File* g, TagLib::MP4::File* s);
    virtual NSString * getGrouping() const;
    virtual NSString * getKey() const;
    virtual bool setGrouping(NSString *);
    virtual bool setKey(NSString *);
protected:
    TagLib::MP4::File* mp4File;
};

#pragma mark - AsfFileMetadata header

class AsfFileMetadata : public AVFileMetadata {
public:
    AsfFileMetadata(TagLib::FileRef* fr, TagLib::File* g, TagLib::ASF::File* s);
    virtual NSString * getGrouping() const;
    virtual NSString * getKey() const;
    virtual bool setGrouping(NSString *);
    virtual bool setKey(NSString *);
protected:
    TagLib::ASF::File* asfFile;
};

#pragma mark - Constants

const char* keyXiphTagComment      = "COMMENT";
const char* keyId3TagiTunesComment = "COMM";
const char* lngId3TagiTunesComment = "eng"; // TODO will this mess up localisations?
const char* keyMp4TagGrouping      = "\251grp";
const char* keyAsfTagGrouping      = "WM/ContentGroupDescription";
const char* keyApeTagGrouping      = "Grouping";
const char* keyId3TagGrouping      = "TIT1";
const char* keyId3TagKey           = "TKEY";
const char* keyMp4TagKey           = "----:com.apple.iTunes:initialkey";
const char* keyXiphTagKey          = "INITIALKEY";
const char* keyAsfTagKey           = "WM/InitialKey";

#pragma mark - Constructors

AVFileMetadata::AVFileMetadata(TagLib::FileRef* inFr, TagLib::File* f) : fr(inFr), genericFile(f) { }

NullFileMetadata::NullFileMetadata      (TagLib::FileRef* fr, TagLib::File* g)                              : AVFileMetadata     (fr, g)       { }
FlacFileMetadata::FlacFileMetadata      (TagLib::FileRef* fr, TagLib::File* g, TagLib::FLAC::File* s)       : AVFileMetadata     (fr, g)       { flacFile = s; }
MpegID3FileMetadata::MpegID3FileMetadata(TagLib::FileRef* fr, TagLib::File* g, TagLib::MPEG::File* s)       : AVFileMetadata     (fr, g)       { mpegFile = s; }
AiffID3FileMetadata::AiffID3FileMetadata(TagLib::FileRef* fr, TagLib::File* g, TagLib::RIFF::AIFF::File* s) : MpegID3FileMetadata(fr, g, NULL) { aiffFile = s; }
WavID3FileMetadata::WavID3FileMetadata  (TagLib::FileRef* fr, TagLib::File* g, TagLib::RIFF::WAV::File* s)  : AiffID3FileMetadata(fr, g, NULL) { wavFile = s; }
Mp4FileMetadata::Mp4FileMetadata        (TagLib::FileRef* fr, TagLib::File* g, TagLib::MP4::File* s)        : AVFileMetadata     (fr, g)       { mp4File = s; }
AsfFileMetadata::AsfFileMetadata        (TagLib::FileRef* fr, TagLib::File* g, TagLib::ASF::File* s)        : AVFileMetadata     (fr, g)       { asfFile = s; }

#pragma mark - Destructors

AVFileMetadata::~AVFileMetadata() { delete fr; }
NullFileMetadata::~NullFileMetadata() { }

#pragma mark - AVFileMetadata implementation

NSString * AVFileMetadata::getTitle() const {
    TagLib::String value = genericFile->tag()->title();
    return [NSString stringWithUTF8String:value.toCString(true)];
}

NSString * AVFileMetadata::getArtist() const {
    TagLib::String value = genericFile->tag()->artist();
    return [NSString stringWithUTF8String:value.toCString(true)];
}

NSString * AVFileMetadata::getAlbum() const {
    TagLib::String value = genericFile->tag()->album();
    return [NSString stringWithUTF8String:value.toCString(true)];
}

NSString * AVFileMetadata::getComment() const {
    TagLib::String value = genericFile->tag()->comment();
    return [NSString stringWithUTF8String:value.toCString(true)];
}

NSString * AVFileMetadata::getGrouping() const {
    return @"NOT APPLICABLE FIXME";
}

NSString * AVFileMetadata::getKey() const {
    return @"NOT APPLICABLE FIXME";
}

bool AVFileMetadata::setTitle(NSString *value) {
    genericFile->tag()->setTitle(TagLib::String([value UTF8String], TagLib::String::UTF8));
    genericFile->save();
    return true;
}

bool AVFileMetadata::setArtist(NSString *value) {
    genericFile->tag()->setArtist(TagLib::String([value UTF8String], TagLib::String::UTF8));
    genericFile->save();
    return true;
}

bool AVFileMetadata::setAlbum(NSString *value) {
    genericFile->tag()->setAlbum(TagLib::String([value UTF8String], TagLib::String::UTF8));
    genericFile->save();
    return true;
}

bool AVFileMetadata::setComment(NSString *value) {
    genericFile->tag()->setComment(TagLib::String([value UTF8String], TagLib::String::UTF8));
    genericFile->save();
    return true;
}

bool AVFileMetadata::setGrouping(NSString */*grp*/) {
    return false;
}

bool AVFileMetadata::setKey(NSString */*key*/) {
    return false;
}

#pragma mark - NullFileMetadata implementation

NSString * NullFileMetadata::getTitle() const {
    return @"NOT APPLICABLE FIXME";
}

NSString * NullFileMetadata::getArtist() const {
    return @"NOT APPLICABLE FIXME";
}

NSString * NullFileMetadata::getAlbum() const {
    return @"NOT APPLICABLE FIXME";
}

NSString * NullFileMetadata::getComment() const {
    return @"NOT APPLICABLE FIXME";
}

bool NullFileMetadata::setTitle(NSString */*tit*/) {
    return false;
}

bool NullFileMetadata::setArtist(NSString */*tit*/) {
    return false;
}

bool NullFileMetadata::setAlbum(NSString */*tit*/) {
    return false;
}

bool NullFileMetadata::setComment(NSString */*cmt*/) {
    return false;
}

#pragma mark - FlacFileMetadata implementation

NSString * FlacFileMetadata::getComment() const {
    // TagLib's default behaviour treats Description as Comment
    if (flacFile->xiphComment()->contains(keyXiphTagComment)) {

        TagLib::String value = flacFile->xiphComment()->fieldListMap()[keyXiphTagComment].toString();
        return [NSString stringWithUTF8String:value.toCString(true)];

    } else {

        return [NSString string];
    }
}

NSString * FlacFileMetadata::getKey() const {
    TagLib::Ogg::XiphComment* c = flacFile->xiphComment();
    if (!c->fieldListMap().contains(keyXiphTagKey)) {
        return [NSString string];
    }
    TagLib::String value = c->fieldListMap()[keyXiphTagKey].toString();
    return [NSString stringWithUTF8String:value.toCString(true)];
}

bool FlacFileMetadata::setComment(NSString *value) {
    // TagLib's default behaviour treats Description as Comment
    flacFile->xiphComment()->addField(keyXiphTagComment, TagLib::String([value UTF8String], TagLib::String::UTF8), true);
    genericFile->save();
    return true;
}

bool FlacFileMetadata::setKey(NSString *value) {
    flacFile->xiphComment()->addField(keyXiphTagKey, TagLib::String([value UTF8String], TagLib::String::UTF8), true);
    flacFile->save();
    return true;
}

#pragma mark - MpegID3FileMetadata implementation

bool MpegID3FileMetadata::hasId3v1Tag() const {
    if (mpegFile == NULL) return false; // AIFF or WAV subclasses
    return !mpegFile->ID3v1Tag()->isEmpty();
}

bool MpegID3FileMetadata::hasId3v2Tag() const {
    if (mpegFile == NULL) return true; // AIFF or WAV subclasses
    return !mpegFile->ID3v2Tag()->isEmpty();
}

bool MpegID3FileMetadata::hasId3v2_3Tag() const {
    if (mpegFile == NULL) return true; // AIFF or WAV subclasses
    if (!hasId3v2Tag()) return false;
    if (mpegFile->ID3v2Tag()->header()->majorVersion() != 3) return false;
    return true;
}

bool MpegID3FileMetadata::hasId3v2_4Tag() const {
    if (mpegFile == NULL) return true; // AIFF or WAV subclasses
    if (!hasId3v2Tag()) return false;
    if (mpegFile->ID3v2Tag()->header()->majorVersion() != 4) return false;
    return true;
}

NSString * MpegID3FileMetadata::getGrouping() const {
    if (!hasId3v2Tag()) return @"NOT APPLICABLE FIXME";
    return getGroupingId3(mpegFile->ID3v2Tag());
}

NSString * MpegID3FileMetadata::getGroupingId3(const TagLib::ID3v2::Tag* tag) const {
    if (!tag->frameListMap().contains(keyId3TagGrouping)) return [NSString string];
    TagLib::ID3v2::FrameList l = tag->frameListMap()[keyId3TagGrouping];
    TagLib::String value = l.front()->toString();
    return [NSString stringWithUTF8String:value.toCString(true)];
}

NSString * MpegID3FileMetadata::getKey() const {
    if (!hasId3v2Tag()) return @"NOT APPLICABLE FIXME";
    return getKeyId3(mpegFile->ID3v2Tag());
}

NSString * MpegID3FileMetadata::getKeyId3(const TagLib::ID3v2::Tag* tag) const {
    if (!tag->frameListMap().contains(keyId3TagKey)) return [NSString string];
    TagLib::ID3v2::FrameList l = tag->frameListMap()[keyId3TagKey];
    TagLib::String value = l.front()->toString();
    return [NSString stringWithUTF8String:value.toCString(true)];
}

bool MpegID3FileMetadata::setTitle(NSString *value) {
    bool written = false;
    if (hasId3v1Tag()) {
        // TagLib's default save behaviour will write a v2 ID3 tag where none exists
        mpegFile->ID3v1Tag()->setTitle(TagLib::String([value UTF8String], TagLib::String::UTF8));
        mpegFile->save(TagLib::MPEG::File::ID3v1, false);
        written = true;
    }
    if (hasId3v2Tag()) {
        mpegFile->ID3v2Tag()->setTitle(TagLib::String([value UTF8String], TagLib::String::UTF8));
        mpegFile->save(TagLib::MPEG::File::ID3v2, false, mpegFile->ID3v2Tag()->header()->majorVersion());
        written = true;
    }
    return written;
}

bool MpegID3FileMetadata::setArtist(NSString *value) {
    bool written = false;
    if (hasId3v1Tag()) {
        mpegFile->ID3v1Tag()->setArtist(TagLib::String([value UTF8String], TagLib::String::UTF8));
        mpegFile->save(TagLib::MPEG::File::ID3v1, false);
        written = true;
    }
    if (hasId3v2Tag()) {
        mpegFile->ID3v2Tag()->setArtist(TagLib::String([value UTF8String], TagLib::String::UTF8));
        mpegFile->save(TagLib::MPEG::File::ID3v2, false, mpegFile->ID3v2Tag()->header()->majorVersion());
        written = true;
    }
    return written;
}

bool MpegID3FileMetadata::setAlbum(NSString *value) {
    bool written = false;
    if (hasId3v1Tag()) {
        mpegFile->ID3v1Tag()->setAlbum(TagLib::String([value UTF8String], TagLib::String::UTF8));
        mpegFile->save(TagLib::MPEG::File::ID3v1, false);
        written = true;
    }
    if (hasId3v2Tag()) {
        mpegFile->ID3v2Tag()->setAlbum(TagLib::String([value UTF8String], TagLib::String::UTF8));
        mpegFile->save(TagLib::MPEG::File::ID3v2, false, mpegFile->ID3v2Tag()->header()->majorVersion());
        written = true;
    }
    return written;
}

bool MpegID3FileMetadata::setComment(NSString *value) {
    bool written = false;
    if (hasId3v1Tag()) {
        mpegFile->ID3v1Tag()->setComment(TagLib::String([value UTF8String], TagLib::String::UTF8));
        mpegFile->save(TagLib::MPEG::File::ID3v1, false);
        written = true;
    }
    if (hasId3v2Tag()) {
        // basic tag
        mpegFile->ID3v2Tag()->setComment(TagLib::String([value UTF8String], TagLib::String::UTF8));
        mpegFile->save(TagLib::MPEG::File::ID3v2, false, mpegFile->ID3v2Tag()->header()->majorVersion());
        // iTunes comment hack
        setITunesCommentId3(mpegFile->ID3v2Tag(), value);
        mpegFile->save(TagLib::MPEG::File::ID3v2, false, mpegFile->ID3v2Tag()->header()->majorVersion());
        written = true;
    }
    return written;
}

void MpegID3FileMetadata::setITunesCommentId3(TagLib::ID3v2::Tag* tag, NSString *value) {
    if (tag->frameListMap().contains(keyId3TagiTunesComment)) {
        const TagLib::ID3v2::FrameList &comments = tag->frameListMap()[keyId3TagiTunesComment];
        bool found = false;
        for (TagLib::ID3v2::FrameList::ConstIterator it = comments.begin(); it != comments.end(); it++) {
            // overwrite all appropriate comment elements
            TagLib::ID3v2::CommentsFrame *commFrame = dynamic_cast<TagLib::ID3v2::CommentsFrame *>(*it);
            if (commFrame && commFrame->description().isEmpty()) {
                commFrame->setLanguage(lngId3TagiTunesComment);
                commFrame->setText(TagLib::String([value UTF8String], TagLib::String::UTF8));
                // we don't save here, because MPEGs need v2.3 / 2.4 handling.
                found = true;
            }
        }
        if (found) return;
    }
    TagLib::ID3v2::CommentsFrame* frm = new TagLib::ID3v2::CommentsFrame();
    frm->setText(TagLib::String([value UTF8String], TagLib::String::UTF8));
    frm->setLanguage(lngId3TagiTunesComment);
    tag->addFrame(frm);
    // again, don't save here.
    return;
}

bool MpegID3FileMetadata::setGrouping(NSString *value) {
    if (!hasId3v2Tag()) return false; // ID3v1 doesn't support Grouping
    setGroupingId3(mpegFile->ID3v2Tag(), value);
    mpegFile->save(TagLib::MPEG::File::ID3v2, true, mpegFile->ID3v2Tag()->header()->majorVersion());
    return true;
}

bool MpegID3FileMetadata::setGroupingId3(TagLib::ID3v2::Tag* tag, NSString *value) {
    TagLib::ID3v2::Frame* frm = new TagLib::ID3v2::TextIdentificationFrame(keyId3TagGrouping);
    frm->setText(TagLib::String([value UTF8String], TagLib::String::UTF8));
    tag->removeFrames(keyId3TagGrouping);
    tag->addFrame(frm);
    // again, don't save here
    return true;
}

bool MpegID3FileMetadata::setKey(NSString *value) {
    if (!hasId3v2Tag()) return false; // ID3v1 doesn't support Key
    setKeyId3(mpegFile->ID3v2Tag(), value);
    mpegFile->save(TagLib::MPEG::File::ID3v2, false, mpegFile->ID3v2Tag()->header()->majorVersion());
    return true;
}

bool MpegID3FileMetadata::setKeyId3(TagLib::ID3v2::Tag* tag, NSString *value) {
    TagLib::ID3v2::Frame* frm = new TagLib::ID3v2::TextIdentificationFrame(keyId3TagKey);
    frm->setText(TagLib::String([value UTF8String], TagLib::String::UTF8));
    tag->removeFrames(keyId3TagKey);
    tag->addFrame(frm);
    // again, don't save in here
    return true;
}

#pragma mark - AiffID3FileMetadata implementation

NSString * AiffID3FileMetadata::getGrouping() const {
    return getGroupingId3(aiffFile->tag());
}

NSString * AiffID3FileMetadata::getKey() const {
    return getKeyId3(aiffFile->tag());
}

bool AiffID3FileMetadata::setTitle(NSString *value) {
    aiffFile->tag()->setTitle(TagLib::String([value UTF8String], TagLib::String::UTF8));
    aiffFile->save();
    return true;
}

bool AiffID3FileMetadata::setArtist(NSString *value) {
    aiffFile->tag()->setArtist(TagLib::String([value UTF8String], TagLib::String::UTF8));
    aiffFile->save();
    return true;
}

bool AiffID3FileMetadata::setAlbum(NSString *value) {
    aiffFile->tag()->setAlbum(TagLib::String([value UTF8String], TagLib::String::UTF8));
    aiffFile->save();
    return true;
}

bool AiffID3FileMetadata::setComment(NSString *value) {
    // basic tag
    genericFile->tag()->setComment(TagLib::String([value UTF8String], TagLib::String::UTF8));
    // iTunes comment hack
    setITunesCommentId3(aiffFile->tag(), value);
    aiffFile->save();
    return true;
}

bool AiffID3FileMetadata::setGrouping(NSString *value) {
    setGroupingId3(aiffFile->tag(), value);
    aiffFile->save();
    return true;
}

bool AiffID3FileMetadata::setKey(NSString *value) {
    setKeyId3(aiffFile->tag(), value);
    aiffFile->save();
    return true;
}

#pragma mark - WavID3FileMetadata implementation

NSString * WavID3FileMetadata::getGrouping() const {
    return getGroupingId3(wavFile->tag());
}

NSString * WavID3FileMetadata::getKey() const {
    return getKeyId3(wavFile->tag());
}

bool WavID3FileMetadata::setTitle(NSString *value) {
    wavFile->tag()->setTitle(TagLib::String([value UTF8String], TagLib::String::UTF8));
    wavFile->save();
    return true;
}

bool WavID3FileMetadata::setArtist(NSString *value) {
    wavFile->tag()->setArtist(TagLib::String([value UTF8String], TagLib::String::UTF8));
    wavFile->save();
    return true;
}

bool WavID3FileMetadata::setAlbum(NSString *value) {
    wavFile->tag()->setAlbum(TagLib::String([value UTF8String], TagLib::String::UTF8));
    wavFile->save();
    return true;
}

bool WavID3FileMetadata::setComment(NSString *value) {
    genericFile->tag()->setComment(TagLib::String([value UTF8String], TagLib::String::UTF8));
    genericFile->save();
    return true;
}

bool WavID3FileMetadata::setGrouping(NSString *value) {
    setGroupingId3(wavFile->tag(), value);
    wavFile->save();
    return true;
}

bool WavID3FileMetadata::setKey(NSString *value) {
    setKeyId3(wavFile->tag(), value);
    wavFile->save();
    return true;
}

#pragma mark - Mp4FileMetadata implementation

NSString * Mp4FileMetadata::getGrouping() const {
    if (!mp4File->tag()->itemListMap().contains(keyMp4TagGrouping)) return [NSString string];
    TagLib::MP4::Item m = mp4File->tag()->itemListMap()[keyMp4TagGrouping];
    TagLib::String value = m.toStringList().front();
    return [NSString stringWithUTF8String:value.toCString(true)];
}

NSString * Mp4FileMetadata::getKey() const {
    if (!mp4File->tag()->itemListMap().contains(keyMp4TagKey)) return [NSString string];
    TagLib::MP4::Item m = mp4File->tag()->itemListMap()[keyMp4TagKey];
    TagLib::String value = m.toStringList().front();
    return [NSString stringWithUTF8String:value.toCString(true)];
}

bool Mp4FileMetadata::setGrouping(NSString *value) {
    TagLib::StringList sl(TagLib::String([value UTF8String], TagLib::String::UTF8));
    mp4File->tag()->itemListMap().insert(keyMp4TagGrouping, sl);
    mp4File->save();
    return true;
}

bool Mp4FileMetadata::setKey(NSString *value) {
    TagLib::StringList sl(TagLib::String([value UTF8String], TagLib::String::UTF8));
    mp4File->tag()->itemListMap().insert(keyMp4TagKey, sl);
    mp4File->save();
    return true;
}

#pragma mark - AsfFileMetadata implementation

NSString * AsfFileMetadata::getGrouping() const {
    if (!asfFile->tag()->attributeListMap().contains(keyAsfTagGrouping)) return [NSString string];
    TagLib::ASF::AttributeList l = asfFile->tag()->attributeListMap()[keyAsfTagGrouping];
    TagLib::String value = l.front().toString();
    return [NSString stringWithUTF8String:value.toCString(true)];
}

NSString * AsfFileMetadata::getKey() const {
    if (!asfFile->tag()->attributeListMap().contains(keyAsfTagKey)) return [NSString string];
    TagLib::ASF::AttributeList l = asfFile->tag()->attributeListMap()[keyAsfTagKey];
    TagLib::String value = l.front().toString();
    return [NSString stringWithUTF8String:value.toCString(true)];
}

bool AsfFileMetadata::setGrouping(NSString *value) {
    asfFile->tag()->setAttribute(keyAsfTagGrouping, TagLib::String([value UTF8String], TagLib::String::UTF8));
    asfFile->save();
    return true;
}

bool AsfFileMetadata::setKey(NSString *value) {
    asfFile->tag()->setAttribute(keyAsfTagKey, TagLib::String([value UTF8String], TagLib::String::UTF8));
    asfFile->save();
    return true;
}

#pragma mark - Metadata factory header

class AVFileMetadataFactory {
public:
    AVFileMetadata* createAVFileMetadata(NSString *) const;
};

#pragma mark - Metadata factory implementation

AVFileMetadata* AVFileMetadataFactory::createAVFileMetadata(NSString *filePath) const {

    TagLib::File* f = NULL;

    TagLib::FileRef* fr = new TagLib::FileRef([filePath UTF8String]);
    if (!fr->isNull()) {
        f = fr->file();
    }

    if (f == NULL || !f->isValid()) {
        delete fr;
        return new NullFileMetadata(NULL, NULL);
    }

    TagLib::FLAC::File* fileTestFlac = dynamic_cast<TagLib::FLAC::File*>(f);
    if (fileTestFlac != NULL) return new FlacFileMetadata(fr, f, fileTestFlac);

    TagLib::MPEG::File* fileTestMpeg = dynamic_cast<TagLib::MPEG::File*>(f);
    if (fileTestMpeg != NULL) return new MpegID3FileMetadata(fr, f, fileTestMpeg);

    TagLib::RIFF::AIFF::File* fileTestAiff = dynamic_cast<TagLib::RIFF::AIFF::File*>(f);
    if (fileTestAiff != NULL) return new AiffID3FileMetadata(fr, f, fileTestAiff);

    TagLib::RIFF::WAV::File* fileTestWav = dynamic_cast<TagLib::RIFF::WAV::File*>(f);
    if (fileTestWav != NULL) return new WavID3FileMetadata(fr, f, fileTestWav);

    TagLib::MP4::File* fileTestMp4 = dynamic_cast<TagLib::MP4::File*>(f);
    if (fileTestMp4 != NULL) return new Mp4FileMetadata(fr, f, fileTestMp4);

    TagLib::ASF::File* fileTestAsf = dynamic_cast<TagLib::ASF::File*>(f);
    if (fileTestAsf != NULL) return new AsfFileMetadata(fr, f, fileTestAsf);

    return new AVFileMetadata(fr, f);
}


@interface TagLibWrapper ()

@property (nonatomic, assign, readwrite) AVFileMetadata *metadata;

@end

@implementation TagLibWrapper

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        AVFileMetadataFactory *factory = new AVFileMetadataFactory();
        self.metadata = factory->createAVFileMetadata(url.path);
    }
    return self;
}

- (void)dealloc {
    delete self.metadata;
}

- (void)writeTagsWithTitle:(NSString * _Nullable)title
                    artist:(NSString * _Nullable)artist
                     album:(NSString * _Nullable)album
                   comment:(NSString * _Nullable)comment
                  grouping:(NSString * _Nullable)grouping
                       key:(NSString * _Nullable)key {

    if (title != NULL) {
        self.metadata->setTitle(title);
    }

    if (artist != NULL) {
        self.metadata->setArtist(artist);
    }

    if (album != NULL) {
        self.metadata->setAlbum(album);
    }

    if (comment != NULL) {
        self.metadata->setComment(comment);
    }

    if (grouping != NULL) {
        self.metadata->setGrouping(grouping);
    }

    if (key != NULL) {
        self.metadata->setKey(key);
    }
}

- (NSString *)getTitle {
    return self.metadata->getTitle();
}

- (NSString *)getArtist {
    return self.metadata->getArtist();
}

- (NSString *)getAlbum {
    return self.metadata->getAlbum();
}

- (NSString *)getComment {
    return self.metadata->getComment();
}

- (NSString *)getGrouping {
    return self.metadata->getGrouping();
}

- (NSString *)getKey {
    return self.metadata->getKey();
}

@end
