// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title TrendPredictor — lightweight on-chain trend estimator (no imports, no constructor, no inputs)
/// @notice Add datapoints by sending wei when calling addDataPoint().
/// @dev Implements EMA + simple slope-based trend detection.

contract TrendPredictor {
    uint8 public constant WINDOW = 10;
    uint16 public constant MAX_HISTORY = 100;

    uint16 public constant ALPHA_NUM = 2;
    uint16 public constant ALPHA_DEN = 10;

    uint256[MAX_HISTORY] private history;
    uint256 private nextIndex = 0;
    uint256 private count = 0;

    uint256 public ema;
    bool public emaInitialized = false;

    event DataPointAdded(uint256 indexed index, uint256 value, uint256 timestamp);
    event EmaUpdated(uint256 newEma, uint256 timestamp);

    // --- External Functions ---

    /// @notice Add a datapoint by sending ETH (msg.value).
    function addDataPoint() external payable {
        uint256 value = msg.value;

        history[nextIndex] = value;
        emit DataPointAdded(nextIndex, value, block.timestamp);

        nextIndex = (nextIndex + 1) % MAX_HISTORY;
        if (count < MAX_HISTORY) count += 1;

        _updateEma(value);
    }

    function getCount() external view returns (uint256) {
        return count;
    }

    function getWindow() external view returns (uint256[] memory) {
        uint256 n = WINDOW;
        if (count < n) n = count;

        uint256[] memory out = new uint256[](n);
        uint256 start;
        if (count < WINDOW) {
            start = (nextIndex + MAX_HISTORY - count) % MAX_HISTORY;
        } else {
            start = (nextIndex + MAX_HISTORY - WINDOW) % MAX_HISTORY;
        }

        for (uint256 i = 0; i < n; i++) {
            out[i] = history[(start + i) % MAX_HISTORY];
        }
        return out;
    }

    function getEma() external view returns (uint256) {
        return ema;
    }

    function computeSlope() external view returns (int256 slopeScaled) {
        uint256 n = WINDOW;
        if (count < n) n = count;
        if (n < 2) return 0;

        int256 sumX = 0;
        int256 sumY = 0;
        int256 sumXY = 0;
        int256 sumX2 = 0;

        uint256 start;
        if (count < WINDOW) {
            start = (nextIndex + MAX_HISTORY - count) % MAX_HISTORY;
        } else {
            start = (nextIndex + MAX_HISTORY - WINDOW) % MAX_HISTORY;
        }

        for (uint256 i = 0; i < n; i++) {
            int256 x = int256(i);
            int256 y = int256(history[(start + i) % MAX_HISTORY]);
            sumX += x;
            sumY += y;
            sumXY += x * y;
            sumX2 += x * x;
        }

        int256 N = int256(n);
        int256 num = N * sumXY - sumX * sumY;
        int256 den = N * sumX2 - sumX * sumX;

        if (den == 0) return 0;

        slopeScaled = (num * 1e18) / den;
    }

    function predictTrend() external view returns (int8) {
        int256 slope = this.computeSlope();
        int256 upThreshold = int256(1e14);
        int256 downThreshold = -int256(1e14);

        if (slope > upThreshold) return 1;
        if (slope < downThreshold) return -1;

        if (count == 0) return 0;
        uint256 lastIndex = (nextIndex + MAX_HISTORY - 1) % MAX_HISTORY;
        uint256 lastValue = history[lastIndex];

        if (emaInitialized) {
            if (lastValue > ema + ema / 20) return 1;
            if (lastValue + lastValue / 20 < ema) return -1;
        }

        return 0;
    }

    function clearData() external {
        nextIndex = 0;
        count = 0;
        ema = 0;
        emaInitialized = false;
    }

    function getLastDataPoint() external view returns (uint256) {
        if (count == 0) return 0;
        uint256 lastIndex = (nextIndex + MAX_HISTORY - 1) % MAX_HISTORY;
        return history[lastIndex];
    }

    // --- Internal Helpers ---
    function _updateEma(uint256 value) internal {
        if (!emaInitialized) {
            ema = value;
            emaInitialized = true;
            emit EmaUpdated(ema, block.timestamp);
            return;
        }

        uint256 partNew = (uint256(ALPHA_NUM) * value) / uint256(ALPHA_DEN);
        uint256 partOld = (uint256(ALPHA_DEN - ALPHA_NUM) * ema) / uint256(ALPHA_DEN);
        ema = partNew + partOld;
        emit EmaUpdated(ema, block.timestamp);
    }
}
