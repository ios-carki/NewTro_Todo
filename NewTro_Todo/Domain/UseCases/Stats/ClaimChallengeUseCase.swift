import Foundation

protocol ClaimChallengeUseCaseProtocol {
    func execute(challengeId: String, points: Int) async
}

final class ClaimChallengeUseCase: ClaimChallengeUseCaseProtocol {
    private let repository: any StatsRepositoryProtocol

    init(repository: any StatsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(challengeId: String, points: Int) async {
        await repository.claimChallenge(id: challengeId, points: points)
    }
}
