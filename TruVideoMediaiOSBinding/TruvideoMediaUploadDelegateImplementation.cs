// using Foundation;
// using System;
//
// namespace TruvideoMediaiOS
// {
//     public class TruvideoMediaUploadDelegateImplementation : NSObject, ITruvideoMediaUploadDelegate
//     {
//         // Event to notify progress updates
//         public event EventHandler<double>? ProgressUpdated;
//
//         [Export("uploadProgress:updated:")]
//         public void UploadProgress(IntPtr progress, double updated)
//         {
//             ProgressUpdated?.Invoke(this, updated);
//         }
//     }
// }