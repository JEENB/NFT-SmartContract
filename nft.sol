// SPDX-License-Identifier: MIT

// NFT_metadata and image stored in IPFS
// 1) Use setAddress to set the address of the ashoka_alumn.sol contract in vm(0xd9145CCE52D386f254917e481eB44e9943F39138)
    // address in ropsten: 0xbF4E94111b7923a8553Da7C6E32b0112887eD680
// 2) Use safemint to mint(deploy) nfts address should be the owner of the contract and uri must be link.
        // uri: ipfs://QmU6g2zYBTxm2G1JpkBNL5Z72z6qB1SYZVpiK4ryaJbdi5
        // nft_metadata:  https://ipfs.io/ipfs/QmU6g2zYBTxm2G1JpkBNL5Z72z6qB1SYZVpiK4ryaJbdi5?filename=ashoka_nft.json
        // image: https://ipfs.io/ipfs/QmZxg7ji1Z2bX9MuHsXRMQajGaEo6vd1iUgtvRN1cUmzM9?filename=ashoka-bckgd.jpg

// 3) For selling first the owner must approve the nfts for transfer. 
    // Use setApprovalForAll and use the owner's address to assign approved: true and operator: <approval_address>
        //** For VM testing address of approval =>**
        // => addresses for approval
        // 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB
        // 0x583031D1113aD414F02576BD6afaBfb302140225
        // 0xdD870fA1b7C4700F2BD7f44238821C26f7392148
        // 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C non ashoka user
        //**                                       **
// 4) Once the above addresses are approved, these addresses can put in buy requests.
//      use buy and give in the nft id

// ** Other Userful functions  **
// changePrice(nftid): To change the price of a NFT must be the owner of nft. 
// getConractBalance: to get the balance of contract only for owner of contract.
// withdraw: to transfer eth from contract to contract owner's address. 
// getprince(nftid): gives the price of the nft
// getowner(nftid): gives the owner of the nft

// NOTE: If and address wants to but nft the user must check if the address is approved to buy that nft. 
// If not contact the user to approve the request. 



//boilerplate from https://wizard.openzeppelin.com/#erc721
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./ashoka_alumn.sol";


contract MyAshokaNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    uint256 public mintPrice = 0.1 ether;
    address alumnContract;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("MyAshokaNFT", "MTK") {}

    mapping(uint256 => address) private ownerDict;

    mapping(uint256 => uint256) private priceDict;


    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    // end The following functions are overrides required by Solidity end.

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        ownerDict[tokenId] = msg.sender;
        priceDict[tokenId] = mintPrice;
    }

    function changePrice(uint256 _price, uint256 NFTID) public{
        require(ownerDict[NFTID] == msg.sender, "Cannot Change Price: Owner required");
        priceDict[NFTID] = _price;
    }

    function getOwner(uint256 NFTID)
    public view returns(address){
        return(ownerDict[NFTID]);
    }

    function getPrice(uint256 NFTID)
    public view returns(uint256){
        return(priceDict[NFTID]);
    }

    function setAddress(address _alumnContractAddr)
    external onlyOwner{
        alumnContract = _alumnContractAddr;
    }

    function buy(uint256 NFTID)
    public payable returns(string memory){
        require(msg.value > priceDict[NFTID], "Lower Price");
        address prevOwner = ownerDict[NFTID];
        ashokaAlumn c = ashokaAlumn(alumnContract);
        require(c.isAlumn(msg.sender) == true, "Cannot buy NFT not an alumn");
        transferFrom(prevOwner, msg.sender, NFTID); //using the safeTransferFrom 
        ownerDict[NFTID] = msg.sender;
        priceDict[NFTID] = msg.value;
        uint256 comission = 2;

        // will transfer some eth to previous owner and deducts the comission   
        payable(prevOwner).transfer(msg.value-(msg.value*comission)/100);
        return("You OWN A NFT");
    }

    function withdraw() public onlyOwner{
        require(address(this).balance > 0, "Balance is 0");
        payable(owner()).transfer(address(this).balance);
    }

    // function getContractBalance() private onlyOwner returns(uint256){
    //     return(address(this).balance);
    // }


}
