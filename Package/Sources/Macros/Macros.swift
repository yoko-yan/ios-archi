/// Generates a mock class for the protocol.
///
/// The generated mock class has the same name as the protocol with "Mock" suffix.
/// It includes:
/// - Call count tracking for each method
/// - Received arguments recording
/// - Closure-based customization
/// - Throwable error injection
///
/// Usage:
/// ```swift
/// @Mockable
/// protocol MyService {
///     func fetchData() async throws -> Data
/// }
/// ```
@attached(peer, names: suffixed(Mock))
public macro Mockable() = #externalMacro(module: "MacrosPlugin", type: "MockableMacro")
