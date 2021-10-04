// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LipToken is ERC721, Ownable {
  constructor(string memory _name, string memory _symbol) // Name and ticker symbol of NFT's
    ERC721(_name, _symbol)
  {}

  uint256 COUNTER; // init counter to keep track of amount of NFT's created

  uint256 fee = 0.01 ether; // Fee to create a new NFT

  struct Lip { // NFT Attributes (this can be metadata on a cloud platform)
    string name;
    uint256 id;
    uint256 dna;
    uint8 level;
    uint8 rarity;
  }

  Lip[] public lips; // Array to hold all NFT's. // A mapping of account address => Lip struct would be more gas efficient for some functions

  event NewLip(address indexed owner, uint256 id, uint256 dna); // Event to emit after a new lip is created

  // Helpers
  function _createRandomNum(uint256 _mod) internal view returns (uint256) { // Function to create semi-random numbers
    uint256 randomNum = uint256(
      keccak256(abi.encodePacked(block.timestamp, msg.sender))
    );
    return randomNum % _mod;
  }

  function updateFee(uint256 _fee) external onlyOwner() { // Setter function to set the creation fee
    fee = _fee;
  }

  function withdraw() external payable onlyOwner() { // Function to withdraw contracts eth holdings
    address payable _owner = payable(owner());
    _owner.transfer(address(this).balance);
  }

  // Creation
  function _createLip(string memory _name) internal { // internal function to be called by another function
    uint8 randRarity = uint8(_createRandomNum(100)); // Random rarity
    uint256 randDna = _createRandomNum(10**16); // random dna
    Lip memory newLip = Lip(_name, COUNTER, randDna, 1, randRarity); // New lip using the struct created above
    lips.push(newLip); // Push created lip to lips array
    _safeMint(msg.sender, COUNTER); // mint a new NFT with inherited function
    emit NewLip(msg.sender, COUNTER, randDna); // emit an event that a new NFT was created
    COUNTER++; // increment counter
  }

  function createRandomLip(string memory _name) public payable { // Function that is called by front end
    require(msg.value >= fee); // Require the creation payment
    _createLip(_name); // Call internal function
  }

  // Getters
  function getLips() public view returns (Lip[] memory) { // Return the array of created lips
    return lips;
  }

  function getOwnerLips(address _owner) public view returns (Lip[] memory) { // Function to return all lips of an owner
    Lip[] memory result = new Lip[](balanceOf(_owner)); // Create array with length == balanceOf(_owner) (Length of all the owners NFTs)
    uint256 counter = 0;
    for (uint256 i = 0; i < lips.length; i++) { // For loops are gas expensive so mappings would be better to use in the future
      if (ownerOf(i) == _owner) { // If owner owns this lip index
        result[counter] = lips[i]; // Push NFT to array to return
        counter++;
      }
    }
    return result; // Return array of owners NFT's
  }

  // Actions
  function levelUp(uint256 _lipId) public { // Function to level up lips
    require(ownerOf(_lipId) == msg.sender); // Require the NFT is owned by the sender // Could add a requirement of experience points or amount traded
    Lip storage lip = lips[_lipId]; // Get the lip from the lips array
    lip.level++; // Increment the lips levelUp
  }
}
