//
//  Camera.swift
//  ios-archi
//
//  Created by yokoda.takayuki on 2023/01/25.
//

import SwiftUI
import Vision
import VisionKit

struct CameraView: View {
    @State var imageData: Data = .init(capacity: 0)
    @State var source: UIImagePickerController.SourceType = .photoLibrary

    @State var isImagePicker = false
    private var requests = [VNRequest]()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ZStack {
                    NavigationLink(
                        destination:
                            ImagePicker(
                                show: $isImagePicker,
                                image: $imageData,
                                sourceType: source
                            ),
                        isActive: $isImagePicker,
                        label: { Text("") }
                    )
                    VStack(spacing: 0) {
                        if imageData.count != 0{
                            Image(
                                uiImage: UIImage(data: self.imageData)!
                            )
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 250)
                            .cornerRadius(15)
                            .padding()
                        }
                        Button {
                            self.isImagePicker.toggle()
                        } label: {
                            Text("Take Photo")
                        }
                        Button {
                            aaa()
                        } label: {
                            Text("Take Photo")
                        }
                    }
                }
            }
        }
    }

    private func aaa() {uests.
        let textRecognitionWorkQueue = DispatchQueue(label: "TextRecognitionQueue",
                                                     qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
        textRecognitionWorkQueue.async {
            self.resultingText = ""
            for pageIndex in 0 ..< scan.pageCount {
                let image = scan.imageOfPage(at: pageIndex)
                if let cgImage = image.cgImage {
                    let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

                    do {
                        try requestHandler.perform(self.requests)
                    } catch {
                        print(error)
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                // textViewに表示する
                self.textView.text = self.resultingText
            })
        }
    }

    // Setup Vision request as the request can be reused
    private mutating func setupVision() {
        let textRecognitionRequest = VNRecognizeTextRequest { request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("The observations are of an unexpected type.")
                return
            }
            // 解析結果の文字列を連結する
            let maximumCandidates = 1
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
//                self.resultingText += candidate.string + "\n"
            }
        }
        // 文字認識のレベルを設定
        textRecognitionRequest.recognitionLevel = .accurate
        self.requests = [textRecognitionRequest]
    }

    // 文字認識できる言語の取得
    private func getSupportedRecognitionLanguages() {
        let accurate = try! VNRecognizeTextRequest.supportedRecognitionLanguages(for: .accurate, revision: VNRecognizeTextRequestRevision1)
        print(accurate)
    }

    func cameraButtonTapped() {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
