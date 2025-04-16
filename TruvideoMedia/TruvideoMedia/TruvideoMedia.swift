import Foundation
import Combine
import TruvideoSdkMedia
import Foundation
import Combine

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
    private var cancellables = Set<AnyCancellable>()
    private var requestMapping = [UUID: TruvideoSdkMediaUploadRequest]()

    @objc public func upload(path: String, tag: String, metaData: String, completion: @escaping (_ result: MediaResponse?, _ error: Error?) -> Void) {
        do {
            guard let url = URL(string: path) else { return }
            let mediaBuilder = TruvideoSdkMedia.FileUploadRequestBuilder(fileURL: url)
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

    private func convertTruvideoStatusToMediaStatus(_ status: TruvideoSdkMediaUploadRequest.Status) -> MediaStatus {
        switch status {
        case .paused: return .paused
        case .processing: return .processing
        case .synchronizing: return .synchronizing
        case .cancelled: return .cancelled
        case .completed: return .completed
        case .error: return .error
        case .idle: return .idle
        @unknown default:
            return .processing
        }
    }

    private func convertTruvideoTypeToMediaType(_ type: TruvideoSdkMediaType) -> MediaType {
        switch type {
        case .audio: return .audio
        case .video: return .video
        case .image: return .image
        case .document: return .document
        @unknown default:
            return .image
        }
    }


    private func convertToDictionary(from jsonString: String) throws -> [String: String] {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Invalid JSON string", code: 0, userInfo: nil)
        }
        return try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: String] ?? [:]
    }
    
    @objc public func search(type: MediaType, tags: String?, pageNumber: Int, size: Int, completion: @escaping (_ result: [MediaResponse], _ error: Error?) -> Void) {
        Task {
            do {
                let convertedType = convertMediaTypeToTruvideoType(type)
                var mediaTags: TruvideoSdkMediaTags? = nil

                if let tags = tags {
                    let tagsDict = try convertToDictionary(from: tags)
                    mediaTags = TruvideoSdkMediaTags.builder(dictionary: tagsDict).build()
                }

                let result = try await TruvideoSdkMedia.search(
                    type: convertedType,
                    tags: mediaTags,
                    pageNumber: pageNumber,
                    size: size
                )
                let convertedMediaList = result.content.map { $0.media }
                completion(convertedMediaList, nil)
            } catch {
                print("Search failed with error: \(error)")
                completion([], error)
            }
        }
    }

    private func convertMediaStatusToTruvideoStatus(_ status: MediaStatus) -> TruvideoSdkMediaUploadRequest.Status {
        switch status {
        case .paused:
            return .paused
        case .processing:
            return .processing
        case .synchronizing:
            return .synchronizing
        case .cancelled:
            return .cancelled
        case .completed:
            return .completed
        case .error:
            return .error
        case .idle:
            return .idle

        }
    }
    
   private func convertMediaTypeToTruvideoType(_ type: MediaType) -> TruvideoSdkMediaType {
        switch type {
        case .audio:
            return .audio
        case .video:
            return .video
        case .image:
            return .image
        case .document:
            return .document
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
            uploadedFileURL: uploadedFileURL,
            tags: tags.dictionary as NSDictionary?,
            metadata: metadata.dictionary as NSDictionary?,
            type: type.rawValue
        )
    }
}

@objc
public class MediaResponse: NSObject {
    internal init(createdDate: Date, remoteId: String, transcriptionLength: Float, transcriptionURL: URL? = nil, uploadedFileURL: URL,tags: NSDictionary? = nil, metadata: NSDictionary? = nil, type: String? = nil) {
        self.createdDate = createdDate
        self.remoteId = remoteId
        self.transcriptionLength = transcriptionLength
        self.transcriptionURL = transcriptionURL
        self.uploadedFileURL = uploadedFileURL
        self.tags = tags
        self.metadata = metadata
        self.type = type
    }
    
    @objc public let createdDate: Date
    @objc public let remoteId: String
    @objc public let transcriptionLength: Float
    @objc public let transcriptionURL: URL?
    @objc public let uploadedFileURL: URL
    @objc public let tags: NSDictionary?
    @objc public let metadata: NSDictionary?
    @objc public let type: String?
}

@objc public enum MediaStatus: Int {
    case cancelled
    case completed
    case error
    case idle
    case paused
    case processing
    case synchronizing
}

@objc public enum MediaType: Int {
    case audio
    case video
    case image
    case document
}

