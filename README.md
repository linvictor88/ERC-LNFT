---
eip: <to be assigned>
title: Licensing Non-Fungible Token (LNFT) Interface
description: LNFT is to manage licensing service contract and thus support proof-of-licensing transfer within a period
author: Bo Lin (@linvictor88), Frank Shen (@sdongsheng@vmware.com)
discussions-to:
status: Draft
type: Standards Track
category: ERC
created: 2021-12-22
requires (*optional): <EIP number(s)>
---

## Abstract
In Blockchain, we have NFT standard to find the ownership value of digital asset by transferring. This draft proposes Licensing NFT (LNFT) which can also be delivered to get the use value. Owners of NFT can monetize more by delivering use/perform/exhibition right. The goal is to guideline LNFT interface and relative basic behaviors definition for easy reading, analysis and future integration to LNFT trading platform.

This draft defines 4 roles in the licensing service: License, Licensor, Licensee, and License Web Service. Their definitions are as below:
1. License
    - License is an official permission or permit to do, use, or own something. For example, the license can be endowed to anything with meaningful value. We can wrap NFT to endow use-ability of this NFT to other people while keeping the owner-ship. We can endow CopyRight License on Smart Contract for codes copy-right announcement. We can also endow MemberShip License on Smart Contract as VIP for the dAPP use.
2. Licensor
    - The owner of one NFT, smart contract, software service or physical items. Licensor defines LNFT behavior including licensing category, use scope, licensing agreement and valid time period.
3. Licensee
    - Licensee is any business, organization, or individual that has been granted legal permission by another entity to engage in an activity.
4. License Web Service
    - Provide customized License service to Licensor. Licensor can create their License service to Licensee based on their needs.
    - After paying for one License, Licensee can get/activate/confirm/return the License
    - LWS is responsible for creating License Smart Contract, storing License information into Blockchain, and call Blockchain to create/get/activate/delete/transfer License
    - Licensee can directly pay local money and LWS will exchange the money with Blockchain coin, or LWS can provide online Blockchain wallet service.

## Motivation
Current NFT just grants ownership right in Blockchain, but there should be more scenarios referring to use-ship without changing the owner. Music NFT owner can sell the listen-right to listeners, Art NFT owner can approve the show-right to exhibition, Smart Contract owner can permit the codes copyright by defining the License right, and DApp owner can give more benefits to users who owns membership LNFT. Existing EIP-2615 tried to endow NFT with mortgage and rental functions by extending the NFT interfaces with renting and lending behavior. The extension is limited to the licensing scope which is not scalable. It is also difficult to implement the interface with existing NFT that will result in a total migration. Hence, licensing is taken as an attribute assigned with NFT instead of variety behavior. It's the LNFT owners who define specified licensing behavior and rules. Based on that, they can transfer the Licensing behavior easily like NFT. NFT standard doesn't do any change since LNFT tracks licensing value.

## Specification
The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in RFC 2119.

NOTES:
    - The following specifications use syntax from Solidity 0.8.0 (or above)

```javascript
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
```

## Rationale
Ethereum smart contracts can be used in purposes of license management such as issue/renew/revoke/track licenses. This will improve the efficiency of license government. Due to blockchain, the management process will be more transparent and thus be more fair to the end users. At meanwhile, ethereum blockchain can also protect the end users' privacy data. 

## Backwards Compatibility
All EIPs that introduce backwards incompatibilities must include a section describing these incompatibilities and their severity. The EIP must explain how the author proposes to deal with these incompatibilities. EIP submissions without a sufficient backwards compatibility treatise may be rejected outright.

## Test Cases
Test cases for an implementation are mandatory for EIPs that are affecting consensus changes.  If the test suite is too large to reasonably be included inline, then consider adding it as one or more files in `../assets/eip-####/`.

## Reference Implementation
An optional section that contains a reference/example implementation that people can use to assist in understanding or implementing this specification.  If the implementation is too large to reasonably be included inline, then consider adding it as one or more files in `../assets/eip-####/`.

## Security Considerations
All EIPs must contain a section that discusses the security implications/considerations relevant to the proposed change. Include information that might be important for security discussions, surfaces risks and can be used throughout the life cycle of the proposal. E.g. include security-relevant design decisions, concerns, important discussions, implementation-specific guidance and pitfalls, an outline of threats and risks and how they are being addressed. EIP submissions missing the "Security Considerations" section will be rejected. An EIP cannot proceed to status "Final" without a Security Considerations discussion deemed sufficient by the reviewers.

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
