# KipuBank

Este repositorio contiene el **contrato inteligente KipuBank**, una bóveda simple en ETH con límites de depósito y retiro, desarrollado como parte de la actividad de entrenamiento en Blockchain.

El contrato permite a los usuarios:

- Depositar tokens nativos (ETH) en una bóveda personal.  
- Retirar fondos con un máximo fijo por transacción (inmutable al desplegar).  
- Asegurar un límite global de capacidad (`bankCap`) definido en el despliegue.  
- Llevar estadísticas de depósitos y retiros.  
- Emitir eventos en cada operación exitosa.  

---

## Requisitos

Para trabajar con este repositorio necesitas:

- [Node.js v22.18 o superior](https://nodejs.org)  
- Una cuenta en [MetaMask](https://metamask.io)  
- Un proyecto en [Alchemy](https://www.alchemy.com)
- Una API key en [Etherscan](https://etherscan.io)  

---

## Configuración

Primero, clona este repositorio:

```bash
git clone https://github.com/dmveintimilla/kipubank
cd kipubank
```

Instala las dependencias:

```
npm install
```
