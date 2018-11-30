//const contractAddress = 'TTi6hyqnRSdwUgGt79r93DFZcLX52Ubnzd'
//const contractAddress = 'TYe2g7ZPzyjHameQJc4hVACuWbDcchH2js'
const contractAddress = 'TQmt7kpQnNd9hFbepfaRFcSrXachRNGrkT'
// const contractAddress = 'TYbLVvCqK5SJn7ej6pcQYBXGkW934t15E5'


const Utils = {
    tronWeb: false,
    contract: false,

    async setTronWeb(tronWeb) {
        this.tronWeb = tronWeb;
        if (this.tronWeb) {
          this.contract = await tronWeb.contract().at(contractAddress)
        }
        return this.tronWeb;
    },
    transferAddress(address) {
      if (address.startsWith("0x")) {
        address = "41" + address.slice(2);
      } else {
        address = "41" + address;
      }
      const result = this.tronWeb.address.fromHex(address);
      return result;
    },
    transformMessage(message) {
        return {
            tips: {
                amount: message.tips,
                count: message.tippers.toNumber()
            },
            owner: this.tronWeb.address.fromHex(message.creator),
            timestamp: message.time.toNumber(),
            message: message.message
        }
    },
    getCardImage(cardId) {
      return "http://static.togetthere.cn/sh" + cardId.toString() + ".jpg";
    },

    async fetchMessages(recent = {}, featured = []) {
        // Try to fetch messageID's of top 20 tipped messages (or until there are no more)
        for(let i = 0; i < 20; i++) {
            const message = await this.contract.topPosts(i).call();

            if(message.toNumber() === 0)
                break; // End of tips array

            featured.push(
                message.toNumber()
            );
        }

        // Fetch Max(30) most recent messages
        const totalMessages = (await this.contract.current().call()).toNumber();
        const min = Math.max(1, totalMessages - 30);

        const messageIDs = [ ...new Set([
            ...new Array(totalMessages - min).fill().map((_, index) => min + index),
            ...featured
        ])];

        await Promise.all(messageIDs.map(messageID => (
            this.contract.messages(messageID).call()
        ))).then(messages => messages.forEach((message, index) => {
            const messageID = +messageIDs[index];

            recent[messageID] = this.transformMessage(message);
        }));

        return {
            featured,
            recent
        };
    },

    async fetchMessage(messageID, { recent = {}, featured = [] }) {
        const message = await this.contract.messages(messageID).call();
        const vulnerable = Object.keys(recent).filter(messageID => (
            !featured.includes(messageID)
        )).sort((a, b) => (
            recent[b].timestamp - recent[a].timestamp
        ));

        recent[messageID] = this.transformMessage(message);

        if(vulnerable.length > 30) {
            const removed = vulnerable.splice(0, vulnerable.length - 30);

            removed.forEach(messageID => {
                delete recent[messageID];
            });
        }

        return {
            message: recent[messageID],
            recent,
            featured
        };
    },

    async fetchStats() {
        const data = await this.contract.getGameStats().call();
        const cardNumber = data[0][0];
        const startTime = data[0][1];
        const endTime = data[0][2];
        const inviteId = parseInt(data[0][3]);
        const inviteNumber = parseInt(data[0][4]);
        const fomoPot = data[0][5];
        const totalEx = parseInt(data[0][6]);
        const worldPot = data[0].slice(7,15);
        
        var result = {
          cardNumber: cardNumber,
          startTime: startTime,
          endTime: endTime,
          inviteId: inviteId,
          inviteNumber: inviteNumber,
          fomoPot: fomoPot,
          totalEx: totalEx,
          worldPot: worldPot,
          priceList: data[0].slice(15),
          lastBuyer: data[1][0].slice(2),
          ownerList: data[1].slice(1)
        }
        return result;
    }
};

export default Utils;
