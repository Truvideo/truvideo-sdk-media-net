using System;
using ObjCRuntime;
using Foundation;

namespace TruvideoMediaiOS {

    [Native]
    public enum MediaType : long 
    {
         audio = 0,
         image = 1,
         video = 2 ,
         document = 3
    }
    
    public enum MediaStatus : long 
    {
        cancelled = 0,
        completed = 1,
        error = 2 ,
        idle = 3,
        paused = 4,
        processing = 5,
        synchronizing = 6
    }
}

