#if canImport(DTTJailbreakDetection)
import DTTJailbreakDetection
#endif

/// Utilities for working with Jailbroken devices.
public enum JailbreakUtils {
  /// Crash if the host device is jailbroken.
  ///
  /// Jailbroken device have no access control on root files, hence rendering the sandbox mode useless. This potentially exposes keys and can lead to loss
  /// of funds.
  public static func crashIfJailbroken() {
    if JailbreakUtils.isJailBroken() {
      fatalError(
        """
        Jailbreak detected on host device. Using TezosKit on a jailbroken device may expose your keys and lead to loss
        of funds.
        """
      )
    }
  }

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
