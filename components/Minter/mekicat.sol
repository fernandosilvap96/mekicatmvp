// SPDX-License-Identifier: MIT
 
pragma solidity ^0.8.2;
 
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
 
contract MekiCats is ERC721URIStorage, Ownable, ERC721Enumerable {
   using Strings for uint256;
   using Counters for Counters.Counter;
 
   // readyNFTs Starts at 0
   // [] readyNFTs Veryfied with cli
   uint256 public readyNFTs = 0;
   // [] maxSupply Veryfied with cli
   uint256 public maxSupply = 10000;
   // [] cost Veryfied with cli
   uint256 public cost = 0.01 ether;
   // [] maxMintAmount Veryfied with cli
   uint256 public maxMintAmount = 1000;
   // [] baseURI initialized empty
   string public baseURI = "ipfs://QmNMubsXoJhy4DUna45uGHpdzbkDCKG8CXiS9X3XgP3GQb/";
   string public baseExtension = ".json";
   // [] isSaleActive Veryfied with cli
   bool public isSaleActive = true;
 
   constructor(address _newOwner) ERC721("MekiCats Test", "MCT") {
       // [] client address (owner) Set
       transferOwnership(_newOwner);
   }
 
   // PUBLIC FUNCTIONS:
 
   // PAYABLE MINT FUNCTION
   // [] Must mint random tokenIds in a pretty simple way
   //  => IDEAS?
   mapping(uint256 => string) tokenURIs;
 
   //MINT BY OWNER => MINTA ONLY FOR OWNER
   function mintByOwner(uint256 _mintAmount) public payable {
       uint256 supply = totalSupply();
 
       // 5 <= 10000 - 100 => readyNFTs cannot be set as a value 0 nor less than supply
       // 1000 <= 100 - 0 => There are not enough NFTs yet
       // 100 <= 100 - 0 => Mint 100
       // 100 <= 100 - 1 => There are not enough NFTs yet
       // 1 <= 10000 - 10000
       require(isSaleActive, "Sale is not active");
       require(_mintAmount > 0, "Need to mint more than zero");
       require(
           supply + _mintAmount <= maxSupply,
           "There are not NFTs available to mint anymore"
       );
       require(
           _mintAmount <= readyNFTs - supply,
           "There are not enough NFTs ready to mint at the moment. Try again later!"
       );
       require(
           _mintAmount <= maxMintAmount,
           "Exceeds Maximum Mint Amount per Transaction"
       );
 
       // if (msg.sender != owner()) {
       //     require(msg.value >= cost * _mintAmount, "Payment insufficient");
       // }
 
       //INTEGRANDO...
       for (uint256 i = 1; i <= _mintAmount; i++) {
       _mint(owner(), supply+i);
       tokenURIs[supply+i] = string(
                   abi.encodePacked(
                       //IPFS://hash/1.json
                       baseURI,
                       supply+i,
                       baseExtension
                   )
               );  
       }
   }
 
   //MINT BY USERS => MINTA FOR THE CALLER
   function mintByUsers(uint256 _mintAmount) public payable {
       uint256 supply = totalSupply();
 
       require(isSaleActive, "Sale is not active");
       require(_mintAmount > 0, "Need to mint more than zero");
       require(
           supply + _mintAmount <= maxSupply,
           "There are not NFTs available to mint anymore"
       );
       require(
           _mintAmount <= readyNFTs - supply,
           "There are not enough NFTs ready to mint at the moment. Try again later!"
       );
       require(
           _mintAmount <= maxMintAmount,
           "Exceeds Maximum Mint Amount per Transaction"
       );
 
       //DAPP => LER O COST => COST * MINTamount
 
       if (msg.sender != owner()) {
            require(msg.value >= cost * _mintAmount, "Payment insufficient");
       }
 
       //INTEGRANDO...
       for (uint256 i = 1; i <= _mintAmount; i++) {
       _mint(msg.sender, supply+i);
       uint256 tok = supply + i;
       tokenURIs[supply+i] = string(
           //tokenURIs[1] =
                   abi.encodePacked(
                       baseURI,
                       tok.toString(),
                       baseExtension
                   )
               );  
       }
   }
 
   function setReadyNFTs(uint256 _newReadyNFTs, string memory _newBaseURI) public onlyOwner {
       // supply = 0
       // _newReadyNFTs = 100
       require(
           _newReadyNFTs > 0 && _newReadyNFTs >= totalSupply(),
           "Must be more than zero and greater or equal to current supply"
       );
       readyNFTs = _newReadyNFTs;
       baseURI = _newBaseURI;
   }
 
   function setBaseURI(string memory _newBaseURI) public onlyOwner {
       baseURI = _newBaseURI;
   }
 
   function tokenURI(uint256 tokenId)
   public
   view
   virtual
   override(ERC721, ERC721URIStorage)
   returns (string memory)
   {
       return tokenURIs[tokenId];
       //tokenURIs[1]
   }
 
   // INTERNAL FUNCTIONS:
 
   function _baseURI() internal view virtual override returns (string memory) {
       return baseURI;
   }
 
   function _cost() internal view returns (uint256) {
       return cost;
   }
 
   // ONLY OWNER FUNCTIONS:
 
   function flipSaleStatus() public onlyOwner {
       isSaleActive = !isSaleActive;
   }
 
   function setCost(uint256 _newCost) public onlyOwner {
       require(_newCost >= 0, "Should be greater or equal than zero");
       cost = _newCost;
   }
 
   function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
       require(_newmaxMintAmount > 0, "Should be greater than zero");
       maxMintAmount = _newmaxMintAmount;
   }
 
   //setBaseExtension deleted
 
   // [] Withdraw Tested
   function withdraw() public payable onlyOwner {
       (bool os, ) = payable(owner()).call{value: address(this).balance}("");
       require(os);
   }
 
   // FUNCTIONS are overrides required by Solidity.
 
   function _beforeTokenTransfer(
       address from,
       address to,
       uint256 tokenId
   ) internal override(ERC721, ERC721Enumerable) {
       super._beforeTokenTransfer(from, to, tokenId);
   }
 
   function supportsInterface(bytes4 interfaceId)
       public
       view
       override(ERC721, ERC721Enumerable)
       returns (bool)
   {
       return super.supportsInterface(interfaceId);
   }
 
   function _burn(uint256 tokenId)
       internal
       override(ERC721, ERC721URIStorage)
       onlyOwner
   {
       super._burn(tokenId);
   }
}
