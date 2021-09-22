pragma solidity >=0.5.8 <0.7.0;

contract Admin {
         address adminAddress;

         constructor () internal {
         }

         function isAdmin () public view returns (bool) {
           //return adminAddress == msg.sender; //TODO figure out why this doesn't work
           return true;
         }

         modifier admin {
           require (isAdmin(), "user is not admin");
           _;
         }
}

contract Site is Admin {

  struct Artist {
    // uint32 id;
    string name;
    string description;
    address payable addr;
  }

  struct Feature {
    uint startTime;
    uint endTime;
    int64 lastFeatureId; // -1 if none
    int64 currentBidId; // -1 if none
    bool accepted; // artist has approved the top bid for this feature
  }

  struct Art {
    // uint32 id;
    uint16 artistId;
    bool finished;
    int64 currentFeatureId; // -1 if none
  }

  struct Bid {
    // uint32 id;
    int64 lowerBidId; // if this outbids an older bid, otherwise -1
    address payable addr;
    uint amount;
    string request;
  }

  Artist[] artists;
  Art[] art;
  Feature[] features;
  Bid[] bids;

  string testMessage;

  function isArtist () public view returns (bool) {
     bool result = false;
     for (uint16 i = 0; i < artists.length; i++) {
       if (msg.sender == artists[i].addr) {
         result = true;
       }
     }
     return result;
  }

  // probably isn't useful. We want to know if msg.sender matches specific artist generally
  modifier artist {
    require (isArtist(), "user is not an artist");
    _;
  }

  //mapping(uint64 => Art) public arts;
  //uint public artsCount;

  //function getArt () public view returns (Art[] storage) {
  //  return art;
  //}

  //function getArtists () public view returns (Artist[] storage) {
  //  return artists;
  //}
  
  // change when struct definition changes
  function getArt (uint i) public view returns (uint16, bool, int64) {
    return (art[i].artistId, art[i].finished, art[i].currentFeatureId);
  }

  function getNumArt () public view returns (uint) {
    return art.length;
  }

  // change when struct definition changes
  function getArtist (uint i) public view returns (string memory, string memory, address payable) {
    return (artists[i].name, artists[i].description, artists[i].addr);
  }

  function getNumArtist () public view returns (uint) {
    return artists.length;
  }

  function getDisplayFeature (uint16 artId) public view returns (int64) {
    int64 latestFeature = art[artId].currentFeatureId;
    if (latestFeature > -1) {
      if (now > features[uint64(latestFeature)].endTime) {
        return latestFeature;
      } else {
        return features[uint(latestFeature)].lastFeatureId;
      }
    } else {
      return -1;
    }
  }

  function addArtist (address payable _addr) public admin {
    artists.push(Artist("", "", _addr));
  }

  function startArt () public artist {
     for (uint16 i = 0; i < artists.length; i++) {
       if (msg.sender == artists[i].addr) {
          art.push(Art(i, false, -1));
       }
     }
  }

  function startFeature (uint64 artId, uint _endTime) public artist {
    Art storage thisArt = art[artId];
    require (artists[thisArt.artistId].addr == msg.sender, "can't start a feature for art you don't own!");

    Feature memory thisFeature = Feature (now, _endTime, thisArt.currentFeatureId, -1, false);
    features.push(thisFeature);
    thisArt.currentFeatureId = int64(features.length - 1);
  }

  // TODO make sure you can't bid on feature auctions that have ended
  function makeBid (uint64 artId, string memory _request) public payable returns (bool, string memory) {
    Art memory thisArt = art[artId];
    if (thisArt.currentFeatureId > -1) {
      Feature storage thisFeature = features[uint(thisArt.currentFeatureId)];

      if (thisFeature.currentBidId > -1) {
        Bid memory oldBid = bids[uint(thisFeature.currentBidId)];

        if (msg.value > oldBid.amount) {
          Bid memory newBid = Bid (thisFeature.currentBidId, msg.sender, msg.value, _request);
          bids.push(newBid);
          thisFeature.lastFeatureId = int64(bids.length - 1);
          return (true, "You're now the top bidder!");

        } else { // insufficient bid
          return (false, "Your bid must be higher than the current maximum bid");
        }

      } else { // very first bid
        Bid memory newBid = Bid (-1, msg.sender, msg.value, _request);
        bids.push(newBid);
        thisFeature.lastFeatureId = int64(bids.length - 1);
        return (true, "You've made the very first bid!");
      }

    } else {
      return (false, "This art isn't open for bidding yet");
    }
  }

  // TODO make function for artist to cancel bid if they hate the request

  // TODO make this callable only by artist who owns artwork?
  function endBidding (uint64 artId) public {
    Art memory thisArt = art[artId];
    require (thisArt.currentFeatureId > -1, "can't end bidding when there is no current feature");
    Feature storage thisFeature = features[uint(thisArt.currentFeatureId)];
    require (now > thisFeature.endTime, "Can't end auction prematurely");

    if (thisFeature.currentBidId > -1) {
      Bid memory winningBid = bids[uint(thisFeature.currentBidId)];

      if (winningBid.lowerBidId > -1) {
         // refund losing bids
         Bid memory currentBid = winningBid; // assignment should be overwritten immediately
         for (currentBid = bids[uint(winningBid.lowerBidId)]; currentBid.lowerBidId != -1; currentBid = bids[uint(currentBid.lowerBidId)]) {
             currentBid.addr.transfer(currentBid.amount);
         }
         currentBid.addr.transfer(currentBid.amount); // need one last call for last bid
      }

      artists[thisArt.artistId].addr.transfer(winningBid.amount); 

    } else { // there are no bids!
      
    }

    thisFeature.accepted = true;
  }

  function getTestMessage() public view returns (string memory) {
    return testMessage;
  }

  constructor (address _admin) public {
    adminAddress =_admin;
    testMessage = "A test has passed";
  }
}
