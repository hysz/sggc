/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 *
 * Author: Greg Hysen (hyszeth.eth)
 * Date: June 2018
 * Description: Uses a simple equation to decode a hex string
 *              into its corresponding binary value.
 */

pragma solidity 0.4.24;

contract HexDecoder {

    /**
     * @dev Decodes a hex-encoded input string, returning it in binary.
     *
     * Input strings may be of any length, but will always be a multiple of two
     * bytes long, and will not contain any non-hexadecimal characters.
     *
     * @param input The hex-encoded input.
     * @return The decoded output.
     */
    function decode(string input) public pure returns(bytes output) {
        // Base case
        uint inputLength = bytes(input).length;
        if(inputLength == 0) return output;

        // index into `output`
        uint j;

        // Each pair of hex characters translates to 1 byte,
        // so output is `inputLen` / 2
        output = new bytes(inputLength / 2);

        // Run conversion
        for(uint i = 0; i != inputLength; i += 2) {
            // Combine left & right into one whole byte
            output[j++] = byte(
                                getHalfOfByte(uint(bytes(input)[i+1])) +
                                getHalfOfByte(uint(bytes(input)[i])) * 16
                              );
        }
        return output;
    }

    /**
     * @dev Translates an ASCII hex character to its corresponding binary value.
     *
     * @param hexLetter Letter to translate.
     * @return The corresponding half-byte of binary.
     */
    function getHalfOfByte(uint hexLetter) internal pure returns (uint) {
        /*
            [0-9] is ASCII [0x30-0x39]
            [a-f] is ASCII [0x41-0x46]
            [A-F] is ASCII [0x61-0x66]

            These ranges are used to construct the conversion below:
                #1
                    [0] is [0x30] (0x30 % 16 = 0)
                    [1] is [0x31] (0x31 % 16 = 1)
                    ...
                    => [0-9] % 16 is the correct mapping.


                    [a] = [0x41] (0x41 % 16 = 1) and [A] = [0x61] (0x61 % 16 = 1)
                    [b] = [0x42] (0x42 % 16 = 2) and [B] = [0x62] (0x62 % 16 = 2)
                    ...
                    =>
                    [a-f] % 16 + 9 is the correct mapping.
                    [A-F] % 16 + 9 is the correct mapping.

                #2
                    The MSB of [0-9] is `0`.
                    The MSB of [a-f] and [A-F] is `1` (for 64).
                    Divide the value by 64 to shift this MSB to the LSB.
                    =>
                    [0-9] / 64 = 0
                    [a-f] / 64 = 1
                    [A-F] / 64 = 1

                    Multiply this value by 9 to get the correct offset for #1.

    	        #3
                    It's cheaper to & than %, so rather than `% 16` do `& 15`.
        */
        return (hexLetter/uint(64)) * 9 + hexLetter & 15;
    }
}
