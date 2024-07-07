import RegexBuilder
import UIKit

protocol GetSeedFromImageUseCase: Sendable {
    func execute(image: UIImage) async throws -> Seed?
//    func execute(image: UIImage) -> AnyPublisher<Seed?, RecognizeTextLocalRequestError>
}

struct GetSeedFromImageUseCaseImpl: GetSeedFromImageUseCase {
    private let recognizedTextsRepository: any RecognizedTextsRepository
    private let getSeedFromTextUseCase: any GetSeedFromTextUseCase

    init(
        recognizedTextsRepository: any RecognizedTextsRepository = RecognizedTextsRepositoryImpl(),
        getSeedFromTextUseCase: any GetSeedFromTextUseCase = GetSeedFromTextUseCaseImpl()
    ) {
        self.recognizedTextsRepository = recognizedTextsRepository
        self.getSeedFromTextUseCase = getSeedFromTextUseCase
    }

    func execute(image: UIImage) async throws -> Seed? {
        let texts = try await recognizedTextsRepository.get(image: image)
        // シード値に余計な文字がついてしまったケースを考慮し、読み取れた文字を１つの文字列にして、シード値の形式にマッチするものをSeedにする
        let text = texts.joined(separator: " ")
        return await getSeedFromTextUseCase.execute(text: text)
    }
}
