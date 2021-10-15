pragma solidity ^0.8.0;
import "./Kittycontract.sol";
import "./IKittyMarketPlace.sol";

contract KittyMarketPlace is IKittyMarketPlace{

    Kittycontract private _kittyContract;

    struct Offer{
        address payable seller;
        uint256 price;
        uint256 index;
        uint256 tokenId;
        bool active;
    }

    mapping (uint256 => Offer) tokenIdToOffer;

    Offer[] offers;

    constructor(address _kittyContractAddress) {
        setKittyContract(_kittyContractAddress);
    }
    function setKittyContract(address _kittyContractAddress) public{
        _kittyContract = Kittycontract(_kittyContractAddress);
    }

    function getOffer(uint256 _tokenId) external view returns ( address seller, uint256 price, uint256 index, uint256 tokenId, bool active){
        Offer storage offer = tokenIdToOffer[_tokenId];
        return (
            offer.seller,
            offer.price,
            offer.index,
            offer.tokenId,
            offer.active
        );
    }

    function getAllTokenOnSale() external view returns(uint256[] memory listOfOffers){
        uint256 length = offers.length;

        if(length == 0)
            return new uint256[](0);

        uint256[] memory result = new uint256[](length);

        uint256 offerId;

        for(offerId = 0; offerId < length; offerId++){
            if(offers[offerId].active == true )
                result[offerId] = offers[offerId].tokenId;
        }    

        return result;
    }

    function _ownsKitty(address _address, uint256 _tokenId) internal view returns(bool) {
        return (_kittyContract.ownerOf(_tokenId) == _address);
    }

    function setOffer(uint256 _price, uint256 _tokenId) external{
        require(_ownsKitty(msg.sender, _tokenId));
        require(tokenIdToOffer[_tokenId].active == false, "can set offer on cat multiple times");
        require(_kittyContract.isApprovedForAll(msg.sender, address(this)));

        Offer memory _offer = Offer({seller: payable(msg.sender), 
                                    price : _price,
                                    active: true,
                                    tokenId: _tokenId,
                                    index: offers.length});

        tokenIdToOffer[_tokenId] = _offer;

        offers.push(_offer);
        
        emit MarketTransaction("Create Offer", msg.sender, _tokenId);
    }

    function removeOffer(uint256 _tokenId) external{
        require(msg.sender == tokenIdToOffer[_tokenId].seller);
        tokenIdToOffer[_tokenId].active = false;
    }

    function buyKitty(uint256 _tokenId) external payable{
        Offer memory offer = tokenIdToOffer[_tokenId];
        require(msg.value == offer.price, "Incorrect price");
        require(offer.active == true, "No active order present");

        delete tokenIdToOffer[_tokenId];
        offers[offer.index].active = false;
        
        //Transfer funds to seller
        if(offer.price > 0){
            (bool success, bytes memory data) = offer.seller.call{value: offer.price}("");
            require(success);
        }

        //Transfer ownership of kitty
        _kittyContract.transferFrom(offer.seller, msg.sender, _tokenId);

        emit MarketTransaction("Buy", msg.sender, _tokenId);
    }

}