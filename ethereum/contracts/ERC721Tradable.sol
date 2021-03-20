pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

/**
 * @title ERC721Tradable
 * ERC721Tradable - ERC721 contract that whitelists a trading address, and has minting functionality.
 */
contract ERC721Tradable is ERC721Full, Ownable {

    address proxyRegistryAddress;
    uint256 private _currentTokenId = 0;

    constructor(
        string memory _name,
        string memory _symbol,
        address _proxyRegistryAddress
    ) public ERC721Full(_name, _symbol) {
        proxyRegistryAddress = _proxyRegistryAddress;
        _setBaseURI("https://layeredmusic.nftstud.io/api/");
    }

    /**
     * @dev Mints a token to an address with a tokenURI.
     * @param _to address of the future owner of the token
     */
    function mintTo(address _to, string memory _tokenURI) public returns (uint256){
        uint256 newTokenId = _getNextTokenId();
        _mint(_to, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
        _incrementTokenId();
        return newTokenId;
    }

    /**
     * @dev Burns a token.
     * @param _tokenId existing tokenId
     */
    function burnToken(uint256 _tokenId) public returns (bool){
        _burn(msg.sender, _tokenId);
        return true;
    }

    /**
     * @dev get the last _currentTokenId
     */
    function returnTokenId() public view returns (uint256) {
        return _currentTokenId;
    }

    /**
     * @dev calculates the next token ID based on value of _currentTokenId
     * @return uint256 for the next token ID
     */
    function _getNextTokenId() private view returns (uint256) {
        return _currentTokenId.add(1);
    }

    /**
     * @dev increments the value of _currentTokenId
     */
    function _incrementTokenId() private {
        _currentTokenId++;
    }

    /**
     * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        returns (bool)
    {
        // Whitelist OpenSea proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }
}
