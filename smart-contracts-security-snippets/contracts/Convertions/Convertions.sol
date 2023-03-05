// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Conversions {

    function addressToBytes32() public view returns (bytes32) {
        return bytes32(uint256(uint160(msg.sender)));
    }

    function addressToUint160() public pure returns (uint160) {
        address from = address(0xFbAD768340a24E06384591537d7D2F80693d6aDB);
        uint160 result = uint160(from);
        return result;
    }

    function addressToUint16() public pure returns (uint16) {
        address from = address(0xFbAD768340a24E06384591537d7D2F80693d6aDB);
        uint16 result = uint16(uint160(from));         // 6ADB
        return result;                              
    }

    function addressToUint16ToBytes2() public pure returns (bytes2) {
        address from = address(0xFbAD768340a24E06384591537d7D2F80693d6aDB);
        uint16 addressInUint16 = uint16(uint160(from));
        bytes2 result = bytes2(addressInUint16);    // 693D6ADB
        return result;
    }

    function addresstoBytes20() public pure returns (bytes20) {
        address from = address(0xFbAD768340a24E06384591537d7D2F80693d6aDB);
        bytes20 result = (bytes20(from));
        return result;
    }

    function addresstoBytes2() public pure returns (bytes2) {
        address from = address(0xFbAD768340a24E06384591537d7D2F80693d6aDB);
        bytes2 result = bytes2((bytes20(from)));
        return result;
    }

    

    function addressToUint32() public pure returns (uint32) {
        address from = address(0xFbAD768340a24E06384591537d7D2F80693d6aDB);
        uint32 addressInUint32 = uint32(uint160(from));
        return addressInUint32;
    }

    function gateThree() public pure returns (bool) {
        address from = address(0xFbAD768340a24E06384591537d7D2F80693d6aDB); //address = bytes20 = uint160
        // require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)));
        // require(uint32(uint64(_gateKey)) != uint64(_gateKey));
        // require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)));

        // k = uint64(_gateKey);

                        /// Opening Condition 3 //
        // uint32(k) == uint16(uint160(tx.origin));         | Condition 3
        // Condition 3 basically calculates the value for uint32(k)
            // uint32(k) = uint16(uint160(tx.origin))
                // uint32(k) will forcefully be an uint32 with the first 16 bits set to 0s, and the last 16 bits will be the result of uint16(uint160(tx.origin))

        //          uint32                      ==              uint16                      ===>           uint32(uint16)
        // XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX  ==  -------- -------- XXXXXXXX XXXXXXXX     ===>    00000000 00000000 XXXXXXXX XXXXXXXX

        // 

                        // Opening Condition 2 //
        // uint32(k) == uint16(k);                          | Condition 2

        /*
            if      uint32(uint64(_gateKey)) == uint16(uint160(tx.origin))   (Condition 3)
                                        && 
                    uint32(uint64(_gateKey)) == uint16(uint64(_gateKey))     (Condition 1)

            Thus:   uint16(uint160(tx.origin)) == uint16(uint64(_gateKey))


            if      uint16(uint160(tx.origin)) == uint16(uint64(_gateKey))  
                                        &&
                    uint32(k)                   = uint16(uint160(tx.origin))

            Thus:   uint32(k) == uint16(uint64(_gateKey))   ====>   uint16(uint160(tx.origin)) == uint16(uint64(_gateKey))  ===>   uint32(k) == uint16(uint160(tx.origin)) 

                    ///// The above means, k16 opens condition 3 & 2

        */

        // uint k16 = uint16(uint160(tx.origin))
        uint16 k16 = uint16(uint160(from));


                    /// Opening Condition 1 ///
        
        // uint32(k) != k;          <--- How to force that k which is an uint64 will have a different value when is casted to 32bits?

                // When casting from uint64 to uint32, what will happen is that the 32 first most-right bits will be rid-off and the uint32 will only contain the last 32 most-left bits
                    // Original uint64 ====> XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX
                    // Casting to uint32 ==> -------- -------- XXXXXXXX XXXXXXXX

                // So, the safest way to ensure that the original uint64 is different than the casted uint32 is by having a 1 at the first bit at the right, thay bit will be taken away from the uint32

                // And when the casted uint32 is then re-casted back to uint64, the resultant value will be full zero-padded on the first 32 bits
                    // Original uint64      ===> 1XXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX            <----> The original uint64 has the 1 at the first right bit
                    // uint32(uint64)       ===> -------- -------- XXXXXXXX XXXXXXXX
                    // uint64(uint32(uint64)) => 00000000 00000000 XXXXXXXX XXXXXXXX            <----> The recasted uint32(uint64) to uint64 lost the 1 from the original uint64, thus, uint32(k) != k

            // k = uint64(_gateKey);
        uint64 mask = uint64(1 << 63); // Generates the binary number:              10000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
        uint64 k64 = mask + uint64(k16);    
            // k16 will be zero-padded at the right from its 16bits up to 64bits
            // The k16 casted to 64 will be something like:                         00000000 00000000 00000000 00000000 00000000 00000000 00000000 XXXXXXXX 
            
            // Adding the mask + the uint64(k16)
                // The result will be an uint64 binary number similar to

                    // 10000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
                    //                                  +
                    // 00000000 00000000 00000000 00000000 00000000 00000000 00000000 XXXXXXXX 
                    // =======================================================================
    // uint64 k64 =    10000000 00000000 00000000 00000000 00000000 00000000 00000000 XXXXXXXX

    /*
        uint32(k) != k
            - k =           10000000 00000000 00000000 00000000 00000000 00000000 00000000 XXXXXXXX
            - uint32(k) =   -------- -------- -------- -------- 00000000 00000000 00000000 XXXXXXXX
        
        - uint64(uint32(k)) 00000000 00000000 00000000 00000000 00000000 00000000 00000000 XXXXXXXX

        - Thus:     00000000 00000000 00000000 00000000 00000000 00000000 00000000 XXXXXXXX     <=====> uint32(k)
                                            !=
                    10000000 00000000 00000000 00000000 00000000 00000000 00000000 XXXXXXXX     <=====> k
    */

    // Therefore, k64 = k!
    // if k = uint64(_gateKey) => k64
    // if bytes8 _gateKey == uint64(_gateKey)
        // _gateKey == k64  <--> Making k64 compatible with _gateKey    ===> bytes8 _gateKey = bytes8(k64)
    bytes8 key = bytes8(k64);

    require(uint32(uint64(key)) == uint16(uint64(key)), "GatekeeperOne: invalid gateThree part one");
    require(uint32(uint64(key)) != uint64(key), "GatekeeperOne: invalid gateThree part two");
    require(uint32(uint64(key)) == uint16(uint160(from)), "GatekeeperOne: invalid gateThree part three");

    return true;

    }


    function test() public pure returns(uint64) {
        return uint64(1 << 63);
        // returns a decimal value of: 9223372036854775808
        // Which in binary is:  10000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    }


}