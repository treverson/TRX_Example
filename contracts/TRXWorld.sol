pragma solidity ^0.4.23;

// A common construct for card game
contract TRXWorld
{
    struct Card
    {
        address owner;
        uint id;
        uint price;
        uint lastPrice;
    }

    event BuyCard(uint id);
    mapping(uint => Card) public card_list;
    // user invite id
    mapping(address => uint) public userInviteId;
    mapping(uint => address) public inviteIdToAddress;
    // user referral money
    mapping(address => uint) public userInviteMoney;
    uint public inviteIndex = 0;
    uint public cardPrice;
    uint public cardNumber = 0;
    uint public startTime = 0;
    uint public endTime = 0;
    uint public devEarning = 0;
    uint public gameLength = 0;
    uint public totalEx = 0;
    uint public invitePrice = 100000000;  // 100 trx for referral id 
    // pot
    mapping(uint => uint) public worldPot;  // 1 world + 7 continent
    uint public fomoPot; // 1 country 
    
    address public lastBuyer;
    address public owner;
    

    constructor() public
    {
        owner = msg.sender;
        // issue card here 100trx here 
        cardPrice = 1000000000;
        // issue 10 card
        card_list[0] = Card({owner: owner, id: 0, price: cardPrice*100, lastPrice: cardPrice*100});
        // seven continent
        for (uint i = 0; i < 7; i++) {
            card_list[1+i] = Card({owner: owner, id: i+1, price: cardPrice*10, lastPrice: cardPrice*10});
        }
        for (uint j = 0; j < 254; j++) {
            card_list[8+j] = Card({owner: owner, id: j+8, price: cardPrice, lastPrice: cardPrice});
        }
        // TODO: change 
        cardNumber = 1 + 7 + 254;
        // 254 countries => add issueCountry here when use trx
        
        // config
        gameLength = 24*60*60;
        startTime = 1543492800;
        lastBuyer = owner;
        endTime = startTime + gameLength;
        // owner has invite id 1
        inviteIndex += 1;
        userInviteId[msg.sender] = inviteIndex;
        inviteIdToAddress[inviteIndex] = msg.sender;
        inviteIndex += 173;
    }
    
    function countryParent(uint cardId) public pure returns(uint) {
        require(cardId >= 8);    
        uint newCardId = cardId - 8;
        if (newCardId < 38) {
            return 1;
        } else if (newCardId < 55) {
            return 2;
        } else if (newCardId < 109) {
            return 3;
        } else if (newCardId < 164) {
            return 4;
        } else if (newCardId < 223) {
            return 5;
        } else if (newCardId < 249) {
            return 6;
        } else {
            return 7;
        }
    }
    
    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }

    function buyCard(uint cardId, uint inviteId) public payable {
        require(now > startTime, "GAME not start");
        require(now < endTime, "GAME already end");
        require(msg.value >= card_list[cardId].price);
        require(msg.sender != card_list[cardId].owner);
        require(cardId < cardNumber);
        require(cardId >= 0);
        require(inviteId>0);
        totalEx += msg.value;
        uint excess = msg.value - card_list[cardId].price;
        if (excess > 0) {
            msg.sender.transfer(excess);
        }
        uint profit = card_list[cardId].price - card_list[cardId].lastPrice;
        card_list[cardId].owner.transfer(card_list[cardId].lastPrice);
        emit BuyCard(cardId);
        uint userProfit = 0;
        uint continentProfit = 0;
        uint worldProfit = 0;
        uint fomoProfit = 0;
        uint inviteProfit = 0;
        
        if (profit > 0) {
            // devProft = all - above
            // userProfit
            userProfit = profit/10*3;
            card_list[cardId].owner.transfer(userProfit);
            // fomoProfit
            fomoProfit = profit/100*5;
            fomoPot += fomoProfit;
            // inviteProfit
            if (inviteIdToAddress[inviteId] == address(0)) {
                inviteProfit = 0;
            } else {
                inviteProfit = profit/10;
                inviteIdToAddress[inviteId].transfer(inviteProfit);
            }
            // buy world
            if (cardId <= 7) {
                worldProfit = profit/100*15;
                worldPot[0] += worldProfit;
            } else {
                uint continentId = countryParent(cardId);
                worldProfit = profit/100*5;
                continentProfit = profit/10;
                worldPot[0] += worldProfit;
                worldPot[continentId] += continentProfit;
            }
        }
        // devProfit
        uint devProfit = profit - userProfit - continentProfit - worldProfit - fomoProfit - inviteProfit;
        owner.transfer(devProfit);

        card_list[cardId].owner = msg.sender;
        lastBuyer = msg.sender;
        card_list[cardId].lastPrice = card_list[cardId].price;
        // update time 
        if (endTime + 30 > now + gameLength) {
            endTime = now + gameLength;
        } else {
            endTime += 30;
        }
        // 35 percent rise
        card_list[cardId].price = card_list[cardId].price / 100 * 135;
    }
    
    function buyInviteId() public payable returns(uint) {
        // user has no invite id
        require(userInviteId[msg.sender]==0);
        require(msg.value >= invitePrice);
        owner.transfer(msg.value);
        inviteIndex += 1;
        userInviteId[msg.sender] = inviteIndex;
        inviteIdToAddress[inviteIndex] = msg.sender;
        return inviteIndex;
    }
    
    function getGameStats() public view returns(uint[], address[] ){
        // country_number
        uint[] memory result = new uint[](cardNumber+8+7);
        address[] memory addressResult = new address[](cardNumber+1);
        
        result[0] = cardNumber;
        result[1] = startTime;
        result[2] = endTime;
        result[3] = userInviteId[msg.sender];
        result[4] = inviteIndex;
        result[5] = fomoPot;
        result[6] = totalEx;
        for (uint k = 0; k < 8; k++) {
            result[k+7] = worldPot[k];
        }
        for (uint i = 0; i < cardNumber; i++) {
            result[i+15] = card_list[i].price;
        }
        
        addressResult[0] = lastBuyer;
        for (uint j = 0; j < cardNumber; j++) {
            addressResult[1+j] = card_list[j].owner;
        }
        return (result, addressResult);
    }
    
    function withdrawFomoPool() public {
        // game end 
        require(now > endTime);
        // the last buyer 
        require(msg.sender==lastBuyer);
        require(fomoPot > 0);
        lastBuyer.transfer(fomoPot);
        fomoPot = 0;
    }
    
    function withdrawWorldPool(uint cardId) public {
        require(cardId < 8);
        require(now > endTime);
        require(card_list[cardId].owner == msg.sender);
        require(worldPot[cardId] > 0);
        card_list[cardId].owner.transfer(worldPot[cardId]);
        worldPot[cardId] = 0;
    }   
    
    function changeVersion() onlyOwner public
    {
        // if someone forget to withdraw money in three days
        require(now > endTime + 3*24*60*60);
        owner.transfer(address(this).balance);
    }
    
    function myBalance() public view returns(uint) {
        return address(this).balance;
    }
}
