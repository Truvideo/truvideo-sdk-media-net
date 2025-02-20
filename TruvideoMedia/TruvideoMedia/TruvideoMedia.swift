import Foundation
import Combine
import TruvideoSdkMedia

@objc
final public class TruvideoMedia: NSObject {
    private var disposeBag = Set<AnyCancellable>()
    
    @objc
    public static let shared = TruvideoMedia()
    
    @objc public func upload(path: String, completion: @escaping (_ result: MediaResponse?, _ error: Error?) -> Void) {
        do {
            guard let url = URL(string: path) else { return }
            let fileUploadRequest = try TruvideoSdkMedia.FileUploadRequestBuilder(
                fileURL: url
            ).build()
            let completeCancellable = fileUploadRequest.completionHandler
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { receiveCompletion in
                    switch receiveCompletion {
                    case .finished:
                        print("finished")
                    case .failure(let error):
                        print("failure:", error)
                    }
                }, receiveValue: { uploadedResult in
                    completion(uploadedResult.media, nil)
                })
            
            completeCancellable.store(in: &disposeBag)
            do {
                try fileUploadRequest.upload()
            } catch let error {
                completion(nil, error)
            }
        } catch let error {
            completion(nil, error)
        }
    }
    
    
    
}

extension TruvideoSDKMedia {
    var media: MediaResponse {
        MediaResponse(
            createdDate: createdDate,
            remoteId: remoteId,
            transcriptionLength: transcriptionLength,
            transcriptionURL: transcriptionURL,
            uploadedFileURL: uploadedFileURL
        )
    }
}

@objc
public class MediaResponse: NSObject {
    internal init(createdDate: Date, remoteId: String, transcriptionLength: Float, transcriptionURL: URL? = nil, uploadedFileURL: URL) {
        self.createdDate = createdDate
        self.remoteId = remoteId
        self.transcriptionLength = transcriptionLength
        self.transcriptionURL = transcriptionURL
        self.uploadedFileURL = uploadedFileURL
    }
    
    @objc public let createdDate: Date
    @objc public let remoteId: String
    @objc public let transcriptionLength: Float
    @objc public let transcriptionURL: URL?
    @objc public let uploadedFileURL: URL
}
