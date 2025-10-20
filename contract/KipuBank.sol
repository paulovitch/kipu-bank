// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// == ERRORS ==

error WithdrawCapZero();
error BankCapZero();
error CapAboveBankCap();
error AmountZero();
error BankCapExceeded();
error ExceedsPerTxCap();
error InsufficientBalance();
error EtherTransferFailed();
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


contract KipuBank {

// == STATE VARIABLES ==
/// @notice Per-transaction withdraw cap (in wei), immutable after deployment.
uint256 public immutable withdrawPerTxCap;

/// @notice Global bank cap (in wei), immutable after deployment.
uint256 public immutable bankCap;

/// @dev Total amount of ETH vaulted across all users.
uint256 private _totalVaulted;

/// @dev Total number of successful deposits.
uint256 private _depositsCount;

/// @dev Total number of successful withdrawals.
uint256 private _withdrawsCount;

/// @dev Mapping of user address to their balance.
mapping(address => uint256) private _balances;

// == CONSTRUCTOR ==

/// @param _withdrawPerTxCap Per-transaction withdraw cap (wei).
/// @param _bankCap Global bank cap (wei).

constructor(uint256 _withdrawPerTxCap, uint256 _bankCap){
    if (_withdrawPerTxCap == 0) revert WithdrawCapZero();
    if (_bankCap == 0) revert BankCapZero();
    if (_withdrawPerTxCap > _bankCap)revert CapAboveBankCap();

    withdrawPerTxCap = _withdrawPerTxCap;
    bankCap = _bankCap;
}

// == EXTERNAL/PUBLIC FUNCTIONS ==

/// @notice Deposit ETH into your personal vault.
/// @dev Uses CEI: checks -> effects; no external interactions.
/// Emits a Deposited event on success.

function deposit() external payable {

    // CHECKS
    if (msg.value == 0) revert AmountZero();

    uint256 projected = _totalVaulted + msg.value;
    if (projected > bankCap) revert BankCapExceeded();

    // EFFECTS (cache y una sola escritura)
    address sender = msg.sender;
    uint256 newBal = _balances[sender] + msg.value;
    _balances[sender] = newBal;
    _totalVaulted = projected;
    unchecked { _depositsCount += 1; }

    // EVENT
    emit Deposited(sender, msg.value, newBal);
}

/// @notice Withdraw ETH from your personal vault, respecting the per-tx cap.
/// @param amount Amount to withdraw in wei.
/// @dev Follows CEI: checks -> effects -> interactions.
/// Emits a Withdrawn event on success.

function withdraw(uint256 amount) external {

    // CHECKS
    if (amount == 0) revert AmountZero();
    if (amount > withdrawPerTxCap) revert ExceedsPerTxCap();

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

// == INTERNAL/PRIVATE FUNCTIONS ==

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


