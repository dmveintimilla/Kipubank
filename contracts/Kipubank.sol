// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract KipuBank {
    uint256 public immutable limiteRetiro;
    uint256 public bankCap;

    mapping(address => uint256) public balances;

    uint256 public totalDepositado;
    uint256 public contadorDepositos;
    uint256 public contadorRetiros;

    // Errores 
    error CantidadInvalida();
    error BalanceInsuficiente();
    error ExcedeBankCap(uint256 intentado, uint256 disponible);
    error ExcedeLimiteRetiro(uint256 intentado, uint256 limite);
    error TransferenciaFallida();

    event Deposito(address indexed usuario, uint256 monto, uint256 totalDepositado, uint256 contadorDepositos);
    event Retiro(address indexed usuario, uint256 monto, uint256 contadorRetiros);

    // Validar que la cantidad sea mayor que 0
    modifier cantidadValida(uint256 _cantidad) {
        if (_cantidad == 0) revert CantidadInvalida();
        _;
    }

    // Validar que el usuario tenga balance suficiente
    modifier balanceSuficiente(uint256 _cantidad) {
        if (balances[msg.sender] < _cantidad) revert BalanceInsuficiente();
        _;
    }

    // Constructor: inicializa los límites de capacidad y retiro
    constructor(uint256 _bankCap, uint256 _limiteRetiro) {
        bankCap = _bankCap;
        limiteRetiro = _limiteRetiro;
    }

    // Función para depositar ETH en la bóveda
    function depositar() external payable cantidadValida(msg.value) {
        uint256 nuevaSuma = totalDepositado + msg.value;
        if (nuevaSuma > bankCap) {
            revert ExcedeBankCap(msg.value, bankCap - totalDepositado);
        }

        balances[msg.sender] += msg.value;
        totalDepositado = nuevaSuma;
        contadorDepositos++;

        emit Deposito(msg.sender, msg.value, totalDepositado, contadorDepositos);
    }

    // Función para retirar ETH de la bóveda
    function retirar(uint256 cantidad)
        external
        cantidadValida(cantidad)
        balanceSuficiente(cantidad)
    {
        if (cantidad > limiteRetiro) {
            revert ExcedeLimiteRetiro(cantidad, limiteRetiro);
        }

        balances[msg.sender] -= cantidad;
        totalDepositado -= cantidad;
        contadorRetiros++;

        _transferirSeguro(payable(msg.sender), cantidad);

        emit Retiro(msg.sender, cantidad, contadorRetiros);
    }

    // Función privada para transferir ETH de forma segura
    function _transferirSeguro(address payable destino, uint256 cantidad) private {
        (bool exito, ) = destino.call{value: cantidad}("");
        if (!exito) revert TransferenciaFallida();
    }

    // Aceptar depósitos directos de ETH
    receive() external payable cantidadValida(msg.value) {
        uint256 nuevaSuma = totalDepositado + msg.value;
        if (nuevaSuma > bankCap) {
            revert ExcedeBankCap(msg.value, bankCap - totalDepositado);
        }

        balances[msg.sender] += msg.value;
        totalDepositado = nuevaSuma;
        contadorDepositos++;

        emit Deposito(msg.sender, msg.value, totalDepositado, contadorDepositos);
    }

    // Consultar el balance de un usuario
    function verBalance(address usuario) external view returns (uint256) {
        return balances[usuario];
    }
}
