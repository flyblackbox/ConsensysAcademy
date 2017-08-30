pragma solidity ^0.4.4;

contract Splitter {
	struct ToUserStruct {
		address addr;
		string name;
		uint balance;
	}

	struct SplitterStruct {
		string fromUserName;
		ToUserStruct toUser1;
		ToUserStruct toUser2;
		uint index;
	}

	mapping (address => SplitterStruct) private splitterStructs;
	address[] private splitterIndex;

	address public owner = msg.sender;
	bool public enabled = true;

//	event Transfer(address indexed _from, address indexed _to, uint256 _value);

	function Splitter() {
	}

	// additions or updates can only be made by transaction originator or contract owner
	modifier onlyBy(address _account)
	{
		require(msg.sender == _account || msg.sender == owner);
		_;
	}

	// only the owner can kill the whole contract
	modifier onlyByOwner()
	{
		require(msg.sender == owner);
		_;
	}

	function insertSplitter(
		address fromUserAddr,
		string fromUserName, 
		address toUser1Addr,
		string toUser1Name,
		address toUser2Addr,
		string toUser2Name)
		public
		payable
		onlyBy(fromUserAddr)
		returns(bool success)
	{
		require(enabled);
		require(msg.value > 0);

		// divide value between the two users, favouring the first user in the case of 
		uint valueSplit2 = msg.value / 2;
		uint valueSplit1 = msg.value - valueSplit2;

		ToUserStruct memory toUser1 = ToUserStruct(toUser1Addr, toUser1Name, valueSplit1);
		ToUserStruct memory toUser2 = ToUserStruct(toUser2Addr, toUser2Name, valueSplit2);

		splitterStructs[fromUserAddr].fromUserName = fromUserName;
		splitterStructs[fromUserAddr].toUser1 = toUser1;
		splitterStructs[fromUserAddr].toUser2 = toUser2;

		// update index array and index of new splitter struct in one step, saving on gas
		splitterStructs[fromUserAddr].index = splitterIndex.push(fromUserAddr) - 1;

		return true;
	}

	// // check if this splitter exists
	// function isSplitter(address fromUserAddr)
	// 	public
	// 	constant
	// 	returns (bool exists)
	// {
	// 	if (splitterIndex.length == 0) {
	// 		return false;
	// 	}

	// 	if (splitterIndex[splitterStructs[fromUserAddr].index] == fromUserAddr) {
	// 		return true;
	// 	}

	// 	return false;
	// }

	function kill() onlyByOwner() {
		enabled = false;
	}

	function getSplitterCount()
		public
		constant
		returns(uint count)
	{
		return splitterIndex.length;
	}

	function getSplitterAtIndex(uint index)
		public
		constant
		returns(
			address fromUserAddr,
			string fromUserName, 
			address toUser1Addr,
			string toUser1Name,
			uint toUser1Balance,
			address toUser2Addr,
			string toUser2Name,
			uint toUser2Balance)
	{
		// ensure this splitter entry exists
		require(index > 0 && index < splitterIndex.length);

		SplitterStruct memory s = splitterStructs[splitterIndex[index]];

		return (
			splitterIndex[index], 
			s.fromUserName, 
			s.toUser1.addr, 
			s.toUser1.name, 
			s.toUser1.balance, 
			s.toUser2.addr, 
			s.toUser2.name, 
			s.toUser2.balance
		);
	}
}