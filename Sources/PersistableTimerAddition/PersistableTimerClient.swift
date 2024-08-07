import Foundation
import Dependencies
import DependenciesMacros

/// A client for managing a persistable timer, capable of restoring state after application termination.
/// This client abstracts the functionalities of a `PersistableTimer` into a set of dependency functions.
@DependencyClient
public struct PersistableTimerClient: Sendable {
    /// Provides a continuous stream of timer states, updated at regular intervals.
    public var timerStream: @Sendable () -> AsyncStream<TimerState> = { unimplemented("\(Self.self).timerStream") }

    /// Retrieves the persisted timer data, if available.
    /// - Throws: Errors encountered while fetching the timer data.
    public var getTimerData: @Sendable () throws -> RestoreTimerData?

    /// Checks if a timer is currently running.
    /// - Returns: A Boolean value indicating whether a timer is running.
    public var isTimerRunning: @Sendable () -> Bool = { unimplemented("\(Self.self).isTimerRunning") }

    /// Restores the timer from the last known state and starts the timer if it was running.
    /// - Throws: Errors encountered while restoring the timer.
    public var restore: @Sendable () throws -> RestoreTimerData

    /// Starts the timer with the specified type, optionally forcing a start even if a timer is already running.
    /// - Parameters:
    ///   - type: The type of timer, either stopwatch or countdown.
    ///   - forceStart: A Boolean value to force start the timer, ignoring if another timer is already running.
    /// - Throws: Errors encountered while starting the timer.
    public var start: @Sendable (_ type: RestoreType, _ forceStart: Bool) async throws -> RestoreTimerData

    /// Resumes a paused timer.
    /// - Throws: Errors encountered while resuming the timer.
    public var resume: @Sendable () async throws -> RestoreTimerData

    /// Pauses the currently running timer.
    /// - Throws: Errors encountered while pausing the timer.
    public var pause: @Sendable () async throws -> RestoreTimerData

    /// Finishes the timer and optionally resets the elapsed time.
    /// - Parameter isResetTime: A Boolean value indicating whether to reset the elapsed time upon finishing.
    /// - Throws: Errors encountered while finishing the timer.
    public var finish: @Sendable (_ isResetTime: Bool) async throws -> RestoreTimerData
}

extension PersistableTimerClient {
    /// Creates a live instance of `PersistableTimerClient` with the specified data source type.
    /// - Parameter dataSourceType: The type of data source to use, either in-memory or UserDefaults.
    /// - Returns: A `PersistableTimerClient` instance configured with a live `PersistableTimer`.
    public static func live(
        dataSourceType: DataSourceType,
        updateInterval: TimeInterval = 1,
        useFoundationTimer: Bool = false
    ) -> Self {
        let timer = PersistableTimer(
            dataSourceType: dataSourceType,
            updateInterval: updateInterval,
            useFoundationTimer: useFoundationTimer
        )
         return PersistableTimerClient(
             timerStream: { timer.timeStream },
             getTimerData: { try timer.getTimerData() },
             isTimerRunning: { timer.isTimerRunning() },
             restore: { try timer.restore() },
             start: { type, forceStart in try await timer.start(type: type, forceStart: forceStart) },
             resume: { try await timer.resume() },
             pause: { try await timer.pause() },
             finish: { isResetTime in try await timer.finish(isResetTime: isResetTime) }
         )
    }
}

extension PersistableTimerClient: TestDependencyKey {
    /// Provides a stubbed or mocked instance of `PersistableTimerClient` for testing purposes.
    public static let testValue = Self()
}

public extension DependencyValues {
    /// The `PersistableTimerClient` dependency, used for managing a persistable timer in the app.
    var persistableTimerClient: PersistableTimerClient {
        get { self[PersistableTimerClient.self] }
        set { self[PersistableTimerClient.self] = newValue }
    }
}
