import Combine
import NetworkInterface
import Network

final class CheckRepository {
  private let remoteDataSource: CheckDataSource

  init(remoteDataSource: CheckDataSource) {
    self.remoteDataSource = remoteDataSource
  }
}

extension CheckRepository {

  func checkList() -> AnyPublisher<CheckListDTO, DataTransferError> {
      return remoteDataSource.checkList()
      .map { list in
          return list
      }
      .eraseToAnyPublisher()
  }
}
