
using System;
using Foundation;
using ObjCRuntime;

namespace TruvideoMediaiOS {

// @interface MediaResponse : NSObject
[BaseType (typeof(NSObject), Name = "_TtC13TruvideoMedia13MediaResponse")]
[DisableDefaultCtor]
interface MediaResponse
{
	// @property (readonly, copy, nonatomic) NSDate * _Nonnull createdDate;
	[Export ("createdDate", ArgumentSemantic.Copy)]
	NSDate CreatedDate { get; }

	// @property (readonly, copy, nonatomic) NSString * _Nonnull remoteId;
	[Export ("remoteId")]
	string RemoteId { get; }

	// @property (readonly, nonatomic) float transcriptionLength;
	[Export ("transcriptionLength")]
	float TranscriptionLength { get; }

	// @property (readonly, copy, nonatomic) NSURL * _Nullable transcriptionURL;
	[NullAllowed, Export ("transcriptionURL", ArgumentSemantic.Copy)]
	NSUrl TranscriptionURL { get; }

	// @property (readonly, copy, nonatomic) NSURL * _Nonnull uploadedFileURL;
	[Export ("uploadedFileURL", ArgumentSemantic.Copy)]
	NSUrl UploadedFileURL { get; }
}

// @interface TruvideoMedia : NSObject
[BaseType (typeof(NSObject), Name = "_TtC13TruvideoMedia13TruvideoMedia")]
[DisableDefaultCtor]
interface TruvideoMedia
{
	// @property (readonly, nonatomic, strong, class) TruvideoMedia * _Nonnull shared;
	[Static]
	[Export ("shared", ArgumentSemantic.Strong)]
	TruvideoMedia Shared { get; }

	// -(void)uploadWithPath:(NSString * _Nonnull)path completion:(void (^ _Nonnull)(MediaResponse * _Nullable, NSError * _Nullable))completion;
	[Export ("uploadWithPath:completion:")]
	void UploadWithPath (string path, Action<MediaResponse, NSError> completion);
}
}