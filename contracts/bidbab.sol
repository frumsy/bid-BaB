pragma solidity ^0.4.0;

import "DateTime.sol";

contract bidbab {

    event UserRating(address userAddress, uint ustar);
    event HostRating(address hostAddress, uint hstar);

    struct Location {
      uint32 lat; //times 1/100000
      uint32 long; //times 1/100000
    }
    
    struct StartStopDate {
        uint fromDate;
        uint toDate;
    }
        
    struct Bid {
        address placedBy;
        uint amount;
        StartStopDate duration;
    }
    
    struct Space {
        string hostName;
        string postName;
        address listedBy;//= msg.sender
        uint startdate;// = now; //set via function
        uint enddate;// = now; //set via function
        
        Bid[] bids;
        Bid currentbid;
        StartStopDate[] freeSpace;
    }

    Bid[] public acceptedBids;

    function validDate(uint _date) private returns (bool) {
        if(_date < now) {
            return false;
        }
    } 
   
    function placeBid (Space storage _space, uint _start, uint _toDate, uint _amount) internal
    {
        //StartStopDate cal = getCalendar();
        
        require (msg.sender.balance > _amount);
        Bid storage userBid;
        userBid.placedBy = msg.sender;
        userBid.amount = _amount;
        userBid.duration.fromDate = _start;
        userBid.duration.toDate = _toDate;
        _space.bids.push(userBid);
    }

    function publicBid (Space _space, uint16 startyear, uint8 startmonth, uint8 startday, uint16 endyear, uint8 endmonth, uint8 endday, uint amount) public returns (bool) {
        if(placeBid(_space, toTimeStamp(startyear, startmonth, startday), toTimeStamp(endyear, endmonth, endday))) {
            return true;
        }
        return false;
    }
    
    function makeSpace(string _hostName, string _postName, uint _startdate, uint _enddate, uint lat, uint long) internal returns (bool)
    {
        require(validDate(startdate) && validDate(enddate));
        Space my_space;
        my_space.hostName = _hostName;
        my_space.postName = _postName;
        my_space.listedBy = msg.sender;
        my_space.startdate = _startdate; //set via function
        my_space.enddate = _enddate;
        return true;
    } 

    function createListing(string _hostName, string _postName, uint16 startyear, uint8 startmonth, uint8 startday, uint16 endyear, uint8 endmonth, uint8 endday, uint lat, uint long) constant returns (bool) {
        uint starttime = toTimeStamp(startyear, startmonth, startday);
        uint endtime = toTimeStamp(endyear, endmonth, endday);
        makeSpace(_hostName, _postName, starttime, endtime, lat, long);
    }
    //index, amount, address
    function findMaxBid(Space _space) internal returns (uint, uint, address) { 
        //uint days = _space.bids[0].duration.toDate - _space.bids[0].duration.fromDate;
        uint maxbid = _space.bids[0].amount;
        address maxbidder = _space.bids[0].placedBy;
        uint maxid = 0;
        for(int i = 0; i < _space.bids.length; i++) {
            //uint idays = _space.bids[i].duration.toDate - _space.bids[i].duration.fromDate;
            if(_space.bids[i].amount > maxbid) {
                maxbid = _space.bids[i].amount;
                maxbidder = _space.bids[i].placedBy;
                maxid = i;
            }
        }
        return(maxid, maxbid, maxbidder);
    }

    function closeBid(Space storage _space) payable returns (uint){
        require (_space.listedBy == msg.sender);
        Bid winningBid = _space.bids[findMaxBid(_space)[0]];
        require(winningBid.placeBy.balance > winningBid.amount);
        acceptedBids.push(winningBid);
        if( (_space.freeSpace[0].toDate - _space.freeSpace[0].fromDate)- (winningBid.duration.toDate - winningBid.duration.fromDate) > 0) {
            StartStopDate i1;
            i1.fromDate = _space.freeSpace[0].fromDate;
            i1.toDate = winningBid.duration.fromDate;
            StartStopDate i2;
            i2.fromDate = winningBid.duration.toDate;
            i2.toDate = _space.freeSpace[0].toDate;

            if(i1.toDate - i1.fromDate > 0) {
                _space.freeSpace.push(i1);
            }
            if(i2.toDate - i2.fromDate > 0) {
                _space.freeSpace.push(i2);
            }
        }
        return winningBid.amount;
    }
    function bidbab(byte[] bs, address add)
    {
    }
}
