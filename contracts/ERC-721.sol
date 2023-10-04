// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTFriend is ERC721, ERC721Enumerable, Pausable, Ownable {
    using Counters for Counters.Counter;

    uint256  maxSupply =3;

    bool publicMintOpen = false;
    bool allowlistMintOpen = false;

    mapping(address => bool)public allowlist;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("NFTFriend", "NFTF") {}


    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmY5rPqGTN1rZxMQg2ApiSZc7JiBNs1ryDzXPZpQhC1ibm/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // Edit mint window function for open or close
    function editMintWindow(
        bool _publicMintOpen, 
        bool _AllowlistOpen )
        external onlyOwner {
        publicMintOpen = _publicMintOpen;
        allowlistMintOpen = _AllowlistOpen;
     }

     //  populate the Allowlist mint
     function populateAllowList(
        address[] calldata addresses)
        external onlyOwner {
        for(uint i=0;i<addresses.length;i++){
            allowlist[addresses[i]]= true;
        }
     }

     // AllowList mint function
     function allowListMint() public payable {
       require(msg.value == 0.01 ether,"you have not enough funds");
       require(allowlistMintOpen,"AllowList mint is not open");
       require(allowlist[msg.sender],"you are not in allowlist");
       internalmint();
    }

    //public mint function
    function publicMint() public payable {
         require(msg.value == 0.1 ether,"you have not enough funds");
         require(publicMintOpen,"AllowList mint is not open");
       internalmint();
    }

    // withdraw Balance from contract
    function withdraw(address _addr)external onlyOwner{
        uint256 Balance = address(this).balance;
        payable (_addr).transfer(Balance);
    }

    function internalmint()internal{
        require(totalSupply() < maxSupply, "we are sold out");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);

    }
    
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}