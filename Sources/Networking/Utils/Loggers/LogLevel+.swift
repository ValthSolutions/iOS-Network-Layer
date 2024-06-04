import NetworkInterface

extension LogLevel {
    public var logger: Loger {
        switch self {
        case .debug: DEBUGLog()
        case .release: RELEASELog()
        }
    }
}
