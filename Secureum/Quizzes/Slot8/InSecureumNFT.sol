pragma solidity 0.8.0;

interface ERC721TokenReceiver{function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);}

// Assume that all strictly required ERC721 functionality (not shown) is implemented correctly
// Assume that any other required functionality (not shown) is implemented correctly
contract InSecureumNFT {
    //@audit-info => As per OZ Documentation, luckily the HEXA value is indeed the correct value of the IERC721.onERC721Received.selector function, I'd personally recomend to set the value to IERC721.onERC721Received.selector instead of its hardoced bytes equivalent!
    /*
    Whenever an IERC721 tokenId token is transferred to this contract via IERC721.safeTransferFrom by operator from from, this function is called.
    It must return its Solidity selector to confirm the token transfer. If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
    The selector can be obtained in Solidity with IERC721.onERC721Received.selector.
    */
    bytes4 internal constant MAGIC_ERC721_RECEIVED = 0x150b7a02;
    //@audit-info => Mixing variables of different environemnts in the same codebase
    uint public constant TOKEN_LIMIT = 10; // 10 for testing, 13337 for production
    uint public constant SALE_LIMIT = 5; // 5 for testing, 1337 for production

    mapping (uint256 => address) internal idToOwner;
    uint internal numTokens = 0;
    uint internal numSales = 0;
    address payable internal deployer;
    address payable internal beneficiary;
    bool public publicSale = false;
    uint private price;
    uint public saleStartTime;
    uint public constant saleDuration = 13*13337; // 13337 blocks assuming 13s block times 
    uint internal nonce = 0;
    uint[TOKEN_LIMIT] internal indices;
 
    constructor(address payable _beneficiary) {
        deployer = payable(msg.sender);
        beneficiary = _beneficiary;
    }

    function startSale(uint _price) external {
        //@audit-issue => As per the error message, the two conditions must be true (&&) not only one of the two (||)
        //@audit-issue => Actually, using the || operator, anybody can start the sale by setting a price different than 0!
        //@audit => Change the OR (||) opeartor for an AND (&&) operator
        require(msg.sender == deployer || _price != 0, "Only deployer and price cannot be zero");
        price = _price;
        saleStartTime = block.timestamp;
        publicSale = true;
    }

    //@audit => Validating if the codesize of an address is 0 does not guarantee at a 100% that the address is not a contract!
    function isContract(address _addr) internal view returns (bool addressCheck) {
        uint256 size;
        assembly { size := extcodesize(_addr) }
        addressCheck = size > 0;
    }

    //@audit-info => In the long run exists the possibility that this function will generate an index that has already been used to mint an NFT, but in the _mint() there is a validation in place to prevent re-assigning an index that has been already minted!
    function randomIndex() internal returns (uint) {
        uint totalSize = TOKEN_LIMIT - numTokens;
        uint index = uint(keccak256(abi.encodePacked(nonce, msg.sender, block.difficulty, block.timestamp))) % totalSize;
        uint value = 0;
        if (indices[index] != 0) {
            value = indices[index];
        } else {
            value = index;
        }
        if (indices[totalSize - 1] == 0) {
            indices[index] = totalSize - 1;
        } else {
            indices[index] = indices[totalSize - 1];
        }
        nonce += 1;
        return (value + 1);
    }

    // Calculate the mint price
    function getPrice() public view returns (uint) {
        require(publicSale, "Sale not started.");
        uint elapsed = block.timestamp - saleStartTime;
        if (elapsed > saleDuration) {
            return 0;
        } else {
            return ((saleDuration - elapsed) * price) / saleDuration;
        }
    }
    
    // SALE_LIMIT is 1337 
    // Rest i.e. (TOKEN_LIMIT - SALE_LIMIT) are reserved for community distribution (not shown)
    //@audit-info => As soon as the NFT is minted, the received ETH will be sent to the beneficiary address, this means that the ETH balance of this contract will always be reset to 0 after a new NFT is minted!
    function mint() external payable returns (uint) {
        require(publicSale, "Sale not started.");
        require(numSales < SALE_LIMIT, "Sale limit reached.");
        numSales++;
        //@audit-issue => After the sale timeperiod is passed, getPrice() will return 0 as the price to mint, and there is any validation to revert the transaction if the sale has passed the saleDuration!
        //@audit => Should be a mechanism to stop the minting once the saleDuration timestamp has been passed!
        uint salePrice = getPrice();
        //@audit-info => This function expects the user to send more ETH than whatever the getPrice() says it will cost to mint the NFT. The function will attempt to return back the different between how much ETH the user sent and how much it will cost to mint the NFT
        require((address(this)).balance >= salePrice, "Insufficient funds to purchase.");
        if ((address(this)).balance >= salePrice) {
            //@audit => transfer() is recommended to not be using anymore, instead use call{value:<value>}("")
            payable(msg.sender).transfer((address(this)).balance - salePrice);
        }
        return _mint(msg.sender);
    }

    // TOKEN_LIMIT is 13337
    //@audit => Missed to validate _to address is not the 0x address (To prevent the NFT from being burned :))
    function _mint(address _to) internal returns (uint) {
        require(numTokens < TOKEN_LIMIT, "Token limit reached.");
        // Lower indexed/numbered NFTs have rare traits and may be considered
        // as more valuable by buyers => Therefore randomize
        uint id = randomIndex();
        if (isContract(_to)) {
            //@audit => If the called contract is a malitious contract could execute a reentrancy attack when the onERC721Received() is called!
                                                    //onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);
            bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(msg.sender, address(0), id, "");
            require(retval == MAGIC_ERC721_RECEIVED);
        }
        //@audit-info => This check makes sure to not re-assing an NFT in case the randomIndex() generates an index that has been already minted!
        require(idToOwner[id] == address(0), "Cannot add, already owned.");
        idToOwner[id] = _to;
        numTokens = numTokens + 1;
        //@audit => transfer() is recommended to not be using anymore, instead use call{value:<value>}("")
        beneficiary.transfer((address(this)).balance);
        return id;
    }
}