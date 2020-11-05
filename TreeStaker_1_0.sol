
contract ERC20{
    function allowance(address owner, address spender) external view returns (uint256){}
    function transfer(address recipient, uint256 amount) external returns (bool){}
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool){}
    function balanceOf(address account) external view returns (uint256){}
    function decimals() external view returns (uint256){}
}

contract TreeStaker{
    
    ERC20 token=ERC20(0xfa28ED428D54424D42ED4F71415315df2f2E49D6);
    
    struct Leaf{
        uint prev;
        uint next;
        uint stake;
        address owner;
        address container;
    }
    
   Leaf[] public list;
   mapping(address=>uint)public index;
    
   constructor()public{
       list.push(Leaf(0,1,0,address(this),address(this)));
       list.push(Leaf(1,0,0,address(this),address(this)));
   } 
   
   function stakeOnTopOf(address _container,uint _stake,uint _index)public returns(bool){
       require(_index>0);
       require(index[msg.sender]>0);
       require(list[_index].stake<_stake);
       require(token.transfer(address(this),_stake));
       uint prev=list[_index].prev;
       uint next=_index;
       list.push(Leaf(prev,_index,_stake,msg.sender,_container));
       list[list[_index].prev].next=list.length-1;
       list[_index].prev=list.length-1;
       index[msg.sender]=list.length-1;
       return true;
   }
   
    function unstake()public returns(bool){
        Leaf memory leaf=list[index[msg.sender]];
        require(token.transfer(msg.sender,leaf.stake));
        leaf.stake=0;
        list[leaf.prev].next=leaf.next;
        list[leaf.next].prev=leaf.prev;
       return true;
   }
   
   function getLeaf(uint _index)public view returns(uint,uint,uint,address,address){
       return (list[_index].prev,list[_index].next,list[_index].stake,list[_index].owner,list[_index].container);
   }
   
   
}
