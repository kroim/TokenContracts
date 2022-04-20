// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BCNFT is ERC721, Ownable {
    using SafeMath for uint256;

    string baseTokenURI;
    uint256 private _tokenIds = 0;

    struct Token {
        uint256 tokenId;
        address creator;
        address owner;
        string tokenURI;
        uint256 level;  // 1, 2, 3, 4, 5
    }
    struct Holder {
        uint256 index;
        bool exist;
    }
    struct OwnIDS {
        uint256 id;
        uint256 index;
        bool exist;
    }
    uint256 non = 999999999;
    address[] private holders;
    mapping(address=>Holder) private checkHolders;
    mapping(uint256 => Token) private tokens;
    mapping(address=>uint256) private _tokenBalance;
    mapping(address=>uint256[]) private _ownIds;
    mapping(address=>OwnIDS) private _ownIdsExist;

    constructor() ERC721("BSNFT Token", "BSNT") {}

    function getTokenLevel(uint256 _id) public view returns (uint256) {
        require(_id < _tokenIds, "Non exist token!");
        return tokens[_id].level;
    }

    function setBaseTokenURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function _updateOwnIds(address _account, uint256 _tokenId, uint256 _flag) internal {
        if (_flag == 1) {
            _ownIdsExist[_account].id = _tokenId;
            _ownIdsExist[_account].index = _ownIds[_account].length;
            _ownIdsExist[_account].exist = true;
            _ownIds[_account].push(_tokenId);
        } else {
            uint256 index = _ownIdsExist[_account].index;
            if (_ownIds[_account].length > 0) {
                _ownIds[_account][index] = _ownIds[_account][_ownIds[_account].length - 1];
            }
            _ownIds[_account].pop();
            _ownIdsExist[_account].index = non;
            _ownIdsExist[_account].exist = false;
        }
    }

    function updateHolders(address _account) internal {
        if (!checkHolders[_account].exist) {
            checkHolders[_account].index = holders.length;
            checkHolders[_account].exist = true;
            holders.push(_account);
        } else if (checkHolders[_account].exist && _tokenBalance[_account] == 0) {
            uint256 index = checkHolders[_account].index;
            holders[index] = holders[holders.length - 1];
            holders.pop();
            checkHolders[holders[index]].index = index;
            checkHolders[_account].index = non;
            checkHolders[_account].exist = false;
        }
    }

    function mintToken(uint256 _level, string memory _tokenURI) public returns (uint256) {
        uint256 curId = _tokenIds;
        _tokenIds ++;
        _tokenBalance[_msgSender()] += 1;
        Token storage newToken = tokens[curId];
        newToken.tokenId = curId;
        newToken.creator = _msgSender();
        newToken.owner = _msgSender();
        newToken.tokenURI = _tokenURI;
        newToken.level = _level;
        _safeMint(_msgSender(), curId);
        updateHolders(_msgSender());
        _updateOwnIds(_msgSender(), curId, 1);
        return curId;
    }

    function creatorOf(uint256 _tokenId) public view returns (address) {
        return tokens[_tokenId].creator;
    }

    function balanceOf(address account) public view virtual override returns(uint256) {
        return _tokenBalance[account];
    }

    function tokenURI(uint256 _tokenId) override public view returns (string memory) {
        require(_tokenId < _tokenIds, "ERC721Metadata: URI query for nonexistent token");
        return tokens[_tokenId].tokenURI;
    }

    function ownerOf(uint256 _tokenId) public view virtual override returns (address) {
        address owner = tokens[_tokenId].owner;
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function setTokenURI(uint256 _tokenId, string memory _tokenURI) public {
        require(_msgSender() == ownerOf(_tokenId), "Unable to set token URI");
        tokens[_tokenId].tokenURI = _tokenURI;
    }

    function _transfer(address from, address to, uint256 _tokenId) internal virtual override {
        // check token id is available
        require(_tokenId < _tokenIds, "Undefined tokenID!");
        // check owner of token
        require(ownerOf(_tokenId) == from, "Caller is not owner");
        require(to != address(0), "ERC721: transfer to the zero address");
        _beforeTokenTransfer(from, to, _tokenId);
        _approve(address(0), _tokenId);
        tokens[_tokenId].owner = to;
        _tokenBalance[from]--;
        _tokenBalance[to]++;
        updateHolders(from);
        _updateOwnIds(from, _tokenId, 2);
        updateHolders(to);
        _updateOwnIds(to, _tokenId, 1);
        emit Transfer(from, to, _tokenId);
    }

    function checkAccountLevel(address _account) external view returns (uint256) {
        uint256 level = 0;
        uint256[] memory ownIds = _ownIds[_account];
        bool level1 = false;
        bool level2 = false;
        bool level3 = false;
        bool level4 = false;
        bool level5 = false;
        for (uint256 i = 0; i < ownIds.length; i++) {
            if (tokens[ownIds[i]].level > level) {
                level = tokens[ownIds[i]].level;
            }
            if (tokens[ownIds[i]].level == 1) level1 = true;
            if (tokens[ownIds[i]].level == 2) level2 = true;
            if (tokens[ownIds[i]].level == 3) level3 = true;
            if (tokens[ownIds[i]].level == 4) level4 = true;
            if (tokens[ownIds[i]].level == 5) level5 = true;
        }
        if (level1 && level2 && level3 && level4 && level5) level = 6;
        return level;
    }

    function getHolders() external view returns (address[] memory) {
        return holders;
    }

    function checkNFTHolder(address _account) external view returns (bool) {
        return checkHolders[_account].exist;
    }
}
