pragma solidity 0.6.4;

import "./interface/IBEP20.sol";
import "./interface/ITokenHub.sol";
import "./interface/IAirDrop.sol";
import "./interface/IParamSubscriber.sol";
import "./lib/SafeMath.sol";
import "./lib/BytesToTypes.sol";
import "./System.sol";
import "./MerkleProof.sol";

contract AirDrop is IAirDrop, IParamSubscriber, System {
    using SafeMath for uint256;

    string public constant sourceChainID = "Binance-Chain-Ganges";
    address public approvalAddress = 0xaAaAaAaaAaAaAaaAaAAAAAAAAaaaAaAaAaaAaaAa;
    bytes32 public override merkleRoot = 0x0000000000000000000000000000000000000000000000000000000000000000;
    bool public merkleRootAlreadyInit = false;

    // This is a packed array of booleans.
    mapping(bytes32 => bool) private claimedMap;

    function isClaimed(bytes32 node) public view override returns (bool) {
        return claimedMap[node];
    }

    function claim(
        uint256 tokenIndex, bytes32 tokenSymbol, uint256 amount,
        bytes calldata ownerPubKey, bytes calldata ownerSignature, bytes calldata approvalSignature,
        bytes32[] calldata merkleProof) external override {
        // Recover the owner address and check signature.
        bytes memory ownerAddr = _verifyTMSignature(ownerPubKey, ownerSignature, _tmSignarueHash(tokenIndex, tokenSymbol, amount, msg.sender));
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
        _verifySignature(msg.sender, ownerSignature, approvalSignature, node, merkleProof);
    
        // Verify the merkle proof.
        require(MerkleProof.verify(merkleProof, merkleRoot, node), "InvalidProof");
    
        // Unlock the token from TokenHub.
        ITokenHub(TOKEN_HUB_ADDR).unlock(contractAddr, msg.sender, amount);

        // Mark it claimed and send the token.
        claimedMap[node] = true;

        emit Claimed(tokenSymbol, msg.sender, amount);
    }

    function _verifySignature(address account, bytes memory ownerSignature, bytes memory approvalSignature, bytes32 leafHash, bytes32[] memory merkleProof) private view {
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

        bytes memory buffer;
        for (uint i = 0; i < merkleProof.length; i++) {
            buffer = abi.encodePacked(buffer, merkleProof[i]);
        }
        // Perform the approvalSignature recovery and ensure the recovered signer is the approval account
        bytes32 hash = keccak256(abi.encodePacked(sourceChainID, account, ownerSignature, leafHash, merkleRoot, buffer));
        require(ecrecover(hash, v, r, s) == approvalAddress, "InvalidSignature");
    }

    function _checkTokenContractExist(bytes32 tokenSymbol) private view returns (address) {
        address contractAddr = ITokenHub(TOKEN_HUB_ADDR).getContractAddrByBEP2Symbol(tokenSymbol);
        require(contractAddr != address(0x00), "InvalidSymbol");

        return contractAddr;
    }

    function _verifyTMSignature(bytes memory pubKey, bytes memory signature, bytes32 messageHash) internal view returns (bytes memory) {
        // Ensure the public key is valid
        require(pubKey.length == 33, "Invalid pubKey length");
        // Ensure the signature length is correct
        require(signature.length == 64, "Invalid signature length");

        // assemble input data
        bytes memory input = new bytes(129);
        _bytesConcat(input, pubKey, 0, 33);
        _bytesConcat(input, signature, 33, 64);
        _bytesConcat(input, _bytes32toBytes(messageHash), 97, 32);


        bytes memory output = new bytes(20);
        /* solium-disable-next-line */
        assembly {
          // call tmSignatureRecover precompile contract
          // Contract address: 0x69
          let len := mload(input)
          if iszero(staticcall(not(0), 0x69, input, len, output, 20)) {
            revert(0, 0)
          }
        }
        
        // return the recovered address
        return output;
    }

    function _bytesConcat(bytes memory data, bytes memory _bytes, uint256 index, uint256 len) internal pure {
        for (uint i; i<len; ++i) {
          data[index++] = _bytes[i];
        }
    }

    function _bytes32toBytes(bytes32 _data) public pure returns (bytes memory) {
        return abi.encodePacked(_data);
    }

    function _tmSignarueHash(
        uint256 tokenIndex,
        bytes32 tokenSymbol,
        uint256 amount,
        address recipient
    ) internal pure returns (bytes32) {
        return sha256(abi.encodePacked(
            '{"account_number":"0","chain_id":"',
            sourceChainID,
            '","data":null,"memo":"","msgs":[{"amount":"',
            _bytesToHex(abi.encodePacked(amount), false),
            '","recipient":"',
            _bytesToHex(abi.encodePacked(recipient), true),
            '","token_index":"',
            _bytesToHex(abi.encodePacked(tokenIndex), false),
            '","token_symbol":"',
            _bytesToHex(abi.encodePacked(tokenSymbol), false),
            '"}],"sequence":"0","source":"0"}'
        ));
    }

    function _bytesToHex(bytes memory buffer, bool prefix) public pure returns (string memory) {
        // Fixed buffer size for hexadecimal convertion
        bytes memory converted = new bytes(buffer.length * 2);

        bytes memory _base = "0123456789abcdef";

        for (uint256 i = 0; i < buffer.length; i++) {
            converted[i * 2] = _base[uint8(buffer[i]) / _base.length];
            converted[i * 2 + 1] = _base[uint8(buffer[i]) % _base.length];
        }

        if (prefix) {
            return string(abi.encodePacked('0x',converted));
        }
        return string(converted);
    }

    /*********************** Param update ********************************/
    function updateParam(string calldata key, bytes calldata value) external override onlyInit onlyGov{
      if (Memory.compareStrings(key,"approvalAddress")) {
        require(value.length == 20, "length of approvalAddress mismatch");
        address newApprovalAddress = BytesToTypes.bytesToAddress(20, value);
        require(newApprovalAddress != address(0), "approvalAddress should not be zero");
        approvalAddress = newApprovalAddress;
      } else if (Memory.compareStrings(key,"merkleRoot")) {
        require(!merkleRootAlreadyInit, "merkleRoot already init");
        require(value.length == 32, "length of merkleRoot mismatch");
        bytes32 newMerkleRoot = 0;
        BytesToTypes.bytesToBytes32(32 ,value, newMerkleRoot);
        require(newMerkleRoot != bytes32(0), "merkleRoot should not be zero");
        merkleRoot = newMerkleRoot;
        merkleRootAlreadyInit = true;
      } else {
        require(false, "unknown param");
      }
      emit paramChange(key,value);
    }
}