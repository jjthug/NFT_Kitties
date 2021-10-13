//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./IERC721.sol";
import "./Ownable.sol";
import "./IERC721Receiver.sol";


import "hardhat/console.sol";

contract Kittycontract is IERC721, Ownable {
    string public constant name = "JJKitties";
    string public constant symbol = "JJT";

    bytes4 internal constant ERC721_RECEIVED_CONSTANT = bytes4(keccak256(abi.encodePacked("onERC721Received(address,address,uint256,bytes")));
    
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd; // not verified
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7; // not verified

    event Birth(address owner,
                uint256 kittenId,
                uint256 _mumId,
                uint256 _dadId,
                uint256 _generation,
                uint256 _genes
                );

    struct Kitty{
        uint256 genes;
        uint64 birthTime;
        uint32 mumId;
        uint32 dadId;
        uint16 generation;
    }

    mapping (uint256 => address) approvals;
    mapping (address => mapping(address => bool)) allApprovals; // approved to use all assets of an address

    Kitty[] kitties;

    mapping (uint256 => address) public kittyIndextoOwner;
    mapping(address => uint256) ownershipTokenCount;
    uint256 gen0Counter;
    uint256 constant CREATION_LIMIT_GEN0 = 100;

    function createKittyGen0(uint256 _genes) public onlyOwner returns(uint256){
        require(gen0Counter < CREATION_LIMIT_GEN0);
        gen0Counter++;

        return createKitty(0, 0, 0, _genes, msg.sender);


    }

    function createKitty(uint256 _mumId,
                        uint256 _dadId,
                        uint256 _generation,
                        uint256 _genes,
                        address owner) public returns(uint256){
        require(owner != address(0));
        Kitty memory _kitty = Kitty(_genes, uint64(block.timestamp), uint32(_mumId), uint32(_dadId), uint16(_generation));
        kitties.push(_kitty);
        uint256 newKittyId = kitties.length;

            emit Birth(address(0),
                 newKittyId,
                 _mumId,
                 _dadId,
                 _generation,
                 _genes
                );

        kittyIndextoOwner[newKittyId] = owner;     
        return newKittyId;

    }

    function getKitty(uint256 _id) internal view returns (
        uint256 genes,
        uint256 birthTime,
        uint256 mumId,
        uint256 dadId,        
        address owner,
        uint256 generation

    ) {
        Kitty storage kitty = kitties[_id];
        genes = kitty.genes;
        birthTime = uint256(kitty.birthTime);
        mumId = uint256(kitty.mumId);
        dadId = uint256(kitty.dadId);
        generation = uint256(kitty.generation);
        owner = kittyIndextoOwner[_id];
    }

    function balanceOf(address owner) external view returns (uint256 balance){
        return ownershipTokenCount[owner];
    }

    function ownerOf(uint256 tokenId) external view returns (address owner){
        return kittyIndextoOwner[tokenId];
    }

    function _transfer(address from, address to, uint256 tokenId) internal{
        kittyIndextoOwner[tokenId] = to;
        ownershipTokenCount[from]--;
        approvals[tokenId] = address(0);

        emit Transfer( from,  to, tokenId);
    }

    function transferFrom(
    address from,
    address to,
    uint256 tokenId
    ) external{
        require(from != address(0) && to != address(0));
        require(kittyIndextoOwner[tokenId] == from);
        if(msg.sender != from){
            require(approvals[tokenId] == msg.sender);
        }

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
    ) external{
        require(from != address(0) && to != address(0));
        require(kittyIndextoOwner[tokenId] == from);
        if(msg.sender != from){
            require(approvals[tokenId] == msg.sender);
        }

        require(true); //* - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
        
        _safeTransfer(from, to, tokenId, "");

    }

    function _checkERC721Support(address from, address to, uint256 tokenId, bytes4 data) internal returns(bool) {
        if(!isContract(to)){
            return true;
        }
        bytes4 returnData = bytes4(IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data));
        return returnData == ERC721_RECEIVED_CONSTANT; // compare the hashes
    }

    function _safeTransfer(address from, address to, uint tokenId, bytes4 data) internal {

        _transfer(from, to, tokenId);
        _checkERC721Support(from, to, tokenId, data);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external{
        require(from != address(0) && to != address(0));
        require(kittyIndextoOwner[tokenId] == from);
        if(msg.sender != from){
            require(approvals[tokenId] == msg.sender);
        }

        require(true); //* - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.

        _safeTransfer(from, to, tokenId, bytes4(data));

        require(_checkERC721Support(from, to, tokenId, bytes4(data)));

    }

    function approve(address to, uint256 tokenId) external{
        require(kittyIndextoOwner[tokenId] == msg.sender);
        
        emit Approval(msg.sender, to, tokenId);
    }

    function getApproved(uint256 tokenId) external view returns (address operator){
        return approvals[tokenId];
    }

    function setApprovalForAll(address operator, bool _approved) external{
        allApprovals[msg.sender][operator] = true;

        emit ApprovalForAll(msg.sender, operator, _approved);

    }

    function isApprovedForAll(address owner, address operator) external view returns (bool){
        if(allApprovals[owner][operator])
        return true;

        return false;
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool){
        return(interfaceId == _INTERFACE_ID_ERC721 || interfaceId == _INTERFACE_ID_ERC165);
    }

    function isContract(address _addr) private returns (bool isContract){
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function _breed (uint256 _dadId, uint256 _mumId) public returns(uint256){
        require(kittyIndextoOwner[_dadId] == msg.sender);
        require(kittyIndextoOwner[_mumId] == msg.sender);
        (uint256 dadDna,,,,,uint256 DadGeneration) = getKitty(_dadId);
        (uint256 mumDna,,,,,uint256 MumGeneration) = getKitty(_dadId);

        uint256 newDna = _mixDna(dadDna, mumDna);

        uint256 kidGen = 0;

        if(DadGeneration > MumGeneration) {
            kidGen = DadGeneration + 1;
            kidGen /= 2;
        }
        else if (MumGeneration > DadGeneration){
            kidGen = MumGeneration + 1;
            kidGen /= 2;
        }
        else {
            kidGen = MumGeneration + 1;
        }

        createKitty (_mumId, _dadId, kidGen, newDna, msg.sender); 






        
    }

    function _mixDna (uint256 _dadDna, uint256 _mumDna) internal returns(uint256){
        uint256[4] memory geneArray;

        uint8 random = uint8(block.timestamp % 255); // gameable, not safe
        uint256 i;
        uint256 result;
        uint256 index = 3;

        for( i=1; i<=128 ; i=i*2){
            if(i & random !=0){
                geneArray[index] = uint8(_mumDna%100);
            }
            else{
                geneArray[index] = uint8(_dadDna%100);
            }

            _mumDna = _mumDna/100;
            _dadDna = _dadDna/100;

            index--;
        }

        uint256 newGene;
        for(i=1; i<=3 ; i++){
            newGene = newGene + geneArray[i];

            if(i != 7 ){
                newGene = newGene * 100;
            }

        }

        return newGene;


    }

}