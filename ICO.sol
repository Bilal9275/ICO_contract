// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;



interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
       if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Ownable   {
    address public _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**

     * @dev Initializes the contract setting the deployer as the initial owner.

     */

    constructor()  {
        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);
    }

    /**

     * @dev Returns the address of the current owner.

     */

    function owner() public view returns (address) {
        return _owner;
    }

    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");

        _;
    }

    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     * Can only be called by the current owner.

     */

    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;
    }
}



contract ICO_FIRST is Ownable {

    using SafeMath for uint256;
    IERC20 public Token;

    constructor(IERC20 _TOKEN) 
    {
        Token = _TOKEN  ;
    }

  uint256 public constant RATE = 3000; // Number of tokens per bnb
  uint256 public constant CAP = 5350; // Cap in Ether
  uint256 public constant START = 1649930820; // Apr 14, 2022 @ 2:24 PM GMT +5:00
  uint256 public constant DAYS = 45; // 45 Day
  
  uint256 public constant initialTokens = 6000000 * 10**18; // Initial number of tokens available
  bool public initialized = false;
  uint256 public raisedAmount = 0;

  event BoughtTokens(address indexed to, uint256 value);


  function goalReached() public view returns (bool) {
    return (raisedAmount >= CAP * 1 ether);
  }

  function isActive() public view returns (bool) {
    return (
        initialized == true &&
        block.timestamp >= START && // Must be after the START date
        block.timestamp <= START.add(DAYS * 1 days) && // Must be before the end date
        goalReached() == false // Goal must not already be reached
    );
  }

  modifier whenSaleIsActive() {
    // Check if sale is active
    assert(isActive());
    _;
  }

  function initialize() public onlyOwner {
      require(initialized == false); // Can only be initialized once
      require(tokensAvailable() == initialTokens); // Must have enough tokens allocated
      initialized = true;
  }
  
  function tokensAvailable() public view returns (uint256) {
    return Token.balanceOf(address(this));
  }

  function buyTokens() public payable whenSaleIsActive {
    require(isActive() == true,"sale is not active");
    uint256 weiAmount = msg.value; // Calculate tokens to sell
    uint256 tokens = weiAmount.mul(RATE).div(1E18);

    emit BoughtTokens(msg.sender, tokens); // log event onto the blockchain
    raisedAmount = raisedAmount.add(msg.value); // Increment raised amount
    Token.transfer(msg.sender, tokens); // Send tokens to buyer
  }

  function withDraw (uint256 _amount) onlyOwner public
    {
        payable(msg.sender).transfer(_amount);
    }


}