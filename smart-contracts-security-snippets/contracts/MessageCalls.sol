// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Source {
    Target target;

    constructor(Target _target) {
        target = _target;
    }

    function callTarget() public {
        uint test = 1;
        bytes memory isSaved = hex"cacacaca";
        bytes memory returnedVaule = target.doSomething(test);
    }
}

contract Target {
    function doSomething(uint test) public returns (bytes memory) {
        return hex"ffffffff";
    }
}