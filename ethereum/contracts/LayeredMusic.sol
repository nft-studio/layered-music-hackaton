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
    mapping (string => uint256) private _maxTracks;
    mapping (string => address) private _productions;
    mapping (string => uint256) private _mintedTracks;
    mapping (string => uint256) private _paidTracks;
    mapping (string => uint256) private _mintingCosts;

    // Payable minting features
    // uint256 mintingCost = 50 finney;
    uint256 platformFee = 15;
    mapping (address => mapping(string => uint256)) private _buyedMintings;
    mapping (string => uint256) private _soldTracks;

    constructor(address _proxyRegistryAddress)
        public
        ERC721Tradable("Layered Music Track", "LMT", _proxyRegistryAddress)
    {}

    function baseTokenURI() public pure returns (string memory) {
        return "https://layeredmusic.nftstud.io/api/";
    }

    function contractURI() public pure returns (string memory) {
        return "https://layeredmusic.nftstud.io/api/details.json";
    }

    // Existence functions

    function trackExists(string memory tokenURI) internal view returns (bool) {
        address owner = _absoluteHashes[tokenURI];
        return owner != address(0);
    }

    function ownerTrack(string memory hash) public view returns (address) {
        return _absoluteHashes[hash];
    }

    function productionOwner(string memory hash) public view returns (address) {
        return _productions[hash];
    }

    function ownedTracks() public view returns (string[] memory) {
        return _creators[msg.sender];
    }

    function totalTrackCounts() public view returns (uint256) {
        return returnTokenId();
    }

    function mintedTracksCount(string memory production) public view returns (uint256) {
        return _mintedTracks[production];
    }

    function soldTracksCount(string memory production) public view returns (uint256) {
        return _soldTracks[production];
    }

    // Minting functions

    function canMint(string memory tokenURI) internal returns (bool){
        require(!trackExists(tokenURI), "LayeredMusic: Trying to mint existent track");
        return true;
    }

    function mintTrack(string memory tokenSequence, string memory production) public returns (uint256) {
        require(productionExists(production), "LayeredMusic: Production doesn\'t exists");
        string memory tokenURI = string(abi.encodePacked(production,tokenSequence));
        require(_mintedTracks[production] < _maxTracks[production], "LayeredMusic: Max tracks reached");
        require(canMint(tokenURI), "LayeredMusic: Can't mint track");
        require(_buyedMintings[msg.sender][production] > 0, "LayeredMusic: Didn't bought any minting");
        uint256 tokenId = mintTo(msg.sender, tokenURI);
        _absoluteHashes[tokenURI] = msg.sender;
        _creators[msg.sender].push(tokenURI);
        _mintedTracks[production]++;
        _buyedMintings[msg.sender][production]--;
        return tokenId;
    }

    function rewardTrack(address account, string memory tokenURI) public returns (uint256) {
        require(canMint(tokenURI), "LayeredMusic: Can't mint token");
        uint256 tokenId = mintTo(account, tokenURI);
        _absoluteHashes[tokenURI] = msg.sender;
        return tokenId;
    }

    // Production functions

    function productionExists(string memory production) internal view returns (bool) {
        address owner = _productions[production];
        return owner != address(0);
    }

    function addProduction(string memory production, uint256 max, address producerAddress, uint256 mintingCost) public onlyOwner {
        require(!productionExists(production), "LayeredMusic: Production exists yet");
        _productions[production] = producerAddress;
        _maxTracks[production] = max;
        _mintingCosts[production] = mintingCost;
        _mintedTracks[production] = 0;
    }

    // Payment functions

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function buyMinting(string memory production) public payable {
        require(productionExists(production), "LayeredMusic: Production doesn\'t exists");
        require(_soldTracks[production] < _maxTracks[production], "LayeredMusic: Max tracks reached");
        uint256 mintingCost = _mintingCosts[production];
        require(msg.value % mintingCost == 0, 'LayeredMusic: Amount should be a multiple of minting cost');
        uint256 amount = msg.value / mintingCost;
        _buyedMintings[msg.sender][production] += amount;
        _soldTracks[production] += amount;
    }

    function balanceOfMinting(string memory production) public view returns (uint256) {
        return _buyedMintings[msg.sender][production];
    }

    function withdrawEther() public onlyOwner {
        require(address(this).balance > 0, 'LayeredMusic: Nothing to withdraw!');
        msg.sender.transfer(address(this).balance);
    }

    function rewardProducer(string memory production) public onlyOwner {
        require(address(this).balance > 0, 'LayeredMusic: Nothing to withdraw!');
        uint256 minted = _mintedTracks[production];
        uint256 topay = _mintedTracks[production] - _paidTracks[production];
        require(topay > 0, 'LayeredMusic: Nothing to pay!');
        uint256 platformFeeValue = _mintingCosts[production] / 100 * platformFee;
        uint256 reward = ( _mintingCosts[production] - platformFeeValue ) * topay;
        uint256 fee = platformFee * topay;
        address payable producerAddress = address(uint160(_productions[production]));
        msg.sender.transfer(fee);
        producerAddress.transfer(reward);
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
