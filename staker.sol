/* 
 *  HappyStaker
 *  VERSION: 1.0
 *
 */

contract ERC20{
    function allowance(address owner, address spender) external view returns (uint256){}
    function transfer(address recipient, uint256 amount) external returns (bool){}
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool){}
}

contract HappyStaker {
    

    event Staked(address staker);


    ERC20 public token;
    uint public total_stake=0;
    uint public total_stakers=0;
    mapping(address => uint)public stake;
    bool public paused;
    uint public lockTime;
    uint public startLock;
    address public master;

    constructor(address tokenToStake) public {
        token=ERC20(tokenToStake);
        master=msg.sender;
    }
    

    function stakeNow(uint256 amount) public {
        require(amount > 0, "You need to stake at least some tokens");
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        token.transferFrom(msg.sender, address(this), amount);
        if(stake[msg.sender]>=0)total_stakers++;
        stake[msg.sender]+=amount;
        total_stake+=amount;
        
        emit Staked(msg.sender);
    }
    
    function unstake(uint256 amount) public {
        require(amount > 0, "You need to unstake at least some tokens");
        require(stake[msg.sender] > 0, "You have no stake");
        if((paused)&&((startLock+lockTime)>block.number))revert();
        token.transfer(msg.sender, stake[msg.sender]);
        total_stake-=stake[msg.sender];
        stake[msg.sender]=0;
        total_stakers--;

    }
    
    function pause() public{
        require(msg.sender==master);
        require(!paused);
        require(block.number>startLock+lockTime+1000);
        paused=true;
        startLock=block.number;
    }
    
    function setMaster(address new_master)public returns(bool){
        if(msg.sender!=master)revert();
        master=new_master;
        return true;
    }

}
