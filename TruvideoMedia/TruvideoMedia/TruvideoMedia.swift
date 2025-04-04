import Foundation
import Combine
import TruvideoSdkMedia
import Foundation
import Combine
import TruvideoSdkMedia

@objc
public protocol TruvideoMediaUploadDelegate: AnyObject {
    func uploadProgress(updated progress: Double)
}

@objc
final public class TruvideoMedia: NSObject {
    private var disposeBag = Set<AnyCancellable>()
    
    @objc
    public static let shared = TruvideoMedia()
    
    @objc public weak var delegate: TruvideoMediaUploadDelegate?

    @objc public func upload(path: String, tag: String, metaData: String, completion: @escaping (_ result: MediaResponse?, _ error: Error?) -> Void) {
        do {
            guard let url = URL(string: path) else { return }
            let mediaBuilder = TruvideoSdkMedia.FileUploadRequestBuilder(fileURL: url)

            // Convert tag and metaData strings to dictionaries
            let tagsDict = try convertToDictionary(from: tag)
            let metaDataDict = try convertToDictionary(from: metaData)

            // Add tags
            for (key, value) in tagsDict {
                mediaBuilder.addTag(key, value)
            }

            // Add metadata
            for (key, value) in metaDataDict {
                mediaBuilder.addMetadata(key, value)
            }

            let fileUploadRequest = try mediaBuilder.build()

            // Handle completion
            let completeCancellable = fileUploadRequest.completionHandler
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { receiveCompletion in
                    switch receiveCompletion {
                    case .finished:
                        print("Upload finished")
                    case .failure(let error):
                        print("Upload failed:", error)
                        completion(nil, error)
                    }
                }, receiveValue: { uploadedResult in
                    completion(uploadedResult.media, nil)
                })

            completeCancellable.store(in: &disposeBag)

            // Handle progress updates
            let progressCancellable = fileUploadRequest.progressHandler
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] progress in
                    let percentage = progress.percentage * 100
                    print("Upload progress: \(percentage)%")
                    self?.delegate?.uploadProgress(updated: percentage)
                })
            
            progressCancellable.store(in: &disposeBag)

            do {
                try fileUploadRequest.upload()
            } catch let error {
                completion(nil, error)
            }
        } catch let error {
            completion(nil, error)
        }
    }

    private func convertToDictionary(from jsonString: String) throws -> [String: String] {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Invalid JSON string", code: 0, userInfo: nil)
        }
        return try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: String] ?? [:]
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
