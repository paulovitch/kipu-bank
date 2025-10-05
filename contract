// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract KipuBank {

/// @notice Se emite cuando un usuario depoista ETH con éxito. 
/// @param user Dirección del usuario que depositó.
/// @param amount Monto depositado (wei).
/// @param newUserBalance Balance del usuario luego del depósito.
event Deposited(address indexed user, uint256 amount, uint256 newUserBalance);

/// @notice Se emite cuando usuario retira ETH con éxito.
/// @param user Dirección del usuario que retiró 
/// @param amount Monto retirado (wei).
/// @param newUserBalance Balance del usuario luego del retiro. 
event Withdrawn(address indexed user, uint256 amount, uint256 newUserBalance);

/// Variables de estado - State Variables /// 

/// @notice Límite máximo permitido por retiro (en wei).
uint256 public immutable withdrawPerTxCap; 

/// @notice Límite global de depósitos del banco (en wei). 
uint public immutable bankCap;

constructor(uint256 _withdrawPerTxCap, uint256 _bankCap){
    require(_withdrawPerTxCap > 0, "cap=0");
    require(_bankCap > 0, "bankCap=0");
    require(_withdrawPerTxCap <= _bankCap, "cap>bankCap");

    withdrawPerTxCap = _withdrawPerTxCap;
    bankCap = _bankCap;
}

/// @notice Depositá ETH a tu bóveda personal. 
/// @dev Enviar un 'Value' > 0 en la transacción. 
function deposit() external payable {
    
    //Checks 
    require(msg.value > 0, "amount=0");

    uint256 projected = totalVaulted + msg.value;
    require(projected <= bankCap, "bankCap exceeded");

    //Effects
    balances[msg.sender] += msg.value;
    totalVaulted = projected;
    _incrementDepositCount();

    //Interactions N.A.

    //Event
    emit Deposited(msg.sender, msg.value, balances[msg.sender]);
}
    //Private helper
function _incrementDepositCount() private {
        totalDepositsCount +=1;
    }

/// @notice Retirá ETH de tu bóveda respetanod el límite máximo por transacción
/// @param amount Monto a retirar en wei
function withdraw(uint256 amount) external {

    //Checks
    require(amount > 0, "amount=0");
    require(amount <= withdrawPerTxCap,"exceeds per transaction cap");

    uint userBal = balances[msg.sender];
    require(amount <= userBal, "insufficient balance");

    //Effects (actualizar estados antes de interactura)
    balances[msg.sender]=userBal - amount;
    totalVaulted -= amount;
    totalWithdrawsCount += 1;

    // Interactions (transferencia segura)
    (bool ok, ) = payable(msg.sender).call{value: amount}("");
    require(ok, "native transfer failed");

    //Events
    emit Withdrawn(msg.sender, amount, balances[msg.sender]);

}

/// @notice Devuelve el balance del usuario consultado
/// @param user Dirección a consultar.
/// @return balance Balance actual en wei. 

function balanceOf(address user) external view returns (uint256 balance){
    balance = balances[user];
}

/// @notice Rechaza ETH enviados directamente. Usa deposit(). 
receive() external payable {
    revert("use deposit()");
}

/// @notice Rechaza llamadas no esperadas o datos mal formateados 
fallback() external payable { 
    revert("use deposit()");
}

/// @notice Suma total de ETH depositado por todos los usuarios 
uint256 public totalVaulted;

/// @notice Número total de depósitos exitosos registrados. 
uint256 public totalDepositsCount; 

/// @notice Número total de retiros exitosos registrados.
uint256 public totalWithdrawsCount;

/// @notice Balance individual de cada usuario.
mapping(address=> uint256) public balances; 

}



