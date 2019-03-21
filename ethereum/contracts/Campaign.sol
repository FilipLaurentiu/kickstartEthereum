pragma solidity ^0.5.0;

contract CampaignFactory {
    address[] public deployedCompaigns;
    
    function createCampaign(uint minimum) public {
        Campaign newCampaign = new Campaign(minimum, msg.sender);
        deployedCompaigns.push(address(newCampaign));
    }
    
    function getDeployedCampaigns() public view returns(address[] memory) {
        return deployedCompaigns;   
    }
}

contract Campaign {
  struct Request {
      string description;
      uint value;
      address payable recipient;
      bool complete;
      uint approvalCount;
      mapping(address => bool) approvals;
  }
  
  Request[] public requests;
  address public manager;
  uint public minimumContribution;
  mapping(address => bool) approvers;
  uint public approversCount;
  
  modifier restricted() {
    require(msg.sender == manager,"Only manager can acces this functionality");
    _;
  }
  
  constructor(uint minimum, address creator) public {
      manager = creator;
      minimumContribution = minimum;
  }
  
  function contribute() public payable {
      require(msg.value > minimumContribution,"Value is to low");
      approvers[msg.sender] = true;
      approversCount++;
  }
  
  function createRequest(string memory description, uint value, address payable recipient) public payable restricted {
      Request memory newRequest = Request({
          description: description,
          value: value,
          recipient: recipient,
          complete: false,
          approvalCount: 0
      });
      requests.push(newRequest);
  }
  
  function approveRequest(uint index) public {
      Request storage request = requests[index];
      
      require(approvers[msg.sender], "This is not an approver");
      require(!request.approvals[msg.sender], "Already vote");
      
      request.approvals[msg.sender] = true;
      request.approvalCount++;
  }
  
  function finalizeRequest(uint index) public restricted {
       Request storage request = requests[index];
       require(request.approvalCount > (approversCount / 2));
       require(!request.complete, "Request already finalized");
       
        request.recipient.transfer(request.value);
       request.complete = true;
  }
}