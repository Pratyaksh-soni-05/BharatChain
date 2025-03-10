// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BharatChain is ERC20, Ownable {
    mapping(address => uint256) public distributorGoods;  // Tracks goods allocated to distributors
    mapping(address => uint256) public citizenGoods;      // Tracks goods received by citizens

    event TokensMinted(address indexed to, uint256 amount); 
    event GoodsAllocated(address indexed distributor, uint256 amount);
    event PaymentReceived(address indexed citizen, address distributor, uint256 tokenAmount);
    event GoodsDelivered(address indexed distributor, address citizen, uint256 goodsAmount);
    event TokensBurned(address indexed from, uint256 amount);

    constructor() ERC20("BharatToken", "BHT") Ownable(msg.sender) {
        _mint(msg.sender, 1000000 * 10 ** decimals());  // Govt gets initial 1M tokens
    }

    function mintTokens(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    function allocateGoods(address distributor, uint256 goodsAmount) public onlyOwner {
        distributorGoods[distributor] += goodsAmount;
        emit GoodsAllocated(distributor, goodsAmount);
    }

    function payForGoods(address distributor, uint256 tokenAmount) public {
        require(balanceOf(msg.sender) >= tokenAmount, "Not enough tokens!");
        require(distributorGoods[distributor] >= tokenAmount, "Distributor lacks goods!");

        _transfer(msg.sender, distributor, tokenAmount);
        distributorGoods[distributor] -= tokenAmount;
        citizenGoods[msg.sender] += tokenAmount;

        emit PaymentReceived(msg.sender, distributor, tokenAmount);
    }

    function deliverGoods(address citizen, uint256 goodsAmount) public {
        require(citizenGoods[citizen] >= goodsAmount, "Citizen has not paid for these goods!");

        citizenGoods[citizen] -= goodsAmount;

        emit GoodsDelivered(msg.sender, citizen, goodsAmount);
    }

    function burnTokens(uint256 amount) public onlyOwner {
        require(balanceOf(msg.sender) >= amount, "Not enough tokens to burn!");

        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }
}
