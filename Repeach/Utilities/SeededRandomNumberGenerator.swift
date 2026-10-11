/// A deterministic random number generator initialized with a `UInt64` seed.
///
/// Two generators created with the same seed produce the same sequence. This is
/// useful for reproducible quizzes and tests, but not for cryptography.
/// The SplitMix64 algorithm is used to generate the numbers.
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(with seed: UInt64) {
        self.state = seed
    }

    /// Generate the next value through the SplitMix64 algorithm.
    ///
    /// SplitMix64 is a fairly simple algorithm that, though it is considered to be poor for cryptographic purposes,
    /// is very fast to calculate, and is "good enough" for many random number needs.
    /// More information on the algorithm can be found on:
    /// [Rosetta Code](https://rosettacode.org/wiki/Pseudo-random_numbers/Splitmix64).
    mutating func next() -> UInt64 {
        self.state &+= 0x9E3779B97F4A7C15

        var value = self.state
        value = (value ^ (value >> 30)) &* 0xBF58476D1CE4E5B9
        value = (value ^ (value >> 27)) &* 0x94D049BB133111EB
        
        return value ^ (value >> 31)
    }
}
