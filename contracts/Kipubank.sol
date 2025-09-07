// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


/**
 * @title KipuBank
 * @notice Proyecto para depósitos y retiros de ETH con límite global de banco (bankCap)
 *         y límite por transacción para retiros (limiteRetiro). Con estadísticas
 * @dev Este contrato usa errores personalizados, patrón checks-effects-interactions
 */
contract KipuBank {

    // 1. TODO Variables de estado apropiadas
    uint256 public totalDepositado;
    uint256 public contadorDepositos;
    uint256 public contadorRetiros;

    // 2. Mapping para balances de usuarios  
    mapping(address => uint256) public balances;

    // 3. Sistema de límites (bankCap, withdrawalLimit)
    // 4. Variables immutable y constant
    uint256 public immutable limiteRetiro;
    uint256 public immutable bankCap;

     // 5. Eventos para depósitos y retiros
    /**
     * @notice Emitido cuando se realiza un depósito exitoso.
     * @param usuario Dirección del usuario que depositó.
     * @param monto   Monto depositado en wei.
     * @param totalDepositado Saldo total bajo custodia tras el depósito.
     * @param contadorDepositos Conteo global de depósitos tras el depósito.
     */
    event Deposito(address indexed usuario, uint256 monto, uint256 totalDepositado, uint256 contadorDepositos);
     /**
     * @notice Emitido cuando se realiza un retiro exitoso.
     * @param usuario Dirección del usuario que retiró.
     * @param monto   Monto retirado en wei.
     * @param contadorRetiros Conteo global de retiros tras el retiro.
     */
    event Retiro(address indexed usuario, uint256 monto, uint256 contadorRetiros);

    // 6. Errores personalizados completos
    error CantidadInvalida();
    error BalanceInsuficiente();
    error ExcedeBankCap(uint256 intentado, uint256 disponible);
    error ExcedeLimiteRetiro(uint256 intentado, uint256 limite);
    error TransferenciaFallida();

    // 7. Modificadores para validaciones
     /**
     * @notice Verifica que la cantidad proporcionada sea mayor que cero.
     * @param _cantidad Monto a validar (wei).
     */
     modifier cantidadValida(uint256 _cantidad) {
        if (_cantidad == 0) revert CantidadInvalida();
        _;
    }

    /**
     * @notice Despliega el contrato con los límites globales requeridos.
     * @param _bankCap       Capacidad global máxima del banco (wei).
     * @param _limiteRetiro  Límite máximo de retiro por transacción (wei).
     * @dev Requiere que el bankCap sea mayor al límite de retiro.
     */
    // 8. Constructor con parámetros
    constructor(uint256 _bankCap, uint256 _limiteRetiro) {
        require(_bankCap > _limiteRetiro, "El capital debe ser mayor que el limite de retiro.");
        // TODO: Asignar valores
        bankCap = _bankCap;
        limiteRetiro = _limiteRetiro;
    }

   
    // 9. Función deposit() payable externa
    /**
     * @notice Deposita ETH en la bóveda del remitente.
     * @dev Rechaza montos cero y valida que no se exceda el bankCap.
     *      Sigue checks-effects-interactions y emite evento.
     *      El valor a depositar se toma de msg.value.
     */
    function depositar() external payable cantidadValida(msg.value) {
        uint256 valorPosibelBanco = resultadoBalance() + msg.value;

        if (valorPosibelBanco > bankCap) {
            revert ExcedeBankCap(msg.value, bankCap - totalDepositado);
        }
        
        balances[msg.sender] += msg.value;
        totalDepositado += msg.value;
        contadorDepositos++;


        emit Deposito(msg.sender, msg.value, totalDepositado, contadorDepositos);

    }

    /**
     * @notice Retira ETH de la bóveda del remitente respetando el límite por transacción.
     * @param cantidad Monto a retirar en wei.
     * @dev Rechaza montos cero, valida límite por transacción y fondos suficientes.
     *      Sigue checks-effects-interactions y emite evento.
     */
    // 10. Función withdraw() externa  
    function retirar(uint256 cantidad) external cantidadValida(cantidad) {
        // TODO: Verificar que no exceda límite de retiro
        if (cantidad > limiteRetiro) {
            revert ExcedeLimiteRetiro(cantidad, limiteRetiro);
        }
        // TODO: Verificar balance suficiente
         if (balances[msg.sender] < cantidad) {
            revert BalanceInsuficiente();
        }
        
        balances[msg.sender] -= cantidad;
        totalDepositado -= cantidad;
        contadorRetiros++;


        _transferirSeguro(payable(msg.sender), cantidad);


        emit Retiro(msg.sender, cantidad, contadorRetiros);

    }
    
     /**
     * @notice Realiza una transferencia nativa (ETH) de forma segura usando call.
     * @param destino  Dirección a la que se envían los fondos.
     * @param cantidad Monto a transferir en wei.
     * @dev Revierte con TransferenciaFallida si la llamada retorna false.
     */
    // 11. Función privada para transferencias seguras
    function _transferirSeguro(address payable destino, uint256 cantidad) private {
        (bool exito, ) = destino.call{value: cantidad}("");
        if (!exito) revert TransferenciaFallida();
    }

    // 12. Funciones view para consultas
    function resultadoBalance() public view returns (uint256) {
        return address(this).balance;
    }
   
    function verTotalDepositado() external view returns  (uint256){
        return contadorDepositos;
    }

    function verTotalRetirado() external view returns  (uint256){
        return contadorRetiros;
    }

   function obtenerFondos() external view returns (uint256) {
        return balances[msg.sender];
    }

    function getFondosPorCuenta(address cuenta) external view returns (uint256) {
        return balances[cuenta];
    }



}
