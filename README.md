### 7702Attacktest



1：

forge install foundry-rs/forge-std

anvil --hardfork prague

forge test --match-contract EIP7702PhishingAttackTest -vvvv 

forge script script/EIP7702Phishing.s.sol --tc EIP7702PhishingAttackTest --evm-version prague  -vvvv 
