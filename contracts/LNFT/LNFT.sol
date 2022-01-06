// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "../SFT/SFT.sol";
import "../SFT/ISFTMetadata.sol";
import "./ILNFT.sol";

contract LNFT is ILNFT, SFT {
    using Address for address;
    using Strings for uint256;

    struct licenseTypeMeta {
        address licensor_address;
        string  licensor_name;
        string  name;
        string  symbol;
        string  description;
        uint256 mint_time;
    }

    struct licenseMeta {
        uint256 license_type;
        uint256 issue_time;
        address vendor_address;
        uint256 expire_time;
        bool    is_active;
    }

    // infinite timestamp
    uint256 public TIME_INFINITE = type(uint256).max;

    // Mapping from _licenseType to type metadata.
    mapping(uint256 => licenseTypeMeta) private _licenseTypeDatas;

    // Mapping from _licenseId to license metadata.
    mapping(uint256 => licenseMeta) private _licenseDatas;

    function _licenseTypeExists(uint256 _licenseType) internal virtual returns (bool) {
        return licensorAddress(_licenseType) != address(0);
    }

    function _licenseExists(uint256 _licenseId)  internal view virtual returns (bool) {
        return _licenseDatas[_licenseId].issue_time > 0;
    }

    constructor(string memory name_, string memory symbol_) SFT(name_, symbol_) {
    }

    function licensorAddress(uint256 _licenseType) public view virtual override returns (address) {
        return _licenseTypeDatas[_licenseType].licensor_address;
    }

    function licensorName(uint256 _licenseType) public view virtual override returns (string memory) {
        return _licenseTypeDatas[_licenseType].licensor_name;
    }

    function semiName(uint256 _licenseType) public view virtual override(ISFTMetadata, SFT) returns (string memory) {
        return _licenseTypeDatas[_licenseType].name;
    }

    function semiSymbol(uint256 _licenseType) public view virtual override(ISFTMetadata, SFT) returns (string memory) {
        return _licenseTypeDatas[_licenseType].symbol;
    }

    function description(uint256 _licenseType) public view virtual override returns (string memory) {
        return _licenseTypeDatas[_licenseType].description;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(SFT, IERC165) returns (bool) {
        return
            interfaceId == type(ILNFT).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _isSemiTypeMintApproved(address _operator, address, uint256 _licenseType, uint256, bytes memory) internal virtual override returns (bool) {
        return
            _licenseTypeExists(_licenseType) &&
            _operator == licensorAddress(_licenseType);
    }

    function agreementURI(uint256 _licenseType) public view virtual override returns (string memory) {
        return semiURI(_licenseType);
    }

    function _licenseTypeBeforeMint(address _operator, address, uint256 _licenseType, uint256,
                                string memory, string memory, string memory, string memory, bytes memory) internal virtual {
        if (_licenseTypeExists(_licenseType)) {
            require (_operator == licensorAddress(_licenseType), "LNFT: licenseTypeMint caller is not the owner");
        } else {
            licenseTypeMeta storage _typeMeta = _licenseTypeDatas[_licenseType];
            _typeMeta.licensor_address = _operator;
            _typeMeta.mint_time = block.timestamp;
        }
    }

    function _licenseTypeAfterMint(address _operator, address _to, uint256 _licenseType, uint256 _value,
                                string memory _licensorName, string memory _desc, string memory _licenseName, string memory _licenseSymbol, bytes memory _data) internal virtual {
        licenseTypeMeta storage _typeMeta = _licenseTypeDatas[_licenseType];
        if (bytes(_licensorName).length > 0) {
            _typeMeta.licensor_name = _licensorName;
        }
        if (bytes(_desc).length > 0) {
            _typeMeta.description = _desc;
        }
        if (bytes(_licenseName).length > 0) {
            _typeMeta.name = _licenseName;
        }
        if (bytes(_licenseSymbol).length > 0) {
            _typeMeta.symbol = _licenseSymbol;
        }

        emit LicenseTypeMinted(_operator, _to, _licenseType, _value, _licensorName, _desc, _licenseName, _licenseSymbol, _data);
    }

	function licenseTypeMint(address _to, uint256 _licenseType, uint256 _value, string memory _licensorName, string memory _desc, string memory _licenseName, string memory _licenseSymbol, bytes memory _data) public virtual override {
        address _operator = _msgSender();
        _licenseTypeBeforeMint(_operator, _to, _licenseType, _value, _licensorName, _desc, _licenseName, _licenseSymbol, _data);
        semiTypeMint(_to, _licenseType, _value, _data);
        _licenseTypeAfterMint(_operator, _to, _licenseType, _value, _licensorName, _desc, _licenseName, _licenseSymbol, _data);
    }

    function _isSemiMintApproved(address, address, address, uint256 _licenseType, uint256 _licenseId, bytes memory) internal virtual override returns (bool) {
        return
            _licenseExists(_licenseId) &&
            _licenseDatas[_licenseId].license_type == _licenseType;
    }

    function _licenseBeforeMint(address, address, uint256 _licenseType, uint256 _licenseId, bool, bytes memory) public virtual {
        licenseMeta storage _meta = _licenseDatas[_licenseId];
        _meta.license_type = _licenseType;
        _meta.issue_time = block.timestamp;
    }

    function _setExpireTime(uint256, uint256 _licenseId, uint256 time, bytes memory) internal virtual {
        _licenseDatas[_licenseId].expire_time = time;
    }

    function _licenseAfterMint(address _from, address, uint256 _licenseType, uint256 _licenseId, bool _active, bytes memory _data) public virtual {
        licenseMeta storage _meta = _licenseDatas[_licenseId];
        _meta.vendor_address = _from;
        _setExpireTime(_licenseType, _licenseId, TIME_INFINITE, _data);
        _meta.is_active = _active;
    }

    function licenseMint(address _from, address _to, uint256 _licenseType, bool _active, bytes memory _data) public virtual override {
        uint256 _licenseId = _getNftId();
        _licenseBeforeMint(_from, _to, _licenseType, _licenseId, _active, _data);
        semiMint(_from, _to, _licenseType, _data);
        _licenseAfterMint(_from, _to, _licenseType, _licenseId, _active, _data);
    }

    function licenseType(uint256 _licenseId) public view virtual override returns (uint256) {
        require(_licenseExists(_licenseId), "LNFT: _licenseId should exist");
        return _licenseDatas[_licenseId].license_type;
    }

    function expireOn(uint256 _licenseId) public view virtual override returns (uint256) {
        require(_licenseExists(_licenseId), "LNFT: _licenseId should exist");
        return _licenseDatas[_licenseId].expire_time;
    }

    function _isExpired(uint256 _licenseId) internal view virtual returns (bool) {
        require(_licenseExists(_licenseId), "LNFT: _licenseId should exist");
        return expireOn(_licenseId) <= block.timestamp;
    }

    function setActive(uint256 _licenseId, bool _active) public virtual override {
        require(_licenseExists(_licenseId), "LNFT: _licenseId should exist");
        require(_isApprovedOrOwner(_msgSender(), _licenseId),
                "LNFT: caller is not owner nor approved");
        _licenseDatas[_licenseId].is_active = _active;
    }

    function isActive(uint256 _licenseId) public view virtual override returns (bool) {
        require(_licenseExists(_licenseId), "LNFT: _licenseId should exist");
        return _licenseDatas[_licenseId].is_active;
    }

    function isValid(uint256 _licenseId) public view virtual override returns (bool) {
        return
            isActive(_licenseId) &&
            !_isExpired(_licenseId);
    }

    function validate(address _owner, uint256 _licenseId) public view virtual override returns (bool) {
        return
            ownerOf(_licenseId) == _owner &&
            isValid(_licenseId);
    }

    function licenseURI(uint256 _licenseId) public view virtual override returns (string memory) {
        return tokenURI(_licenseId);
    }
}
