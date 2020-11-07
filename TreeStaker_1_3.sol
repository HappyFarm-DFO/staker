contract ERC20{
    function allowance(address owner, address spender) external view returns (uint256){}
    function transfer(address recipient, uint256 amount) external returns (bool){}
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool){}
    function balanceOf(address account) external view returns (uint256){}
    function decimals() external view returns (uint256){}
}

contract Ticket { HappyBox public box; }

contract HappyBox{ address public master; }

contract TreeStakerPlus{
    
    string version="2.2";
    uint public total=0;
    
    ERC20 token=ERC20(0xfa28ED428D54424D42ED4F71415315df2f2E49D6);
    
    struct Leaf{
        uint prev;
        uint next;
        uint stake;
        address owner;
        address container;
    }
    
    Leaf[] public list;
    mapping(address=>uint[])public owned;
    mapping(address=>uint)public mapped;
    
    constructor()public{
       list.push(Leaf(0,1,0,address(this),address(this)));
       list.push(Leaf(0,10000000000000000,0,address(this),address(this)));
    } 
   
    function stakeOnTopOf(address _container,uint _stake,uint _index)public returns(bool){
       require(_index>0);
       Leaf storage leaf=list[_index];
       require(leaf.stake<_stake);
       //require(token.transfer(address(this),_stake));
       if(!(mapped[_container]>0)){
            require(HappyBox(Ticket(_container).box()).master()==msg.sender);
            uint prev=leaf.prev;
            list.push(Leaf(prev,_index,_stake,msg.sender,_container));
            uint thisIndex=list.length-1;
            list[leaf.prev].next=thisIndex;
            leaf.prev=thisIndex;
            owned[msg.sender].push(thisIndex);
            mapped[_container]=thisIndex;
       }else{
            //update
            list[mapped[_container]].stake+=_stake;
            if(leaf.prev!=mapped[_container]){
                //knit
                list[list[mapped[_container]].prev].next=list[mapped[_container]].next;
                list[list[mapped[_container]].next].prev=list[mapped[_container]].prev;
                //inject 
                list[leaf.prev].next=mapped[_container];
                leaf.prev=mapped[_container];
            }
       }
       total+=_stake;
       return true;
    }
   
    function unstake(uint _index)public returns(bool){
        Leaf storage leaf=list[owned[msg.sender][_index]];
        //require(token.transfer(msg.sender,leaf.stake));
        total-=leaf.stake;
        leaf.stake=0;
        list[leaf.prev].next=leaf.next;
        list[leaf.next].prev=leaf.prev;
       return true;
    }
   
   
    function readStake(address _container)public view returns(uint,uint){
       return (list[mapped[_container]].stake,mapped[_container]);
    }
    
    function owner(address _owner,uint _index)public view returns(uint,uint,uint,uint,uint,address){
        return (owned[_owner][_index],owned[_owner].length,list[owned[_owner][_index]].prev,list[owned[_owner][_index]].next,list[owned[_owner][_index]].stake,list[owned[_owner][_index]].container);
    }
    
    function leafs()public view returns(uint){
       return list.length;
    }
   
   
}


