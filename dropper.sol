contract TokenDropper{
    
    HappyStaker public staker;
    ERC20 public token;
    mapping(address => bool)public rewarded;
    uint public multiplier;
    
    constructor(address staker_contract,uint multip,address token_address){
        staker=HappyStaker(staker_contract);
        multiplier=multip;
        token=ERC20(token_address);
    }
    
    function Pull_Reward() public{
        require(!rewarded[msg.sender]);
        require(HappyStaker.paused);
        require(token.transfer(msg.sender, HappyStaker.stake(msg.sender)*multiplier));
        rewarded[msg.sender]=true;
    }
    
}
