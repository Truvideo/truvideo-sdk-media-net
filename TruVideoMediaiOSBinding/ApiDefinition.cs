
using System;
using System.Runtime.InteropServices.JavaScript;
using Foundation;
using ObjCRuntime;


namespace TruvideoMediaiOS {

    // Define the delegate interface (protocol)
    [BaseType(typeof(NSObject))]
    [Protocol,Model]
    interface TruvideoMediaUploadDelegate
    {
        // The Swift function is: func uploadProgress(updated progress: Double)
        [Export("uploadProgressWithUpdated:")] // ✅ Corrected Export
          void UploadProgress(double updated);

    }

    // @interface MediaResponse : NSObject
    [BaseType(typeof(NSObject), Name = "_TtC13TruvideoMedia13MediaResponse")]
    [DisableDefaultCtor]
    interface MediaResponse
    {
        // @property (readonly, copy, nonatomic) NSDate * _Nonnull createdDate;
        [Export("createdDate", ArgumentSemantic.Copy)]
        NSDate CreatedDate { get; }

        // @property (readonly, copy, nonatomic) NSString * _Nonnull remoteId;
        [Export("remoteId")]
        string RemoteId { get; }

        // @property (readonly, nonatomic) float transcriptionLength;
        [Export("transcriptionLength")]
        float TranscriptionLength { get; }

        // @property (readonly, copy, nonatomic) NSURL * _Nullable transcriptionURL;
        [NullAllowed, Export("transcriptionURL", ArgumentSemantic.Copy)]
        NSUrl TranscriptionURL { get; }

        // @property (readonly, copy, nonatomic) NSURL * _Nonnull uploadedFileURL;
        [Export("uploadedFileURL", ArgumentSemantic.Copy)]
        NSUrl UploadedFileURL { get; }
        
        [Export("tags")]
        NSDictionary Tags { get; }
        
        [Export("metadata")]
        NSDictionary Metadata { get; }
        
        [Export("type")]
        NSString Type { get; }
        
    }
    
    // @interface TruvideoMedia : NSObject
    [BaseType(typeof(NSObject), Name = "_TtC13TruvideoMedia13TruvideoMedia")]
    [DisableDefaultCtor]
    interface TruvideoMedia
    {
        // @property (readonly, nonatomic, strong, class) TruvideoMedia * _Nonnull shared;
        [Static]
        [Export("shared", ArgumentSemantic.Strong)]
        TruvideoMedia Shared { get; }

        // Add delegate property
        [NullAllowed, Export("delegate", ArgumentSemantic.Weak)]
        TruvideoMediaUploadDelegate Delegate { get; set; }

        // -(void)uploadWithPath:(NSString * _Nonnull)path tag:(NSString * _Nonnull)tag metaData:(NSString * _Nonnull)metaData completion:(void (^ _Nonnull)(MediaResponse * _Nullable, NSError * _Nullable))completion;
        [Export("uploadWithPath:tag:metaData:completion:")]
        void UploadMedia(string path, string tag, string metaData, Action<MediaResponse, NSError> completion);
        
        [Export("searchWithType:tags:pageNumber:size:completion:")]
        void Search(MediaType type, string tags, int pageNumber, int size, Action<NSArray, NSError> completion);
    }
}
