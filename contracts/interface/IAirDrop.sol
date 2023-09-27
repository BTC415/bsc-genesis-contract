pragma solidity 0.6.4;

// Allows anyone to claim a token if they exist in a Beacon Chain.
interface IAirDrop {
    // Returns the merkle root of the merkle tree containing account balances available to claim.
    function merkleRoot() external view returns (bytes32);
    // Returns true if the index has been marked claimed.
    function isClaimed(bytes32 index) external view returns (bool);
    // Claim the given amount of the token to the given address. Reverts if the inputs are invalid.
    function claim(uint256 tokenIndex, bytes32 tokenSymbol, uint256 amount,
        bytes calldata ownerPubKey, bytes calldata ownerSignature, bytes calldata approvalSignature,
        bytes32[] calldata merkleProof) external;
    // This event is triggered whenever a call to #claim succeeds.
    event Claimed(bytes32 tokenSymbol, address account, uint256 amount);
}
