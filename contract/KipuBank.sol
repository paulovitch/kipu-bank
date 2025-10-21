// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title kipubank
/// @notice ETH vault with per-transaction withdraw cap and a global deposit cap.
/// @dev Demonstrates custom errors, CEI, modifiers, least-privilege state and NatSpec.


// == ERRORS ==

/// @notice Thrown when per-transaction withdraw cap is zero at deployment.
error WithdrawCapZero();

/// @notice Thrown when bankCap is zero at deployment.
error BankCapZero();

/// @notice Thrown when withdrawPerTxCap exceeds bankCap.
error CapAboveBankCap();

/// @notice Thrown when the provided amount/value equals zero.
error AmountZero();

/// @notice Thrown when a deposit would exceed the global bank cap.
error BankCapExceeded();

/// @notice Thrown when a withdrawal exceeds the per-transaction cap.
error ExceedsPerTxCap();

/// @notice Thrown when a user tries to withdraw more than their balance.
error InsufficientBalance();

/// @notice Thrown when the native ETH transfer via call fails.
error EtherTransferFailed();

/// @notice Thrown when ETH is sent directly (receive/fallback). Use {deposit}.
error DirectEtherNotAllowed();



// == EVENTS ==

/// @notice Emitted on successful deposits.
/// @param user The depositor address.
/// @param amount Deposited amount in wei.
/// @param newUserBalance User balance after the deposit.

event Deposited(address indexed user, uint256 amount, uint256 newUserBalance);

/// @notice Emitted on successful withdrawals.
/// @param user The withdrawing address.
/// @param amount Withdrawn amount in wei.
/// @param newUserBalance User balance after the withdrawal.

event Withdrawn(address indexed user, uint256 amount, uint256 newUserBalance);

contract kipubank {

// == STATE VARIABLES ==
/// @notice Maximum amount allowed per single withdrawal (in wei). Immutable after deployment.
uint256 private immutable withdrawPerTxCap;

/// @notice Maximum total amount of ETH that can be deposited across all users (in wei). Immutable after deployment.
uint256 private immutable bankCap;

/// @dev Total ETH currently stored in all user vaults.
uint256 private _totalVaulted;

/// @dev Counter tracking total number of successful deposits.
uint256 private _depositsCount;

/// @dev Counter tracking total number of successful withdrawals.
uint256 private _withdrawsCount;

/// @dev Mapping storing each user's personal vault balance.
mapping(address => uint256) private _balances;

// == CONSTRUCTOR ==

/// @param _withdrawPerTxCap Per-transaction withdraw cap (wei).
/// @param _bankCap Global bank cap (wei).

constructor(uint256 _withdrawPerTxCap, uint256 _bankCap){
    if (_withdrawPerTxCap == 0) revert WithdrawCapZero();
    if (_bankCap == 0) revert BankCapZero();
    if (_withdrawPerTxCap > _bankCap) revert CapAboveBankCap();

    withdrawPerTxCap = _withdrawPerTxCap;
    bankCap = _bankCap;
}

// == EXTERNAL/PUBLIC FUNCTIONS ==

/// @notice Deposit ETH into your personal vault.
/// @dev Uses CEI: checks -> effects; no external interactions.
/// Emits a Deposited event on success.

function deposit() external payable nonZeroValue respectsBankCap(msg.value) {

    // CHECKS
    // EFFECTS 
    address sender = msg.sender;
    uint256 newBal = _balances[sender] + msg.value;
    _balances[sender] = newBal;
    _totalVaulted+= msg.value;
    _bumpDeposits();


    // EVENT
    emit Deposited(sender, msg.value, newBal);
}

/// @notice Withdraw ETH from your personal vault, respecting the per-tx cap.
/// @param amount Amount to withdraw in wei.
/// @dev Follows CEI: checks -> effects -> interactions.
/// Emits a Withdrawn event on success.

function withdraw(uint256 amount) external nonZeroAmount(amount) withinPerTxCap(amount) {

    // CHECKS

    address payable sender = payable(msg.sender);
    uint256 bal = _balances[sender];
    if (amount > bal) revert InsufficientBalance();

    // EFFECTS
    uint256 newBal = bal - amount;
    _balances[sender] = newBal;
    _totalVaulted -= amount;
    unchecked { _withdrawsCount += 1; }

    // INTERACTIONS
    (bool ok, ) = sender.call{value: amount}("");
    if (!ok) revert EtherTransferFailed();

    emit Withdrawn(sender, amount, newBal);
}

// == MODIFIERS ==
/// @dev Reverts if msg.value == 0.
modifier nonZeroValue() {
    if (msg.value == 0) revert AmountZero();
    _;
}

/// @dev Reverts if amount == 0.
modifier nonZeroAmount(uint256 amount) {
    if (amount == 0) revert AmountZero();
    _;
}

/// @dev Reverts if amount > withdrawPerTxCap.
modifier withinPerTxCap(uint256 amount) {
    if (amount > withdrawPerTxCap) revert ExceedsPerTxCap();
    _;
}

/// @dev Reverts if (current total + amount) would exceed bankCap.
modifier respectsBankCap(uint256 amount) {
    if (_totalVaulted + amount > bankCap) revert BankCapExceeded();
    _;
}


// == INTERNAL/PRIVATE FUNCTIONS ==
/// @dev Increments deposit counter (unchecked for gas).

function _bumpDeposits() private {
    unchecked { _depositsCount += 1; }
}


// == VIEW/PURE GETTERS ==
/// @notice Returns the current balance of a user.
function balanceOf(address user) external view returns (uint256) {
    return _balances[user];
}

/// @notice Returns the total vaulted ETH across all users.
function totalVaulted() external view returns (uint256) {
    return _totalVaulted;
}

/// @notice Returns the total number of successful deposits.
function totalDeposits() external view returns (uint256) {
    return _depositsCount;
}

/// @notice Returns the total number of successful withdrawals.
function totalWithdrawals() external view returns (uint256) {
    return _withdrawsCount;

}

/// @notice Returns the per-transaction withdraw cap (wei).
function getWithdrawPerTxCap() external view returns (uint256) {
    return withdrawPerTxCap;
}

/// @notice Returns the global bank cap (wei).
function getBankCap() external view returns (uint256) {
    return bankCap;
}

// == RECEIVE / FALLBACK ==
/// @notice Reject direct ETH transfers. Use {deposit}.
receive() external payable {
    revert DirectEtherNotAllowed();
}

/// @notice Reject unexpected calls or malformed calldata. Use {deposit}.
fallback() external payable {
    revert DirectEtherNotAllowed();
}


}

