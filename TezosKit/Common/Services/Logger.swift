import Foundation

/// Log levels for TezosKit.
/// Implicitly ordered from most to least verbose.
public enum LogLevel: Int {
  case debug = 0
  case info = 1
  case none = 2
}

/// Provides logging functionality in TezosKit.
public class Logger {
  /// A shared singleton logging instance.
  public static let shared = Logger(logLevel: .none)

  /// The level at which messages will be logged.
  public var logLevel: LogLevel

  /// Please use the shared singleton rather than instantiating this class directly.
  ///
  /// - Parameter logLevel: The level of logs this logger will show.
  private init(logLevel: LogLevel) {
    self.logLevel = logLevel
  }

  /// Log a message.
  ///
  /// - Parameters:
  ///   - message: The message to log.
  ///   - logLevel: The logLevel of the message.
  public func log(_ message: String, level: LogLevel) {
    // Only log if the log level of the Logger is less than the log level of the mssage
    if self.logLevel.rawValue <= level.rawValue {
      print(message)
    }
  }
}
