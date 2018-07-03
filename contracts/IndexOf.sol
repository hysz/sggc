/**
 * This file is part of the 1st Solidity Gas Golfing Conshift.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 *
 * Author: Greg Hysen (hyszeth.eth)
 * Date: June 2018
 * Description: Search for a needle in a haystack using the Boyer-Moore algorithm,
 *              along with the bad character heuristic. For single character needles,
 *              default to a simple naive search.
 */

pragma solidity 0.4.24;

contract IndexOf {

    // Return value when `needle` is not found in `haystack`.
    int256 constant NOT_FOUND = -1;

    /**
     * @dev Returns the index of the first occurrence of `needle` in `haystack`,
     *      or -1 if `needle` is not found in `haystack`.
     *
     * Input strings may be of any length <2^255.
     *
     * @param haystack The string to search.
     * @param needle The string to search for.
     * @return The index of `needle` in `haystack`, or -1 if not found.
     */
    function indexOf(string haystack, string needle)
        public
        pure
        returns(int)
    {
        // Lengths of input strings.
        uint256 haystackLength = bytes(haystack).length;
        uint256 needleLength = bytes(needle).length;

        // Handle base cases.
        if(needleLength > haystackLength) return -1;
        if(needleLength == 0) return 0;
        if(needleLength == 1) {
            // Needle is a single character; default to a naive search.
            uint needleChar = uint(bytes(needle)[0]);
            uint max = haystackLength/5 * 5;
            uint idx;
            // Search in groups to save gas.
            while(idx != max) {
                if(needleChar == uint(bytes(haystack)[idx++])) return int256(--idx);
                if(needleChar == uint(bytes(haystack)[idx++])) return int256(--idx);
                if(needleChar == uint(bytes(haystack)[idx++])) return int256(--idx);
                if(needleChar == uint(bytes(haystack)[idx++])) return int256(--idx);
                if(needleChar == uint(bytes(haystack)[idx++])) return int256(--idx);
            }
            // Search remaining characters in haystack.
            while(idx != haystackLength) if(needleChar == uint(bytes(haystack)[idx++])) return int256(--idx);
            return NOT_FOUND;
        }

        // No base case was hit; run Boyer-Moore.
        return boyerMooreSearch(haystack, needle, haystackLength, needleLength);
    }

    /**
     * @dev Runs boyer-moore with bad character heuristic.
     *      We start with both the needle and haystack aligned at index 0,
     *      matching characters from right to left (starting at the end of `needle`).
     *
     *      The last instance of each character in `needle` is stored in a lookup table, `badchar`.
     *      When there is a mismatch, we handle 3 cases:
     *      1. An instance of "bad character" exists in `needle` to the left of our current index.
     *         In this case, we shift `needle` into place so these characters match.
     *      2. One or more instances of "bad character" exist in `needle`, but because we
     *         only store the last instance we can't perform an optimized shift.
     *         In this case, we shift `needle` to the right by 1.
     *      3. There are no instances of "bad character" in `needle`.
     *         In this case, shift `needle` to the right past the "bad character".
     *
     * @param haystack The string to search.
     * @param needle The string to search for.
     * @param haystackLength The length of `haystack`.
     * @param needleLength The length of `needle`.
     * @return The index of `needle` in `haystack`, or -1 if not found.
     */
    function boyerMooreSearch(string haystack, string needle, uint256 haystackLength, uint256 needleLength)
        private
        pure
        returns(int)
    {
        // Create lookup table for characters in `needle`,
        // storing only the last occurence of each.
        uint256[256] memory badchar;
        uint tmp = needleLength/5 * 5;
        uint i;
        while(i != tmp) {
            // Run in groups of 5 to save gas.
            badchar[uint(bytes(needle)[uint(i)])] = uint(i + 1);
            badchar[uint(bytes(needle)[uint(i + 1)])] = uint(i + 2);
            badchar[uint(bytes(needle)[uint(i + 2)])] = uint(i + 3);
            badchar[uint(bytes(needle)[uint(i + 3)])] = uint(i + 4);
            badchar[uint(bytes(needle)[uint(i + 4)])] = uint(i + 5);
            i += 5;
        }
        // Fill in remaining characters.
        while(i != needleLength) {
            badchar[uint(bytes(needle)[uint(i++)])] = uint(i + 1);
        }

        // Maximum index in `needle`
        uint maxNeedleIndex = needleLength-1;
        // Maximumn offset into `haystack`
        uint maxHaystackOffset = (haystackLength - needleLength);
        // Current offset into `haystack`
        uint256 haystackOffset;
        // Current haystack character
        uint currentHaystackChar;
        // Amount to shift needle by
        uint shift;
        // Current index into `needle`
        uint256 needleIndex;
        while(haystackOffset <= maxHaystackOffset) {
            // Start searching from end of needle.
            needleIndex = maxNeedleIndex;

            // Fast forward through matches.
            while(uint(bytes(needle)[uint(needleIndex)]) == (currentHaystackChar = uint(bytes(haystack)[uint(haystackOffset + needleIndex)]))) {
                if(--needleIndex != uint(-1)) continue;
                // We found the substring!
                return int256(haystackOffset);
            }

            // We have a mismatch. Lookup the mismatched character in `badchar`.
            tmp = badchar[uint(currentHaystackChar)];
            if(tmp != 0) {
                // The mismatched character exists in `needle`
                if(tmp < needleIndex) {
                    // Case #1
                    haystackOffset += needleIndex - tmp;
                    continue;
                }
                // Case #2
                ++haystackOffset;
                continue;
            }
            // Case #3
            haystackOffset += needleIndex + 1;
        }

        return NOT_FOUND;
    }
}
