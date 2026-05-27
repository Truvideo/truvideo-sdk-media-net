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
    
    
    
    // =========================
    // Stream Response (NEW)
    // =========================
    [BaseType(typeof(NSObject), Name = "_TtC13TruvideoMedia27StreamUploadRequestResponse")]
    interface StreamUploadRequestResponse
    {
        [Export("id")]
        string Id { get; }

        [Export("status")]
        string Status { get; }

        [Export("type")]
        string Type { get; }

        [Export("mediaId")]
        string MediaId { get; }

        [NullAllowed, Export("tags")]
        NSDictionary Tags { get; }

        [NullAllowed, Export("metadata")]
        NSDictionary Metadata { get; }

        [Export("includeInReport")]
        bool IncludeInReport { get; }

        [Export("isLibrary")]
        bool IsLibrary { get; }

        [NullAllowed, Export("parts")]
        NSArray Parts { get; }

        [Export("createdAt")]
        string CreatedAt { get; }
        
        [Export("fileURL")]
        string FileURL { get; }
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

        // [Export("searchWithType:tags:pageNumber:size:completion:")]
        // void Search(MediaType type, [NullAllowed] string tags, nint pageNumber, nint size, Action<NSArray, NSError> completion);
        
        // SEARCH

        [Export("searchWithType:tags:isLibrary:pageNumber:size:completion:")]
        void Search(
            MediaType type,
            [NullAllowed] string tags,
            bool isLibrary,
            nint pageNumber,
            nint size,
            Action<NSArray, NSError> completion
        );

        [Export("searchIdWithId:completion:")]
        void SearchId(
            string id,
            Action<NSArray, NSError> completion
        );

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
        
        
        // -------------------------
        // STREAM APIs (NEW)
        // -------------------------

        [Export("getStreamUploadRequestByIdWithId:completion:")]
        void GetStreamUploadRequestById(string id,
            Action<StreamUploadRequestResponse, NSError> completion);
        
        
        [Export("getAllStreamUploadRequestsWithCompletion:")]
        void GetAllStreamUploadRequests(Action<NSArray, NSError> completion);

        [Export("streamUploadMediaWithId:title:tag:metaData:isIncludedInReport:isLibrary:completion:")]
        void StreamUploadMedia(
            string id,
            string title,
            string tag,
            string metaData,
            bool isIncludedInReport,
            bool isLibrary,
            Action<StreamUploadRequestResponse, NSError> completion);
        
        [Export("streamPauseMediaWithId:completion:")]
        void StreamPauseMedia(string id, Action<string, NSError> completion);
        
        [Export("streamResumeMediaWithId:completion:")]
        void StreamResumeMedia(string id, Action<string, NSError> completion);
        
        [Export("streamDeleteMediaWithId:completion:")]
        void StreamDeleteMedia(string id, Action<string, NSError> completion);
        
        [Export("retryStreamRequestWithId:completion:")]
        void RetryStreamRequest(string id, Action<string, NSError> completion);
        
        [Export("cancelStreamRequestWithId:completion:")]
        void CancelStreamRequest(string id, Action<string, NSError> completion);
        
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
