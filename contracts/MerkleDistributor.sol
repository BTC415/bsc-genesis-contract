pragma solidity 0.6.4;

import "./interface/IBEP20.sol";
import "./interface/ITokenHub.sol";
import "./interface/IMerkleDistributor.sol";
import "./lib/SafeMath.sol";
import "./System.sol";
import "./MerkleProof.sol";

contract MerkleDistributor is IMerkleDistributor, System {
    using SafeMath for uint256;

    string public constant sourceChainID = "Binance-Chain-Tigris"; // TODO: replace with the real chain id
    address public constant approvalAddress = 0xaAaAaAaaAaAaAaaAaAAAAAAAAaaaAaAaAaaAaaAa; // TODO: replace with the real address
    bytes32 public constant override merkleRoot = 0xad4aa415f872123b71db5d447df6bb417fa72c6a41737a82fdb5665e3edaa7c3; // TODO: replace with the real merkle root

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

    struct ClaimInfo {
        bytes32 node;
        uint256 index;
        address contractAddr;
    }

    function isClaimed(uint256 index) public view override returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }


    function claim(bytes32 tokenSymbol, uint256 amount, bytes calldata prefixNode, bytes calldata suffixNode, bytes calldata ownerSignature, bytes calldata approvalSignature, bytes32[] calldata merkleProof) external override {
        ClaimInfo memory claimInfo;
        claimInfo.node = keccak256(abi.encodePacked(prefixNode, tokenSymbol, amount, suffixNode));
        claimInfo.index = uint256(keccak256(abi.encodePacked(tokenSymbol, claimInfo.node)));
    
        // Check if the token is claimed.
        require(isClaimed(claimInfo.index), "AlreadyClaimed");

        // Check if the token is exist.
        claimInfo.contractAddr = _checkTokenContractExist(tokenSymbol);

        // Verify the approval signature.
        _verifySignature(tokenSymbol, msg.sender, ownerSignature, approvalSignature, claimInfo.node);
    
        // Verify the merkle proof.
        require(MerkleProof.verify(merkleProof, merkleRoot, claimInfo.node), "InvalidProof");

        // Check balance of the contract. make sure Tokenhub has enough balance.
        require(IBEP20(claimInfo.contractAddr).balanceOf(TOKEN_HUB_ADDR) >= amount, "InsufficientBalance");

        // Mark it claimed and send the token.
        _setClaimed(claimInfo.index);
    
        // Unlock the token from TokenHub.
        ITokenHub(TOKEN_HUB_ADDR).unlock(claimInfo.contractAddr, msg.sender, amount);

        emit Claimed(tokenSymbol, msg.sender, amount);
    }

    function registerToken(bytes32 tokenSymbol, address contractAddr, uint256 decimals, uint256 amount, bytes calldata ownerSignature, bytes calldata approvalSignature) external override {
         // Check if the token is exist.
        _checkTokenContractExist(tokenSymbol);

        // Verify the approval signature.
        _verifySignature(tokenSymbol, msg.sender, ownerSignature, approvalSignature, bytes32(amount));

        // Check balance of the contract. make sure Tokenhub has enough balance.
        require(IBEP20(contractAddr).balanceOf(TOKEN_HUB_ADDR) >= amount, "InsufficientBalance");

        // Bind the token to TokenHub.
        ITokenHub(TOKEN_HUB_ADDR).bindToken(tokenSymbol, contractAddr, decimals);
    }

    function _verifySignature(bytes32 tokenSymbol, address account, bytes memory ownerSignature, bytes memory approvalSignature, bytes32 node) private pure {
        // Ensure the account is not the zero address
        require(account != address(0), "InvalidSignature");

        // Ensure the signature length is correct
        require(approvalSignature.length == 65, "InvalidSignature");
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(approvalSignature, 32))
            s := mload(add(approvalSignature, 64))
            v := byte(0, mload(add(approvalSignature, 96)))
        }
        if (v < 27) v += 27;
        require(v == 27 || v == 28, "InvalidSignature");

        // Perform the approvalSignature recovery and ensure the recovered signer is the approval account
        bytes32 hash = keccak256(abi.encodePacked(sourceChainID, tokenSymbol, account, ownerSignature, node));
        require(ecrecover(hash, v, r, s) == approvalAddress, "InvalidSignature");
    }

    function _checkTokenContractExist(bytes32 tokenSymbol) private view returns (address) {
        address contractAddr = ITokenHub(TOKEN_HUB_ADDR).getContractAddrByBEP2Symbol(tokenSymbol);
        require(contractAddr != address(0x00), "InvalidSymbol");

        return contractAddr;
    }
}