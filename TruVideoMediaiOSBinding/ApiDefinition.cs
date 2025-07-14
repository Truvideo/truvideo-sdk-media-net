using System;
using Foundation;
using ObjCRuntime;

namespace TruvideoMediaiOS
{
    [Protocol, Model]
    [BaseType(typeof(NSObject))]
    interface TruvideoMediaUploadDelegate
    {
        [Abstract]
        [Export("uploadProgressWithUpdated:")]
        void UploadProgress(double updated);
    }

    [BaseType(typeof(NSObject), Name = "_TtC13TruvideoMedia13MediaResponse")]
    interface MediaResponse
    {
        [Export("createdDate", ArgumentSemantic.Copy)]
        NSDate CreatedDate { get; }

        [Export("remoteId")]
        string RemoteId { get; }

        [Export("transcriptionLength")]
        float TranscriptionLength { get; }

        [NullAllowed, Export("transcriptionURL", ArgumentSemantic.Copy)]
        NSUrl TranscriptionURL { get; }

        [Export("uploadedFileURL", ArgumentSemantic.Copy)]
        NSUrl UploadedFileURL { get; }

        [NullAllowed, Export("tags")]
        NSDictionary Tags { get; }

        [NullAllowed, Export("metadata")]
        NSDictionary Metadata { get; }

        [NullAllowed, Export("type")]
        NSString Type { get; }
    }

    [BaseType(typeof(NSObject), Name = "_TtC13TruvideoMedia13TruvideoMedia")]
    interface TruvideoMedia
    {
        [Static]
        [Export("shared", ArgumentSemantic.Strong)]
        TruvideoMedia Shared { get; }

        [NullAllowed, Export("delegate", ArgumentSemantic.Weak)]
        TruvideoMediaUploadDelegate Delegate { get; set; }

        // New
          [Export("mediaBuilderWithPath:tag:metaData:completion:")]
          void MediaBuilder(string path, string tag, string metaData, Action<TruvideoMediaSdkUploadRequest, NSError> completion);

          [Export("getByIdWithId:completion:")]
          void GetById(string id,Action<TruvideoMediaSdkUploadRequest, NSError> completion);

        [Export("getFileUploadRequestsByStatus:completion:")]
        void GetFileUploadRequests(MediaStatus byStatus, Action<NSArray, NSError> completion);

        [Export("searchWithType:tags:pageNumber:size:completion:")]
        void Search(MediaType type, [NullAllowed] string tags, nint pageNumber, nint size, Action<NSArray, NSError> completion);

        [Export("uploadRequest:completion:")]
        void UploadRequest(NSUuid requestId, Action<MediaResponse, NSError> completion);

        [Export("retryRequest:completion:")]
        void RetryRequest(NSUuid requestId, Action<NSString, NSError> completion);

        [Export("pauseRequest:completion:")]
        void PauseRequest(NSUuid requestId, Action<NSString, NSError> completion);

        [Export("resumeRequest:completion:")]
        void ResumeRequest(NSUuid requestId, Action<NSString, NSError> completion);

        [Export("deleteRequest:completion:")]
        void DeleteRequest(NSUuid requestId, Action<NSString, NSError> completion);

        [Export("cancelRequest:completion:")]
        void CancelRequest(NSUuid requestId, Action<NSString, NSError> completion);

        [Export("updateIncludeInReportForRequest:includeInReport:")]
        void UpdateIncludeInReportForRequest(NSUuid requestId, bool includeInReport);
    }

    [BaseType(typeof(NSObject), Name = "_TtC13TruvideoMedia29TruvideoMediaSdkUploadRequest")]
     interface TruvideoMediaSdkUploadRequest
     {
         [Export("id")]
         NSUuid Id { get; }
    
         [Export("filePath")]
         string FilePath { get; }
    
         [NullAllowed, Export("errorMessage")]
         string ErrorMessage { get; }
    
         [NullAllowed, Export("remoteId")]
         string RemoteId { get; }
    
         [NullAllowed, Export("remoteURL", ArgumentSemantic.Copy)]
         NSUrl RemoteURL { get; }
    
         [Export("uploadProgress")]
         double UploadProgress { get; }
    
         [NullAllowed, Export("transcriptionURL")]
         string TranscriptionURL { get; }
    
         [NullAllowed, Export("transcriptionLength")]
         NSNumber TranscriptionLength { get; }
    
         [NullAllowed, Export("metadata")]
         NSDictionary Metadata { get; }
    
         [NullAllowed, Export("tags")]
         NSDictionary Tags { get; }
    
         [Export("status")]
         MediaStatus Status { get; }
    
         [NullAllowed, Export("createdAt", ArgumentSemantic.Copy)]
         NSDate CreatedAt { get; }
    
