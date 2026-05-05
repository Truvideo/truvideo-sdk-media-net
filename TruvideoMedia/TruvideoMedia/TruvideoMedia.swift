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
    
    
    @objc(mediaBuilderWithPath:tag:metaData:completion:)
    public func mediaBuilder(
        path: String,
        tag: String,
        metaData: String,
        completion: @escaping (_ request: TruvideoMediaSdkUploadRequest?, _ error: Error?) -> Void
    ) {
        Task {
            do {
                guard let url = URL(string: path) else {
                    completion(nil, NSError(domain: "INVALID_URL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid file path URL"]))
                    return
                }
                let mediaBuilder = TruvideoSdkMedia.FileUploadRequestBuilder(fileURL: url)
                let tagsDict = try convertToDictionary(from: tag)
                let metaDataDict = try convertToDictionary(from: metaData)
                for (key, value) in tagsDict {
                    mediaBuilder.addTag(key, value)
                }
                for (key, value) in metaDataDict {
                    mediaBuilder.addMetadata(key, value)
                }
                let fileUploadRequest = try mediaBuilder.build()
                self.requestMapping[fileUploadRequest.id] = fileUploadRequest
                let wrappedRequest = await TruvideoMediaSdkUploadRequest(
                    id: fileUploadRequest.id as NSUUID,
                    filePath: fileUploadRequest.filePath,
                    errorMessage: fileUploadRequest.errorMessage,
                    remoteId: fileUploadRequest.remoteId,
                    remoteURL: fileUploadRequest.remoteURL,
                    uploadProgress: fileUploadRequest.uploadProgress,
                    transcriptionURL: fileUploadRequest.transcriptionURL,
                    transcriptionLenght: fileUploadRequest.transcriptionLength as NSNumber?,
                    metadata: fileUploadRequest.metadata.dictionary as NSDictionary,
                    tags: fileUploadRequest.tags.dictionary as NSDictionary,
                    status: convertTruvideoStatusToMediaStatus(fileUploadRequest.status),
                    createdAt: fileUploadRequest.createdAt,
                    updatedAt: fileUploadRequest.updatedAt,
                    includeInReport: fileUploadRequest.includeInReport ?? false,
                    fileType: convertTruvideoTypeToMediaType(fileUploadRequest.fileType),
                    durationMilliseconds: fileUploadRequest.durationMilliseconds ?? 0
                )
                DispatchQueue.main.async {
                    completion(wrappedRequest, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
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
    
    
    @objc public func getById(id: String,completion: @escaping (_ result: TruvideoMediaSdkUploadRequest?, _ error: Error?) -> Void){
        Task{
            do {
                let fileUploadRequest = try TruvideoSdkMedia.getFileUploadRequest(withId : id)
                let wrappedRequest = await TruvideoMediaSdkUploadRequest(
                    id: fileUploadRequest.id as NSUUID, // ensure this exists on SDK side
                    filePath: fileUploadRequest.filePath,
                    errorMessage: fileUploadRequest.errorMessage,
                    remoteId: fileUploadRequest.remoteId,
                    remoteURL: fileUploadRequest.remoteURL,
                    uploadProgress: fileUploadRequest.uploadProgress,
                    transcriptionURL: fileUploadRequest.transcriptionURL,
                    transcriptionLenght: fileUploadRequest.transcriptionLength as NSNumber?,
                    metadata: fileUploadRequest.metadata.dictionary as NSDictionary,
                    tags:fileUploadRequest.tags.dictionary as NSDictionary,
                    status: convertTruvideoStatusToMediaStatus(fileUploadRequest.status),
                    createdAt: fileUploadRequest.createdAt,
                    updatedAt: fileUploadRequest.updatedAt,
                    includeInReport: fileUploadRequest.includeInReport ?? false,
                    fileType: convertTruvideoTypeToMediaType(fileUploadRequest.fileType),
                    durationMilliseconds: fileUploadRequest.durationMilliseconds ?? 0
                )
                completion(wrappedRequest,nil)
            }
            catch{
                completion(nil,error)
            }
        }
    }
            
    
    @objc public func getFileUploadRequests(
        byStatus: MediaStatus,
        completion: @escaping (_ result: [TruvideoMediaSdkUploadRequest], _ error: Error?) -> Void
    ) {
        Task {
            do {
                let status = convertMediaStatusToTruvideoStatus(byStatus)
                let sdkRequests = try TruvideoSdkMedia.getFileUploadRequests(byStatus: status)

                var wrappedRequests: [TruvideoMediaSdkUploadRequest] = []
                wrappedRequests.reserveCapacity(sdkRequests.count)

                for sdkRequest in sdkRequests {
                    let duration = await sdkRequest.durationMilliseconds ?? 0

                    let wrapped = TruvideoMediaSdkUploadRequest(
                        id: sdkRequest.id as NSUUID,
                        filePath: sdkRequest.filePath,
                        errorMessage: sdkRequest.errorMessage,
                        remoteId: sdkRequest.remoteId,
                        remoteURL: sdkRequest.remoteURL,
                        uploadProgress: sdkRequest.uploadProgress,
                        transcriptionURL: sdkRequest.transcriptionURL,
                        transcriptionLenght: sdkRequest.transcriptionLength as? NSNumber,
                        metadata: sdkRequest.metadata.dictionary as NSDictionary,
                        tags: sdkRequest.tags.dictionary as NSDictionary,
                        status: convertTruvideoStatusToMediaStatus(sdkRequest.status),
                        createdAt: sdkRequest.createdAt,
                        updatedAt: sdkRequest.updatedAt,
                        includeInReport: sdkRequest.includeInReport ?? false,
                        fileType: convertTruvideoTypeToMediaType(sdkRequest.fileType),
                        durationMilliseconds: duration
                    )

                    wrappedRequests.append(wrapped)
                }

                completion(wrappedRequests, nil)
            } catch {
                completion([], error)
            }
        }
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


    @objc public func uploadRequest(_ requestId: UUID,completion: @escaping (_ result: MediaResponse?, _ error: Error?) -> Void) {
        do {
            let uploadRequest = try TruvideoSdkMedia.getFileUploadRequest(withId: requestId.uuidString)
     
            let completeCancellable = uploadRequest.completionHandler
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
     
            let progressCancellable = uploadRequest.progressHandler
                .receive(on: DispatchQueue.main)
                .sink { [weak self] progress in
                    let percentage = progress.percentage * 100
                    print("Upload progress: \(percentage)%")
                    self?.delegate?.uploadProgress(updated: Double(percentage))
                }
     
            progressCancellable.store(in: &disposeBag)
     
            try uploadRequest.upload()
     
        } catch {
            completion(nil, error)
        }
    }
    
    @objc public func pauseRequest(_ requestId: UUID, completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        do {
            // Attempt to get the request; throws if not found
            let request = try TruvideoSdkMedia.getFileUploadRequest(withId: requestId.uuidString)
            try request.pause() // throws if pause fails
            completion("request paused", nil)
        } catch {
            completion(nil, error)
        }
    }
    
    
    @objc public func resumeRequest(_ requestId: UUID, completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        do {
            let request = try TruvideoSdkMedia.getFileUploadRequest(withId: requestId.uuidString)
            try request.resume()
            completion("request resumed", nil)
        } catch {
            completion(nil, error)
        }
    }

    @objc public func cancelRequest(_ requestId: UUID, completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        do {
            let request = try TruvideoSdkMedia.getFileUploadRequest(withId: requestId.uuidString)
            try request.cancel()
            completion("request cancelled", nil)
        } catch {
            completion(nil, error)
        }
    }
    
    @objc
    public func deleteRequest(_ requestId: UUID, completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        do {
        
            let request = try TruvideoSdkMedia.getFileUploadRequest(withId: requestId.uuidString)
            try request.delete()
            completion("request deleted", nil)

        } catch {
            completion(nil, error)
        }
    }
    
    @objc public func retryRequest(_ requestId: UUID, completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        do {
            // Try to get the request (throws if not found)
            let request = try TruvideoSdkMedia.getFileUploadRequest(withId: requestId.uuidString)
            // Attempt retry
            try request.retry()
            completion("request retried", nil)
        } catch {
            // Return any error encountered
            completion(nil, error)
        }
    }
    
    @objc public func updateIncludeInReportForRequest(_ requestId: UUID, includeInReport: Bool, completion: ((_ success: Bool, _ error: Error?) -> Void)? = nil) {
        do {
            // Attempt to get the request
            let request = try TruvideoSdkMedia.getFileUploadRequest(withId: requestId.uuidString)
            // Update includeInReport
            try request.updateIncludeInReport(includeInReport)
            completion?(true, nil) // Notify success
        } catch {
            print("Failed to update includeInReport:", error)
            completion?(false, error) // Notify failure
        }
    }
    
    
    @objc
    public func streamResumeMedia(id: String,completion: @escaping (_ result: String?, _ error: Error?) -> Void
    ) {
        Task {
            do {
                let request = try await TruvideoSdkMedia.getUploadRequestById(id)
                try await request.resume()
                completion("stream request resumed", nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    @objc
    public func streamPauseMedia(id: String,completion: @escaping (_ result: String?, _ error: Error?) -> Void
    ) {
        Task {
            do {
                let request = try await TruvideoSdkMedia.getUploadRequestById(id)
                try await request.pause()
                completion("stream request paused", nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    @objc
    public func streamDeleteMedia(id: String,completion: @escaping (_ result: String?, _ error: Error?) -> Void
    ) {
        Task {
            do {
               // print("Fetching stream request with id: \(id)")
                let request = try await TruvideoSdkMedia.getUploadRequestById(id)
                //print("Stream request found: \(request)")
                try await request.delete()
                //print("Stream request deleted successfully")
                completion("stream request deleted", nil)
            } catch {
                //print("Error occurred: \(error)")
                completion(nil, error)
            }
        }
    }
    
    @objc
    public func retryStreamRequest(id: String,completion: @escaping (_ result: String?, _ error: Error?) -> Void
    ) {
        Task {
            do {
               // print("Fetching stream request with id: \(id)")
                let request = try await TruvideoSdkMedia.getUploadRequestById(id)
                //print("Stream request found: \(request)")
                try await request.retry()
                //print("Stream request retried successfully")
                completion("stream request retried", nil)

            } catch {
                print("Error occurred: \(error)")
                completion(nil, error)
            }
        }
    }
  
    @objc
    public func cancelStreamRequest(id: String,completion: @escaping (_ result: String?, _ error: Error?) -> Void
    ) {
        Task {
            do {
                //print("Fetching stream request with id: \(id)")
                let request = try await TruvideoSdkMedia.getUploadRequestById(id)
                //print("Stream request found: \(request)")
                try await request.cancel()
                //print("Stream request cancelled successfully")
                completion("stream request cancelled", nil)

            } catch {
                //print("Error occurred: \(error)")
                completion(nil, error)
            }
        }
    }
    
    
    @objc public func getStreamUploadRequestById(id: String, completion: @escaping (_ result: StreamUploadRequestResponse?, _ error: Error?) -> Void
    ) {
        Task {
            do {
                let request = try await TruvideoSdkMedia.getUploadRequestById(id)
        
                let wrapped = StreamUploadRequestResponse(
                    id: "\(request.id)",
                    status: request.status.rawValue,
                    type: request.fileType.rawValue,
                    mediaId: request.remoteId ?? "",
                    tags: request.tags.dictionary as NSDictionary,
                    metadata: request.metadata.dictionary as NSDictionary,
                    includeInReport: request.isIncludedInReport,
                    isLibrary: request.isLibrary,
                    parts: [],
                    createdAt: "\(request.createdAt)",
                    fileURL: request.fileUrl.absoluteString
                )
                completion(wrapped, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    
    @objc public func getAllStreamUploadRequests(completion: @escaping (_ result: [StreamUploadRequestResponse], _ error: Error?) -> Void
    ) {
        Task {
            do {
                let requests = try await TruvideoSdkMedia.getAllUploadRequests()
                var wrappedRequests: [StreamUploadRequestResponse] = []
                wrappedRequests.reserveCapacity(requests.count)
                for sdkRequest in requests {
                    let duration = sdkRequest.durationMilliseconds ?? 0

                    let wrapped = StreamUploadRequestResponse(
                        id: "\(sdkRequest.id)",
                        status: sdkRequest.status.rawValue,
                        type: sdkRequest.fileType.rawValue,
                        mediaId: sdkRequest.remoteId ?? "",
                        tags: sdkRequest.tags.dictionary as NSDictionary,
                        metadata: sdkRequest.metadata.dictionary as NSDictionary,
                        includeInReport: sdkRequest.isIncludedInReport,
                        isLibrary: sdkRequest.isLibrary,
                        parts: [],
                        createdAt: "\(sdkRequest.createdAt)",
                        fileURL: sdkRequest.fileUrl.absoluteString
                    )

                    wrappedRequests.append(wrapped)
                }

                completion(wrappedRequests, nil)
                
            } catch {
                completion([], error)
            }
        }
    }
    
    

    
    @objc
    public func streamUploadMedia(
        id: String,
        title: String,
        tag: String,
        metaData: String,
        isIncludedInReport: Bool,
        isLibrary: Bool,
        completion: @escaping (_ result: StreamUploadRequestResponse?, _ error: Error?) -> Void
    ) {
        Task {
            do {
               // print("Fetching stream request with id: \(id)")

                let request = try await TruvideoSdkMedia.getUploadRequestById(id)

                // Convert JSON safely
                let tagsDict = try? convertToDictionary(from: tag) ?? [:]
                let metadataDict = try? convertToDictionary(from: metaData) ?? [:]

                // Build Metadata object (REQUIRED)
                let metadataBuilder = TruvideoSdkMediaMetadata.builder()

                let metadataDict1 = try? convertToDictionary(from: metaData)

                for (key, value) in metadataDict1 ?? [:] {
                    metadataBuilder.set(key, value)
                }

                let metadataObject = metadataBuilder.build()

                //print("Creating upload options")

                let options = TruvideoSdkMediaStreamRequest.Options(
                    isIncludedInReport: isIncludedInReport,
                    isLibrary: isLibrary,
                    metadata: metadataObject,
                    tags: tagsDict ?? [:],
                    title: title
                )

               // print("Starting stream upload")

                let uploadedMedia = try await request.upload(with: options)

                let wrapped = StreamUploadRequestResponse(
                    id: "\(request.id)",
                    status: request.status.rawValue,
                    type: request.fileType.rawValue,
                    mediaId: request.remoteId ?? "",
                    tags: request.tags.dictionary as NSDictionary,
                    metadata: request.metadata.dictionary as NSDictionary,
                    includeInReport: request.isIncludedInReport,
                    isLibrary: request.isLibrary,
                    parts: [],
                    createdAt: "\(request.createdAt)",
                    fileURL: request.fileUrl.absoluteString
                )

                completion(wrapped, nil)

            } catch {
               // print("Stream upload failed: \(error)")
                completion(nil, error)
            }
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
public class StreamUploadRequestResponse: NSObject {

    internal init(
        id: String,
        status: String,
        type: String,
        mediaId: String,
        tags: NSDictionary? = nil,
        metadata: NSDictionary? = nil,
        includeInReport: Bool,
        isLibrary: Bool,
        parts: NSArray? = nil,
        createdAt: String,
        fileURL: String
    ) {
        self.id = id
        self.status = status
        self.type = type
        self.mediaId = mediaId
        self.tags = tags
        self.metadata = metadata
        self.includeInReport = includeInReport
        self.isLibrary = isLibrary
        self.parts = parts
        self.createdAt = createdAt
        self.fileURL = fileURL
    }

    @objc public let id: String
    @objc public let status: String
    @objc public let type: String
    @objc public let mediaId: String
    @objc public let tags: NSDictionary?
    @objc public let metadata: NSDictionary?
    @objc public let includeInReport: Bool
    @objc public let isLibrary: Bool
    @objc public let parts: NSArray?
    @objc public let createdAt: String
    @objc public let fileURL: String
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

@objc
public class TruvideoMediaSdkUploadRequest: NSObject{
    
    internal init(
        id: NSUUID,
        filePath: String,
        errorMessage: String? = nil,
        remoteId: String? = nil,
        remoteURL: URL? = nil,
        uploadProgress: Double = 0.0,
        transcriptionURL: String? = nil,
        transcriptionLenght: NSNumber? = nil,
        metadata: NSDictionary? = nil,
        tags: NSDictionary? = nil,
        status: MediaStatus,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        includeInReport: Bool = false,
        fileType: MediaType,
        durationMilliseconds: Int = 0
    ) {
        self.id = id
        self.filePath = filePath
        self.errorMessage = errorMessage
        self.remoteId = remoteId
        self.remoteURL = remoteURL
        self.uploadProgress = uploadProgress
        self.transcriptionURL = transcriptionURL
        self.transcriptionLength = transcriptionLenght
        self.metadata = metadata
        self.tags = tags
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.includeInReport = includeInReport
        self.fileType = fileType
        self.durationMilliseconds = durationMilliseconds
    }
    
    @objc public let id: NSUUID
    @objc public let filePath: String
    @objc public let errorMessage: String?
    @objc public let remoteId: String?
    @objc public let remoteURL: URL?
    @objc public let uploadProgress: Double
    @objc public let transcriptionURL: String?
    @objc public let transcriptionLength: NSNumber?
    @objc public let metadata: NSDictionary?
    @objc public let tags: NSDictionary?
    @objc public let status: MediaStatus
    @objc public let createdAt: Date?
    @objc public let updatedAt: Date?
    @objc public let includeInReport: Bool
    @objc public let fileType: MediaType
    @objc public let durationMilliseconds: Int
    
    @objc public func upload(requestId: UUID,completion: @escaping (_ result: MediaResponse?, _ error: Error?) -> Void){
        TruvideoMedia.shared.uploadRequest(requestId, completion: {result,error in
            completion(result, error)
        })
    }
    
    @objc public func retry(requestId: UUID,completion: @escaping (_ result: String?, _ error: Error?) -> Void){
        TruvideoMedia.shared.retryRequest(requestId, completion: {result,error in 
            completion(result,error)
        })
    }
    
    @objc public func pause(requestId: UUID,completion: @escaping (_ result: String?, _ error: Error?) -> Void){
        TruvideoMedia.shared.pauseRequest(requestId, completion: {result,error in
            completion(result,error)
        })
    }
    
    @objc public func resume(requestId: UUID,completion: @escaping (_ result: String?, _ error: Error?) -> Void){
        TruvideoMedia.shared.resumeRequest(requestId, completion: {result,error in
            completion(result,error)
        })
    }
    
    @objc public func delete(requestId: UUID,completion: @escaping (_ result: String?, _ error: Error?) -> Void){
        TruvideoMedia.shared.deleteRequest(requestId, completion: {result,error in
            completion(result,error)
        })
    }
    
    @objc public func cancel(requestId: UUID,completion: @escaping (_ result: String?, _ error: Error?) -> Void){
        TruvideoMedia.shared.cancelRequest(requestId, completion: {result,error in
            completion(result,error)
        })
    }
    
    @objc public func updateIncludeInReport(requestId: UUID,_ includeInReport: Bool) throws {
        TruvideoMedia.shared.updateIncludeInReportForRequest(requestId, includeInReport: includeInReport)
    }
    
    
    @objc
    public func streamRetry(requestId: String,completion: @escaping (_ result: String?, _ error: Error?) -> Void
    ) {
        TruvideoMedia.shared.retryStreamRequest(id: requestId,completion: { result, error in
                completion(result, error)
            }
        )
    }
    
    @objc
    public func streamPause(requestId: String,completion: @escaping (_ result: String?, _ error: Error?) -> Void
    ) {
        TruvideoMedia.shared.streamPauseMedia(id: requestId,completion: { result, error in
                completion(result, error)
            }
        )
    }
    
    @objc
    public func streamResume(requestId: String,completion: @escaping (_ result: String?, _ error: Error?) -> Void
    ) {
        TruvideoMedia.shared.streamResumeMedia(id: requestId,completion: { result, error in
                completion(result, error)
            }
        )
    }
    
    @objc
    public func streamDelete(requestId: String,completion: @escaping (_ result: String?, _ error: Error?) -> Void
    ) {
        TruvideoMedia.shared.streamDeleteMedia(id: requestId,completion: { result, error in
                completion(result, error)
            }
        )
    }
    
    @objc
    public func streamCancel(requestId: String,completion: @escaping (_ result: String?, _ error: Error?) -> Void
    ) {
        TruvideoMedia.shared.cancelStreamRequest(id: requestId,completion: { result, error in
                completion(result, error)
            }
        )
    }
    
    @objc
    public func getStreamRequest(requestId: String,completion: @escaping (_ result: StreamUploadRequestResponse?, _ error: Error?) -> Void
    ) {
        TruvideoMedia.shared.getStreamUploadRequestById(id: requestId,completion: completion)
    }
    
    @objc
    public func getAllStreamRequests(completion: @escaping (_ result: [StreamUploadRequestResponse], _ error: Error?) -> Void
    ) {
        TruvideoMedia.shared.getAllStreamUploadRequests(completion: completion)
    }
    
    @objc
    public func streamUpload(
        requestId: String,
        title: String,
        tag: String,
        metaData: String,
        isIncludedInReport: Bool,
        isLibrary: Bool,
        completion: @escaping (_ result: StreamUploadRequestResponse?, _ error: Error?) -> Void
    ) {
        TruvideoMedia.shared.streamUploadMedia(
            id: requestId,
            title: title,
            tag: tag,
            metaData: metaData,
            isIncludedInReport: isIncludedInReport,
            isLibrary: isLibrary,
            completion: completion
        )
    }
    
    
    
}

extension TruvideoSdkMediaUploadRequest {
    
    func makeMediaRequest() async -> TruvideoMediaSdkUploadRequest {
            let duration = await durationMilliseconds ?? 0

            return TruvideoMediaSdkUploadRequest(
                id: id as NSUUID,
                filePath: filePath,
                errorMessage: errorMessage,
                remoteId: remoteId,
                remoteURL: remoteURL,
                uploadProgress: uploadProgress,
                transcriptionURL: transcriptionURL,
                transcriptionLenght: transcriptionLength as NSNumber?,
                metadata: metadata.dictionary as? NSDictionary,
                tags: tags.dictionary as? NSDictionary,
                status: convertTruvideoStatusToMediaStatus(status),
                createdAt: createdAt,
                updatedAt: updatedAt,
                includeInReport: includeInReport ?? false,
                fileType: convertTruvideoTypeToMediaType(fileType),
                durationMilliseconds: duration
            )
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
}
