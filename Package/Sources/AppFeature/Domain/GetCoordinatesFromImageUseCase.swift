import RegexBuilder
import UIKit

struct GetCoordinatesFromImageUseCase {
    private let recognizedTextsRepository: RecognizedTextsRepository
    private let getCoordinatesFromTextUseCase: GetCoordinatesFromTextUseCase

    init(
        recognizedTextsRepository: RecognizedTextsRepository = RecognizedTextsRepositoryImpl(),
        getCoordinatesFromTextUseCase: GetCoordinatesFromTextUseCase = GetCoordinatesFromTextUseCaseImpl()
    ) {
        self.recognizedTextsRepository = recognizedTextsRepository
        self.getCoordinatesFromTextUseCase = getCoordinatesFromTextUseCase
    }

    func execute(image: UIImage) async throws -> Coordinates? {
        let texts = try await recognizedTextsRepository.get(image: image)
        // シード値に余計な文字がついてしまったケースを考慮し、読み取れた文字を１つの文字列にして、シード値の形式にマッチするものをSeedにする
        let text = texts.joined(separator: " ")
        return await getCoordinatesFromTextUseCase.execute(text: text)
    }
}
