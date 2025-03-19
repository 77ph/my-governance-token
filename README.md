# MyGovernanceToken (ERC20Votes + OFT v2)

Multichain governance token with LayerZero interoperability.

## 🛠 Deployment Instructions

### 🔹 Step 1: Set Environment Variables
Create a `.env` file:
```env
PRIVATE_KEY=0x...
LZ_ENDPOINT=0x...       # for the current chain
TOKEN_OWNER=0x...       # multisig or deployer
TOKEN_ADDRESS=0x...
REMOTE_CHAIN_ID=109     # e.g., Polygon
REMOTE_TOKEN_ADDRESS=0x...
```

### 🔹 Step 2: Deploy Token
```bash
forge script script/DeployToken.s.sol --rpc-url $RPC_URL --broadcast --verify -vvvv
```

### 🔹 Step 3: Set Trusted Remote
```bash
forge script script/SetTrustedRemote.s.sol --rpc-url $RPC_URL --broadcast -vvvv
```

### 🔹 Step 4: Transfer Ownership to Dead (on L2)
```bash
forge script script/TransferOwnershipToDead.s.sol --rpc-url $RPC_URL --broadcast -vvvv
```

### 🔹 Cross-chain Transfer
Use `safeSendFrom(...)` with appropriate params.

### E2E test
forge test --match-path test/E2E.t.sol


