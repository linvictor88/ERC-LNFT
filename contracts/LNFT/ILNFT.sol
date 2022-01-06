//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

import "../SFT/ISFT.sol";
import "../SFT/ISFTMetadata.sol";

interface ILNFT is ISFT, ISFTMetadata, IERC721Metadata {

    /**
        @dev this emits when `_value` of new license type are minted.
     */
    event LicenseTypeMinted(address indexed _operator, address indexed _to, uint256 indexed _licenseType, uint256 _value, string _licensorName, string _desc, string _licenseName, string _licenseSymbol, bytes _data);

    /**
        @notice get the license issuer name who is the Licensor.
     */
	function licensorName(uint256 _licenseType) external view returns (string memory);

    /**
        @notice get the license issuer address.
     */
	function licensorAddress(uint256 _licenseType) external view returns (address);

    /**
        @notice get the license type name and symbol
        license name call {ISFTMetadata-semiName}
        license symbol call {ISFTMetadata-semiSymbol}
     */

	/**
        @notice a simple introduction of this licensing contract purpose, use and some notices.
     */
	function description(uint256 _licenseType) external view returns (string memory);

    /**
        @notice The license agreement URI of `_licenseType` license.
        call {ISFTMetadata-semiURI}
      */
	function agreementURI(uint256 _licenseType) external view returns (string memory);

	/**
		@notice create `_value` of new type of licenses
        @dev the caller would be the Licensor
        @dev only Licensor can do already minted `_licenseType` metadata change.
        call {ISFT-semiTypeMint}
	*/
	function licenseTypeMint(address _to, uint256 _licenseType, uint256 _value, string calldata _licensorName, string calldata _desc, string calldata _licenseName, string calldata _licenseSymbol, bytes calldata _data) external;

    /**
        @notice assign one new license from `_from` to `_to`
        call {ISFT-semiMint}
     */
	function licenseMint(address _from, address _to, uint256 _licenseType, bool _active, bytes calldata _data) external;

    /**
        @notice get the license type of `_licenseId`.
     */
    function licenseType(uint256 _licenseId) external view returns (uint256 _licenseType);

	/**
		@notice activate/deactivate one license.
		@dev the caller must be approved to do this operation
	 */
	function setActive(uint256 _licenseId, bool _active) external;

    /**
        @notice check the license is activated.
     */
	function isActive(uint256 _licenseId) external view returns (bool);

    /**
        @notice check the license is valid for use.
     */
	function isValid(uint256 _licenseId) external view returns (bool);

    /**
        @notice validate _owner is the owner of `_licenseId` and `_licenseId` is valid. 
     */
    function validate(address _owner, uint256 _licenseId) external view returns (bool);

    /**
        @notice get license expired time with timestamp in seconds.
        2**256 -1 means inifinite
     */
	function expireOn(uint256 _licenseId) external view returns (uint256);

    /*
        @notice Get license metadata URI.
        call {IERC721Metadata-tokenURI}
        {
	    	license_type: _licenseType
	    	licensor_name: The entity issued the license who is the Licensor name
            licensor_address: The Licensor address who first minted the new `_licenseType` licenses
	    	vendor_address: The entity sold the product to Licensee
            is_valid: true/false,
            is_active: true/false,
            factory_time: Licensor first created this type of license (timestamp in seconds).
	    	issue_time: time when this type of license is minted to Licensee (timestamp in seconds).
	    	expire_time: time when license is expired (seconds in timestamp).
	    }
     */
    function licenseURI(uint256 _licenseId) external view returns (string memory);
}
