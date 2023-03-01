import Combine
import NetworkInterface
import Network

public final class CheckRepository {
  private let remoteDataSource: CheckDataSource

    public init(remoteDataSource: CheckDataSource) {
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
