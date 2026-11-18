/// Major units → integer minor units (sen, cents), rounding half up.
///
/// Rounds a fixed-point string first so float noise
/// (1.005 * 100 = 100.4999…) can't change the result. Must match
/// `toMinorUnits` in `functions/src/rules.ts`, which the server uses to
/// charge the card.
int toMinorUnits(double amount) =>
    double.parse((amount * 100).toStringAsFixed(6)).round();
