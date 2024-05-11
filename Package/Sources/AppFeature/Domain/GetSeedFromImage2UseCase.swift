import Dependencies
import UIKit

protocol GetSeedFromImage2UseCase {
    func execute(image: UIImage) async throws -> Seed?
}

struct GetSeedFromImage2UseCaseImpl: GetSeedFromImage2UseCase {
    @Dependency(\.newRecognizedTextsRepository) var newRecognizedTextsRepository
    @Dependency(\.getSeedFromTextUseCase) var getSeedFromTextUseCase

    func execute(image: UIImage) async throws -> Seed? {
        let texts = try await newRecognizedTextsRepository.get(image: image)
        // シード値に余計な文字がついてしまったケースを考慮し、読み取れた文字を１つの文字列にして、シード値の形式にマッチするものをSeedにする
        let text = texts.joined(separator: " ")
        return await getSeedFromTextUseCase.execute(text: text)
    }
}
