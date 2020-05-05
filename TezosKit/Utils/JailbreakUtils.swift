#if canImport(DTTJailbreakDetection)
import DTTJailbreakDetection
#endif

/// Utilities for working with Jailbroken devices.
public enum JailbreakUtils {
  /// Return whether or not the host device is jailbroken.
  ///
  /// On non-iOS builds, this function will always return `false`.
  public static func isJailBroken() -> Bool {
    #if canImport(DTTJailbreakDetection)
      return DTTJailbreakDetection.isJailbroken()
    #else
      return false
    #endif
  }
}
