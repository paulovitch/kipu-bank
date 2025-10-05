# KipuBank — bóveda de ETH con límite por retiro y tope global

**KipuBank** permite:
- **Depositar ETH** en una bóveda personal mediante una función **`payable`** (sin `payable` la transacción que envía ETH se rechaza).  
- **Retirar ETH** respetando un **límite por transacción** (`withdrawPerTxCap`) y sin exceder el propio balance.  
- Respetar un **tope global del banco** (`bankCap`) para la suma de todos los depósitos, fijado en el **constructor** al desplegar.  
- Registrar **eventos** en depósitos y retiros para facilitar auditoría en el explorador de bloques.  
- Exponer **funciones de lectura (`view`)** para consultar balances sin modificar estado.

---

## 🔒 Seguridad (según el Módulo 2)
- Validaciones con **`require`** para revertir si no se cumplen condiciones (`amount > 0`, no superar `bankCap`, etc.).  
- Patrón **Checks → Effects → Interactions** en `withdraw` (primero validar, luego actualizar estado, por último transferir ETH).  
- Envío de ETH con **`.call{value: …}("")`** y verificación del resultado (método recomendado y seguro).  
- Control de entradas directas con **`receive()`** y **`fallback()`**.

---

## ⚙️ Interfaz del contrato

| Función | Tipo | Descripción |
|----------|------|--------------|
| `deposit()` | `external payable` | Deposita ETH en tu bóveda (requiere enviar `Value` > 0). |
| `withdraw(uint256 amount)` | `external` | Retira `amount` si cumple los límites; usa `call` para enviar ETH. |
| `balanceOf(address user)` | `external view` | Devuelve el balance de `user` (no gasta gas). |
| **Eventos** |  | `Deposited(user, amount, newUserBalance)` / `Withdrawn(user, amount, newUserBalance)` |
| **receive/fallback** |  | Rechazan ETH/calls directas fuera de `deposit()`. |

---

## 🚀 Despliegue (Remix + Testnet)
> El Módulo 2 usa Remix y testnets como **Sepolia**.  

1. Abre [remix.ethereum.org](https://remix.ethereum.org) y crea `contracts/KipuBank.sol`.  
2. Compila con **0.8.x**.  
3. En **Deploy & Run**, conecta MetaMask a **Sepolia**.  
4. Pasa los parámetros del constructor:  
   - `_withdrawPerTxCap` (wei), ej.: `100000000000000000` (0.1 ETH)  
   - `_bankCap` (wei), ej.: `5000000000000000000` (5 ETH)  
5. Haz **Deploy** y guarda la **dirección del contrato**.

---

## 🧾 Verificación en el explorador
1. Abre tu dirección en [sepolia.etherscan.io](https://sepolia.etherscan.io).  
2. Ve a **Contract → Verify and Publish**.  
3. Selecciona la misma versión de compilador y pega el código fuente.  
4. Tras verificar, podrás leer y escribir desde el explorador.

---

## 🧪 Cómo interactuar

| Acción | Dónde | Qué hacer | Resultado |
|--------|--------|------------|------------|
| **Depositar** | Remix | Coloca un `Value` > 0 y ejecuta `deposit()` | Evento `Deposited` + balance actualizado |
| **Retirar** | Remix | Ejecuta `withdraw(amount)` con monto válido | Evento `Withdrawn` + ETH enviado |
| **Consultar balance** | Remix o Etherscan | `balanceOf(<tu address>)` | Muestra tu saldo |
| **Eventos** | Etherscan → Logs | Ver `Deposited` / `Withdrawn` | Registro auditable |

---

## ✅ Checklist de entrega

- [ ] Repositorio público **`kipu-bank`**.  
- [ ] Carpeta **`/contracts`** con `KipuBank.sol` (mappings, variables, constructor, funciones, eventos, `require`).  
- [ ] **Dirección verificada** del contrato en testnet (Sepolia u otra).  
- [ ] Este **README.md** explicando: qué hace, cómo desplegar, verificar e interactuar.

---

## 🧭 Solución de problemas

| Problema | Causa / Solución |
|-----------|------------------|
| “La función no acepta ETH” | Asegúrate de que `deposit()` es **`payable`** y de enviar `Value`. |
| “cap=0 / bankCap=0 / cap>bankCap” | Fallo de validación `require` en el constructor. |
| “No veo eventos” | Revisa pestaña **Logs/Events** del explorador. |
| “Transfer failed” | Falla en `call`; revisa que haya saldo suficiente. |
