contract LockDropper{
    
    PeriodicStaker public staker;
    ERC20 public token;
    uint public multiplier;
    address master;
    address public receiver;
    
    constructor() public{
        staker=PeriodicStaker(0x2FC3dc48aE275C2e4933cD9371C20BC7601D9511);
        multiplier=30;
        token=ERC20(0x722dd3F80BAC40c951b51BdD28Dd19d435762180);
        master=msg.sender;
        receiver=0xdA1Ec8F2Fb47e905079663bCEA69f1a2B010f2D3;
    }
    
    function LockDrop(uint amount) public{
        require(staker.status()==1);
        require(staker.stakeNow(amount,msg.sender));
        require(token.transfer(msg.sender, amount*multiplier/100));
    } 
        
    function burn()public returns(bool){
        require(msg.sender==master);
        require(staker.status()==0);
        token.transfer(receiver, token.balanceOf(address(this)));
    }
    
}
