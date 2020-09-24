contract TokenDropper{
    
    HappyStaker public staker;
    ERC20 public token;
    mapping(address => bool)public rewarded;
    uint public multiplier;
    address master;
    address public receiver;
    
    constructor(address staker_contract,uint multip,address token_address,address destination) public{
        staker=HappyStaker(staker_contract);
        multiplier=multip;
        token=ERC20(token_address);
        master=msg.sender;
        receiver=destination;
    }
    
    function Pull_Reward() public{
        require(!rewarded[msg.sender]);
        require(staker.paused());
        require(token.transfer(msg.sender, staker.stake(msg.sender)*multiplier));
        rewarded[msg.sender]=true;
    }
    
    function burn()public returns(bool){
        require(!staker.paused());
        token.transfer(receiver, token.balanceOf(address(this)));
    }
    
}
