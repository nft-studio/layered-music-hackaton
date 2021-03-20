pragma solidity ^0.5.0;

import "./ERC721Tradable.sol";
import './Authorizations.sol';
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title LayeredMusic
 * LayeredMusic
 */
contract LayeredMusic is ERC721Tradable {

    // Authorization feature
    bool USE_AUTHORED_USERS = true;
    using Authorizations for Authorizations.Addresses;
    Authorizations.Addresses trustedMinters;

    // Unique feature
    mapping (string => address) private _absoluteHashes;

    constructor(address _proxyRegistryAddress)
        public
        ERC721Tradable("Layered Music Track", "LMT", _proxyRegistryAddress)
    {}

    function baseTokenURI() public pure returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }

    function contractURI() public pure returns (string memory) {
        return "https://ipfs.io/ipfs/QmeccJSPZdWf5kVrmegUL41frH5ynmbzdh5uLAjDEyHpFp";
    }

    function trackExists(string memory tokenHash) internal view returns (bool) {
        address owner = _absoluteHashes[tokenHash];
        return owner != address(0);
    }

    function ownerTrack(string memory hash) public view returns (address) {
        return _absoluteHashes[hash];
    }

    function trackCounts(string memory hash) public view returns (uint256) {
        return returnTokenId();
    }

    function canMint(string memory tokenURI, uint amount) internal returns (bool){
        if(USE_AUTHORED_USERS){
            require(trustedMinters.exists(msg.sender), 'The sender address is not registered as a Minter');
        }
        require(!trackExists(tokenURI), "LayeredMusic: Trying to mint existent track");
        return true;
    }

    function mintTrack(string memory tokenURI) public returns (uint256) {
        require(canMint(tokenURI, 1), "LayeredMusic: Can't mint token");
        uint256 tokenId = mintTo(msg.sender, tokenURI);
        _absoluteHashes[tokenURI] = msg.sender;
        return tokenId;
    }

    function rewardTrack(address account, string memory tokenURI) public returns (uint256) {
        require(canMint(tokenURI, 1), "LayeredMusic: Can't mint token");
        uint256 tokenId = mintTo(account, tokenURI);
        _absoluteHashes[tokenURI] = msg.sender;
        return tokenId;
    }

    function addMinter(address minter) public onlyOwner {
        trustedMinters.pushAddress(minter);
    }

    function removeMinter(address minter) public onlyOwner {
        trustedMinters.removeAddress(minter);
    }

    function createRandomSeed(uint256 timestamp) public view returns (bytes32) {
        bytes32 seed = 
            keccak256(
                abi.encodePacked(
                    timestamp + 
                    uint256(
                        keccak256(abi.encodePacked(msg.sender))
                    ) +
                    block.timestamp +
                    block.difficulty +
                        ((
                            uint256(
                                keccak256(abi.encodePacked(block.coinbase))
                            )
                        ) / (block.timestamp)) +
                        block.gaslimit +
                        ((
                            uint256(keccak256(abi.encodePacked(msg.sender)))
                        ) / (block.timestamp)) +
                        block.number
                )
        );

        return seed;
    }
}
