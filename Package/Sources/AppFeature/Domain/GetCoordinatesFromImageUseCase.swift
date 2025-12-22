import RegexBuilder
import UIKit

struct GetCoordinatesFromImageUseCase: Sendable {
    private let recognizedTextsRepository: any RecognizedTextsRepository
    private let getCoordinatesFromTextUseCase: any GetCoordinatesFromTextUseCase

    init(
        recognizedTextsRepository: any RecognizedTextsRepository = RecognizedTextsRepositoryImpl(),
        getCoordinatesFromTextUseCase: any GetCoordinatesFromTextUseCase = GetCoordinatesFromTextUseCaseImpl()
    ) {
        self.recognizedTextsRepository = recognizedTextsRepository
        self.getCoordinatesFromTextUseCase = getCoordinatesFromTextUseCase
    }

    func execute(image: UIImage, settings: CameraSettings) async throws -> Coordinates? {
        let texts = try await recognizedTextsRepository.get(image: image, settings: settings)
        // シード値に余計な文字がついてしまったケースを考慮し、読み取れた文字を１つの文字列にして、シード値の形式にマッチするものをSeedにする
        let text = texts.joined(separator: " ")
        return await getCoordinatesFromTextUseCase.execute(text: text)
    }

    func execute(image: UIImage) async throws -> Coordinates? {
        try await execute(image: image, settings: .default)
    }
}
