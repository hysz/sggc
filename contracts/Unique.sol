/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 *
 * Author: Greg Hysen (hyszeth.eth)
 * Date: June 2018
 * Description: A simple hash table with open-addressing and linear probing
 *              is used to filter out duplicate array elements. The unique
 *              array is generated in-place, with distinct elements overwriting
 *              duplicates. At the end of the algorithm, these values are
 *              transposed to a separate array with a length equal to the number
 *              of unique elements.
 */

pragma solidity 0.4.24;

contract Unique {

    // Hash table size.
    // - Size should be prime for a good average distribution.
    // - Space is preallocated, for efficiency.
    // - Specific value was selected based on gas and average # of collisions.
    uint constant HASH_TABLE_SIZE = 313;

    // A randomly generated offset that is added to each entry in the hash table.
    // Rather than storing additional information on occupancy, we add this offset to each entry.
    // Since the table is initially zeroed out, we consider `0` to mean unoccupied.
    uint constant RAND_OFFSET = 0x613c12789c3f663a544355053c9e1e25d50176d60796a155f553aa0f8445ee66;

    /**
     * @dev Removes all but the first occurrence of each element from a list of
     *      integers, preserving the order of original elements, and returns the list.
     *
     * The input list may be of any length.
     *
     * @param input The list of integers to uniquify.
     * @return The input list, with any duplicate elements removed.
     */
    function uniquify(uint[] input)
        public
        pure
        returns(uint[] ret)
    {
        // Base cases
        uint inputLength = input.length;
        if(inputLength == 0 || inputLength == 1) return input;

        // Fast forward to second unique character, if one exists.
        uint firstCharacter = input[0];
        uint i = 1;
        while(input[i] == firstCharacter) {
            if(++i != inputLength) continue;
            // The entire array was composed of a single value.
            ret = createUniqueArray(input, 1);
            return ret;
        }

        // Run uniquify on remaining elements.
        // `i` is index of the first mismatch.
        ret = uniquifyPrivate(
            input,
            inputLength,
            firstCharacter,
            i
        );
        return ret;
    }

    /**
     * @dev A simple hash table with open-addressing and linear probing
     *      is used to filter out duplicate array elements. The unique
     *      array is generated in-place, with distinct elements overwriting
     *      duplicates. At the end of the algorithm, these values are
     *      transposed to a separate array with a length equal to the number
     *      of unqiue elements.
     *
     * @param input The list of integers to uniquify.
     * @param inputLength The length of `input`.
     * @param current First element in `input`.
     * @param i Where to start search.
     * @return The input list, with any duplicate elements removed.
     */
    function uniquifyPrivate(
        uint[] input,
        uint inputLength,
        uint current,
        uint i
    )
        private
        pure
        returns(uint[])
    {
        // Create hash table; initialized to all zeroes.
        uint[HASH_TABLE_SIZE] memory hashTable;
        // Record first element in `hashTable`
        uint hashKey = current % HASH_TABLE_SIZE;
        uint hashValue = current + RAND_OFFSET;
        hashTable[hashKey] = hashValue;
        // Unique elements overwrite duplicates in `input`.
        uint uniqueIndex = 1;
        // Holds the current hash value while searching the hash table.
        uint queriedHashValue;

        // Create unique list.
        while(i != inputLength) {
            // One the right side of `==`, `current` resolves
            // to the value it had on the previous loop iteration.
            if((current = input[i]) == current) {
                ++i;
                continue;
            }

            // Check if current `input` element is unique.
            hashValue = current + RAND_OFFSET;
            if((queriedHashValue=hashTable[(hashKey = current % HASH_TABLE_SIZE)]) == 0) {
                // Current element is unique.
                // Move value to its correct position in `input` and record in hash table.
                if(uniqueIndex != i++) input[uniqueIndex] = current;
                uniqueIndex++;
                hashTable[hashKey] = hashValue;
                continue;
            }

            // We know `hashKey` exists in `hashTable`, meaning this value
            // is either a duplcicate or we have a hash collision.
            while(queriedHashValue != hashValue) {
                // Calculate next key
                hashKey = (hashKey + 1) % HASH_TABLE_SIZE;
                // If non-zero, keep searching.
                if((queriedHashValue = hashTable[(hashKey)]) != 0) {
                    continue;
                }
                // False positive, this element is unique.
                // Move value to its correct position in `input` and record in hash table.
                if(uniqueIndex != i) input[uniqueIndex] = current;
                uniqueIndex++;
                hashTable[hashKey] = hashValue;
                break;
            }

            // We found a duplicate element. Increment index into `input`.
            ++i;
        }

        // If all elements were unique, simply return `input`.
        // Otherwise, transpose the unique list to its own array.
        if(i == uniqueIndex) return input;
        return createUniqueArray(input, uniqueIndex);
    }

    /**
     * @dev Transposes unique elements to a separate array.
     *
     * @param input The list of integers to uniquify.
     * @param uniqueLength Length of unique subarray.
     * @return The input list, with any duplicate elements removed.
     */
    function createUniqueArray(uint[] input, uint uniqueLength)
        private
        pure
        returns(uint[] ret)
    {
        // Copy in groups of 10 to save gas.
        ret = new uint[](uniqueLength);
        uint max = uniqueLength/10 * 10;
        uint i;
        while(i != max) {
            ret[i++] = input[i];
            ret[i++] = input[i];
            ret[i++] = input[i];
            ret[i++] = input[i];
            ret[i++] = input[i];
            ret[i++] = input[i];
            ret[i++] = input[i];
            ret[i++] = input[i];
            ret[i++] = input[i];
            ret[i++] = input[i];
        }
        while(i != uniqueLength) ret[i++] = input[i];
        return ret;
    }
}