         [NullAllowed, Export("updatedAt", ArgumentSemantic.Copy)]
         NSDate UpdatedAt { get; }
    
         [Export("includeInReport")]
         bool IncludeInReport { get; }
    
         [Export("fileType")]
         MediaType FileType { get; }
    
         [Export("durationMilliseconds")]
         nint DurationMilliseconds { get; }
    
         // helper methods
         [Export("uploadWithRequestId:completion:")]
         void Upload(NSUuid requestId, Action<MediaResponse, NSError> completion);
    
         [Export("retryWithRequestId:completion:")]
         void Retry(NSUuid requestId, Action<NSString, NSError> completion);
    
         [Export("pauseWithRequestId:completion:")]
         void Pause(NSUuid requestId, Action<NSString, NSError> completion);
    
         [Export("resumeWithRequestId:completion:")]
         void Resume(NSUuid requestId, Action<NSString, NSError> completion);
    
         [Export("deleteWithRequestId:completion:")]
         void Delete(NSUuid requestId, Action<NSString, NSError> completion);
    
         [Export("cancelWithRequestId:completion:")]
         void Cancel(NSUuid requestId, Action<NSString, NSError> completion);
    
         [Export("updateIncludeInReportWithRequestId:includeInReport:")]
         void UpdateIncludeInReport(NSUuid requestId, bool includeInReport);
     }
    
}




//
// using System;
// using System.Runtime.InteropServices.JavaScript;
// using Foundation;
// using ObjCRuntime;
//
//
// namespace TruvideoMediaiOS {
//
//     // Define the delegate interface (protocol)
//     [BaseType(typeof(NSObject))]
//     [Protocol,Model]
//     interface TruvideoMediaUploadDelegate
//     {
//         // The Swift function is: func uploadProgress(updated progress: Double)
//         [Export("uploadProgressWithUpdated:")] // ✅ Corrected Export
//           void UploadProgress(double updated);
//
//     }
//
//     // @interface MediaResponse : NSObject
//     [BaseType(typeof(NSObject), Name = "_TtC13TruvideoMedia13MediaResponse")]
//     [DisableDefaultCtor]
//     interface MediaResponse
//     {
//         // @property (readonly, copy, nonatomic) NSDate * _Nonnull createdDate;
//         [Export("createdDate", ArgumentSemantic.Copy)]
//         NSDate CreatedDate { get; }
//
//         // @property (readonly, copy, nonatomic) NSString * _Nonnull remoteId;
//         [Export("remoteId")]
//         string RemoteId { get; }
//
//         // @property (readonly, nonatomic) float transcriptionLength;
//         [Export("transcriptionLength")]
//         float TranscriptionLength { get; }
//
//         // @property (readonly, copy, nonatomic) NSURL * _Nullable transcriptionURL;
//         [NullAllowed, Export("transcriptionURL", ArgumentSemantic.Copy)]
//         NSUrl TranscriptionURL { get; }
//
//         // @property (readonly, copy, nonatomic) NSURL * _Nonnull uploadedFileURL;
//         [Export("uploadedFileURL", ArgumentSemantic.Copy)]
//         NSUrl UploadedFileURL { get; }
//         
//         [Export("tags")]
//         NSDictionary Tags { get; }
//         
//         [Export("metadata")]
//         NSDictionary Metadata { get; }
//         
//         [Export("type")]
//         NSString Type { get; }
//         
//     }
//     
//     // @interface TruvideoMedia : NSObject
//     [BaseType(typeof(NSObject), Name = "_TtC13TruvideoMedia13TruvideoMedia")]
//     [DisableDefaultCtor]
//     interface TruvideoMedia
//     {
//         // @property (readonly, nonatomic, strong, class) TruvideoMedia * _Nonnull shared;
//         [Static]
//         [Export("shared", ArgumentSemantic.Strong)]
//         TruvideoMedia Shared { get; }
//
//         // Add delegate property
//         [NullAllowed, Export("delegate", ArgumentSemantic.Weak)]
//         TruvideoMediaUploadDelegate Delegate { get; set; }
//
//         // -(void)uploadWithPath:(NSString * _Nonnull)path tag:(NSString * _Nonnull)tag metaData:(NSString * _Nonnull)metaData completion:(void (^ _Nonnull)(MediaResponse * _Nullable, NSError * _Nullable))completion;
//         [Export("uploadWithPath:tag:metaData:completion:")]
//         void UploadMedia(string path, string tag, string metaData, Action<MediaResponse, NSError> completion);
//         
//         [Export("searchWithType:tags:pageNumber:size:completion:")]
//         void Search(MediaType type, string tags, int pageNumber, int size, Action<NSArray, NSError> completion);
//     }
// }
