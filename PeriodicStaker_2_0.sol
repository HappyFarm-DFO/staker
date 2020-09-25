/* 
 *  HappyStaker
 *  VERSION: 2.0
 *
 */

contract ERC20{
    function allowance(address owner, address spender) external view returns (uint256){}
    function transfer(address recipient, uint256 amount) external returns (bool){}
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool){}
    function balanceOf(address account) external view returns (uint256){}
}

contract PeriodicStaker {
    

    event Staked(address staker);


    ERC20 public token;
    uint public total_stake=0;
    uint public total_stakers=0;
    mapping(address => uint)public stake;
    
    uint public status=0; //0=open , 1=can't unstake , 2 can't stake and unstake
    
    uint safeWindow=40320;
    
    uint public startLock;
    uint public lockTime;
    uint minLock=17280;
    uint maxLock=172800;
    
    uint public freezeTime;
    uint minFreeze=17280;
    uint maxFreeze=40320;

    address public master;

    

    constructor(address tokenToStake) public {
        token=ERC20(tokenToStake);
        master=msg.sender;
    }
    

    function stakeNow(uint256 amount) public {
        require(amount > 0, "You need to stake at least some tokens");
        require(status!=2);
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        require(token.transferFrom(msg.sender, address(this), amount));
        if(stake[msg.sender]>=0)total_stakers++;
        stake[msg.sender]+=amount;
        total_stake+=amount;
        
        emit Staked(msg.sender);
    }
    
    function unstake(uint256 amount) public {
        require(amount > 0, "You need to unstake at least some tokens");
        require(stake[msg.sender] > 0, "You have no stake");
        require((status==0)||((status==1)&&((startLock+lockTime)<block.number))||((status==2)&&((startLock+freezeTime)<block.number)));
        require(token.transfer(msg.sender, stake[msg.sender]));
        total_stake-=stake[msg.sender];
        stake[msg.sender]=0;
        total_stakers--;

    }
    
    function openDropping(uint lock) public{
        require(msg.sender==master);
        require(minLock<=lock);
        require(lock<=maxLock);
        require(status==0);
        require(block.number>startLock+lockTime+safeWindow);
        status=1;
        lockTime=lock;
        startLock=block.number;
    }
    
    function freeze(uint freez) public{
        require(msg.sender==master);
        require(minFreeze<=freez);
        require(freez<=maxFreeze);
        require(status!=2);
        if(status==0)
        require(block.number>startLock+safeWindow);
        if(status==1)
        require(block.number>startLock+lockTime);
        status=2;
        startLock=block.number;
    }
    
    function open() public{
        if(status==1)require(block.number>startLock+lockTime);
        if(status==2)require(block.number>startLock+freezeTime);
        status=0;
        startLock=block.number;
    }
    
    function setMaster(address new_master)public returns(bool){
        require(msg.sender!=master);
        master=new_master;
        return true;
    }
    
    function status()public returns(uint){return status;}

}
