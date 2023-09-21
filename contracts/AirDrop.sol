pragma solidity 0.6.4;

import "./interface/IBEP20.sol";
import "./interface/ITokenHub.sol";
import "./interface/IAirDrop.sol";
import "./lib/SafeMath.sol";
import "./System.sol";
import "./MerkleProof.sol";

contract AirDrop is IAirDrop, System {
    using SafeMath for uint256;

    string public constant sourceChainID = "Binance-Chain-Tigris"; // TODO: replace with the real chain id
    address public constant approvalAddress = 0xaAaAaAaaAaAaAaaAaAAAAAAAAaaaAaAaAaaAaaAa; // TODO: replace with the real address
    bytes32 public constant override merkleRoot = 0xad4aa415f872123b71db5d447df6bb417fa72c6a41737a82fdb5665e3edaa7c3; // TODO: replace with the real merkle root

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

    function isClaimed(bytes32 node) public view override returns (bool) {
        uint256 index = uint256(node);
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(bytes32 node) private {
        uint256 index = uint256(node);
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }


    function claim(uint256 tokenIndex, bytes32 tokenSymbol, uint256 amount, bytes calldata ownerSignature, bytes calldata approvalSignature, bytes32[] calldata merkleProof) external override {
        // Recover the owner address and check signature.
        address ownerAddr = _verifyTMSignature(ownerSignature, keccak256(abi.encodePacked(sourceChainID, tokenSymbol, tokenIndex, amount, msg.sender)));
        // Generate the leaf node of merkle tree.
        bytes32 node = keccak256(abi.encodePacked(ownerAddr, tokenIndex, tokenSymbol ,amount));
    
        // Check if the token is claimed.
        require(isClaimed(node), "AlreadyClaimed");

        address contractAddr = address(0x00);
        // Check if the token is exist.
        if (tokenSymbol != "BNB") {
            contractAddr = _checkTokenContractExist(tokenSymbol);
        }
        
        // Verify the approval signature.
        _verifySignature(msg.sender, ownerSignature, approvalSignature, node);
    
        // Verify the merkle proof.
        require(MerkleProof.verify(merkleProof, merkleRoot, node), "InvalidProof");

        // Check balance of the contract. make sure Tokenhub has enough balance.
        if (tokenSymbol != "BNB") {
            require(IBEP20(contractAddr).balanceOf(TOKEN_HUB_ADDR) >= amount, "InsufficientBalance");
        }else{
            require(address(System.TOKEN_HUB_ADDR).balance >= amount, "InsufficientBalance");
        }
        
        // Mark it claimed and send the token.
        _setClaimed(node);
    
        // Unlock the token from TokenHub.
        ITokenHub(TOKEN_HUB_ADDR).unlock(contractAddr, msg.sender, amount);

        emit Claimed(tokenSymbol, msg.sender, amount);
    }

    function _verifySignature(address account, bytes memory ownerSignature, bytes memory approvalSignature, bytes32 extra) private pure {
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
        bytes32 hash = keccak256(abi.encodePacked(sourceChainID, account, ownerSignature, extra));
        require(ecrecover(hash, v, r, s) == approvalAddress, "InvalidSignature");
    }

    function _checkTokenContractExist(bytes32 tokenSymbol) private view returns (address) {
        address contractAddr = ITokenHub(TOKEN_HUB_ADDR).getContractAddrByBEP2Symbol(tokenSymbol);
        require(contractAddr != address(0x00), "InvalidSymbol");

        return contractAddr;
    }

    function _verifyTMSignature(bytes memory signature, bytes32 messageHash) internal pure returns (address) {
        // Ensure the signature length is correct
        require(signature.length == 65, "Invalid compact signature length");

        // TODO: implement it in precompile contract
        messageHash = 0;
        
        // Additional validation or usage of publicKey here
        return address(0x00);
    }
}