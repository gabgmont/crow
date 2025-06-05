forge build

cast send 0x7a38C86ee0Dcb7De0AC6909B64c005BA18cA4D71 \
    --value 1ether \
    --from 0xF39Fd6e51aad88F6F4ce6aB8827279cffFb92266 \
    --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
    --rpc-url http://127.0.0.1:8545

forge script script/Legit.s.sol:LegitScript \
    --rpc-url http://127.0.0.1:8545 \
    --broadcast \
    --account zero