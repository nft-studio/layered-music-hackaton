pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
import "./ERC721Tradable.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title LayeredMusic
 * LayeredMusic
 */
contract LayeredMusic is ERC721Tradable {

    // Unique feature
    mapping (string => address) private _absoluteHashes;
    mapping (address => string[]) private _creators;

    // Payable minting features
    uint256 mintingCost = 50 finney;
    mapping (address => uint256) private _buyedMintings;

    constructor(address _proxyRegistryAddress)
        public
        ERC721Tradable("Layered Music Track", "LMT", _proxyRegistryAddress)
    {}

    function baseTokenURI() public pure returns (string memory) {
        return "https://layeredmusic.nftstud.io/api/";
    }

    function contractURI() public pure returns (string memory) {
        return "https://raw.githubusercontent.com/Nft-Studio/layered-music-hackaton/master/ethereum/details.json";
    }

    // Existence functions

    function trackExists(string memory tokenHash) internal view returns (bool) {
        address owner = _absoluteHashes[tokenHash];
        return owner != address(0);
    }

    function ownerTrack(string memory hash) public view returns (address) {
        return _absoluteHashes[hash];
    }

    function ownedTracks() public view returns (string[] memory) {
        return _creators[msg.sender];
    }

    function trackCounts() public view returns (uint256) {
        return returnTokenId();
    }

    // Minting functions

    function canMint(string memory tokenURI) internal returns (bool){
        require(_buyedMintings[msg.sender] > 0, 'The sender address didn\'t buyed any minting');
        require(!trackExists(tokenURI), "LayeredMusic: Trying to mint existent track");
        return true;
    }

    function mintTrack(string memory tokenURI) public returns (uint256) {
        require(canMint(tokenURI), "LayeredMusic: Can't mint token");
        uint256 tokenId = mintTo(msg.sender, tokenURI);
        _absoluteHashes[tokenURI] = msg.sender;
        _creators[msg.sender].push(tokenURI);
        _buyedMintings[msg.sender]--;
        return tokenId;
    }

    function rewardTrack(address account, string memory tokenURI) public returns (uint256) {
        require(canMint(tokenURI), "LayeredMusic: Can't mint token");
        uint256 tokenId = mintTo(account, tokenURI);
        _absoluteHashes[tokenURI] = msg.sender;
        return tokenId;
    }

    // Payment functions

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function buyMinting() public payable {
        require(msg.value % mintingCost == 0, 'LayeredMusic: Amount should be a multiple of 0.05 ETH');
        uint256 amount = msg.value / mintingCost;
        _buyedMintings[msg.sender] += amount;
    }

    function balanceOfMinting() public view returns (uint256) {
        return _buyedMintings[msg.sender];
    }

    function withdrawEther() public onlyOwner {
        require(address(this).balance > 0, 'LayeredMusic: Nothing to withdraw!');
        msg.sender.transfer(address(this).balance);
    }

    // Random functions
    
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
