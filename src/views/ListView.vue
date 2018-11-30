<template>
  <div class="has-text-white">
    <div v-if="loading"
         class="loader-wrapper">
      <pulse-loader></pulse-loader>
    </div>

    <div class="columns">
      <div class="column is-4"></div>
      <div class="column is-4">
        <figure class="image">
          <img src="/static/assets/logo.png">
        </figure>
      </div>
      <div class="column is-4">
        <div v-if="stats.inviteId" class="has-text-centered has-text-white shadow-bg is-size-4" style="border-radius: 5px;">
          Invite Link: <span class="has-text-success">http://xworld.io/?r={{stats.inviteId}}</span>
          <div class="has-text-danger"> Invite Link Sold: {{stats.inviteNumber}} </div>
        </div>
        <div v-else class="has-text-white has-text-centered shadow-bg">
          <div class="has-text-danger is-size-3"> Invite to get 5% earning!! =>
          <span class="button is-success is-outlined" style="border-radius: 8px;" @click="buyInviteIdAsync()"> Buy Invite Link at 100Trx</span>
          </div>
          <div class="has-text-danger"> Invite Link Sold: {{stats.inviteNumber}} </div>
        </div>
      </div>
    </div>

    <div v-if="gameStart">
      <div class="has-text-centered is-size-2">
        Ending Countdown
      </div>
    </div>
    <div v-else>
      <div class="has-text-centered is-size-2">
        Start Countdown
      </div>
    </div>
    <div class="has-text-centered is-size-2 atext">
        {{h}}:{{m}}:{{s}}
    </div>
    

    <div class="columns" style="padding-bottom: 1rem;padding-top: 1rem;">
      <div class="column is-2"></div>
      <div class="column is-4 has-text-centered sbg is-size-4">
        <div>The Top Country</div>
        <div class="atext"> {{getCardName(countryKingId)}} </div>
      </div>

      <div class="column is-4 has-text-centered sbg is-size-4">
        <div>The Top Player</div>
        <div class="atext"> {{transferAddress(stats.ownerList[countryKingId]).slice(0, 12)}} </div>
      </div>

      <div class="column is-4">

        <a href="https://t.me/xworldio" target="_blank" class="button sbg2" style="border: 0px solid transparent; margin-top: 1.8rem; margin-left: 3rem;">
          <i class="iconfont icon-telegram has-text-white" style="font-size: 18px;"></i>
        </a>

        <a href="https://discord.gg/67HvHqe" target="_blank" class="button sbg2" style="border: 0px solid transparent; margin-top: 1.8rem; margin-left: 1rem;">
          <i class="iconfont icon-discord has-text-white" style="font-size: 18px;"></i>
        </a>


      </div>
    </div>


    <div class="columns is-multiline">
      
      
      <div class="column is-3 has-text-centered sbg is-size-4">
        <div>Total TRX Invest</div>
        <div class="atext">{{stats.totalEx | short}}</div>
      </div>
      
      <div class="column is-3 has-text-centered sbg is-size-4">
        <div>Last Buyer</div>
        <div class="atext">{{transferAddress(stats.lastBuyer).slice(0,6)}}</div>
      </div>
  
      <div class="column is-3 has-text-centered sbg is-size-4">
        <div>Last Buyer Pot</div>
        <div class="atext">{{stats.fomoPot | short }}</div>
        <div v-if="gameEnd && (transferAddress(stats.lastBuyer)==address) && stats.fomoPot>0" class="button is-success is-outlined" @click="withdrawFomoPot()"> Withdraw </div>
      </div>

      <div class="column is-3 has-text-centered sbg is-size-4">
        <div>World Owner</div>
        <div class="atext">{{transferAddress(stats.ownerList[0]).slice(0,6)}}</div>
      </div>

      <div class="column is-3 has-text-centered sbg is-size-4">
        <div>World Pot</div>
        <div class="atext">{{stats.worldPot[0] | short }}</div>
        <span v-if="gameEnd && (transferAddress(stats.ownerList[0])==address) && stats.worldPot[0]>0" class="button is-success is-outlined" @click="withdrawWorldPool(0)"> Withdraw </span>
      </div>

      <div v-for="item in items.slice(1,8)" class="column is-3 has-text-centered sbg is-size-4">
        <div> {{getCardName(item.id)}} Pot</div>
        <div class="atext"> {{transferAddress(item.owner).slice(0,6)}}</div>
        <div class="atext"> {{stats.worldPot[item.id] | short }}</div>
        <div v-if="gameEnd && (transferAddress(item.owner)==address) && stats.worldPot[item.id]>0" class="button is-success is-outlined" @click="withdrawWorldPool(item.id)"> Withdraw </div>
      </div>

    </div>



    <div class="tabs">
      <ul>
        <li class="is-active has-text-black" id="tab-all" @click="showAll()"><a>Area</a></li>
        <li class="has-text-black" @click="showMy()" id="tab-my"><a>My Area</a></li>
      </ul>
    </div>

    <div id="all-content">
      <div class="control has-text-black">
        <label class="radio">
          <input type="radio" name="answer" v-model="order" value="dec">
          Desc
        </label>
        <label class="radio">
          <input type="radio" name="answer" v-model="order" value="inc">
          Asc
        </label>
      </div>
      <ItemList :items='realList' :endTime="endTime" />
    </div>
    <div id="my-content">
      <ItemList :items='myList' :endTime="endTime" />
    </div>
  </div>
</template>

<script>
import PulseLoader from 'vue-spinner/src/PulseLoader';
import ItemList from '@/components/ItemList';
import API, { eos } from '@/util/api';
import { mapActions, mapState } from 'vuex';
import Utils from '@/utils';
import TronWeb from 'tronweb';
import * as config from '@/config';
import swal from 'sweetalert2';

export default {
  name: 'item-list',
  components: {
    PulseLoader,
    ItemList,
  },

  data() {
    return {
      loading: true,
      items: [],
      global: [{
        "st": 1542884400,
        "ed": 1542884400 + 12*60*60,
        "pool": 0
      }],
      stats: {
      },
      startTime: 0,
      endTime: 0,
      total: null,
      gameStart: false,
      gameEnd: false,
      interval: 0,
      inviteCode: 1,
      order: "dec"
    };
  },

  computed: {
    ...mapState(['scatterAccount', 'tronWeb']),
            h: function() {
                var intervalHour = parseInt(this.interval/3600);
                if (intervalHour < 10) {
                  return "0"+ intervalHour;
                } else {
                  return intervalHour.toString();
                }
            },
            m: function() {
              var intervalMinute = parseInt((this.interval % 3600)/60);
              if (intervalMinute < 10) {
                return "0" + intervalMinute;
              } else {
                return intervalMinute.toString();
              }
            },
            s: function() {
              var intervalSecond = this.interval % 60;
              if (intervalSecond < 10) {
                return "0" + intervalSecond;
              } else {
                return intervalSecond.toString();
              }
            },
    realList() {
      var newItems = $.extend(true, [], this.items);
      if (this.order == "dec") {
        newItems.sort(function(first, second) {
          if (second.price - first.price > 0) {
            return 1;
          }
          if (first.price - second.price > 0) {
            return -1;
          }
          return parseInt(first.id) - parseInt(second.id);
        });
      } else {
        newItems.sort(function(first, second) {
          if (second.price - first.price > 0) {
            return -1;
          }
          if (first.price - second.price > 0) {
            return 1;
          }
          return parseInt(first.id) - parseInt(second.id);
        });
      }
      return newItems;
    },
    countryKingId() {
      var newItems = $.extend(true, [], this.items);
      newItems.sort(function(first, second) {
        if (second.price - first.price > 0) {
          return 1;
        }
        if (first.price - second.price > 0) {
          return -1;
        }
        return parseInt(first.id) - parseInt(second.id);
      });
      for (var i=0; i<newItems.length; i++) {
        if (newItems[i].id >= 8) {
          return newItems[i].id;
        }
      }
    },
    myList() {
      var newItems = $.extend(true, [], this.items);
      var result = [];
      for (var i=0; i< newItems.length; i++) {
        if (this.transferAddress(newItems[i].owner)==this.address) {
          result.push(newItems[i]);
        }
      }
      return result;
    }
  },
  async created() {
    function sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
    for (var i = 0; i < 100; i++) {
      if (!!window.tronWeb) {
        break;
      } else {
        await sleep(10);
      }
    }
    const FOUNDATION_ADDRESS = 'TWiWt5SEDzaEqS6kE5gandWMNfxR2B5xzg';
    
    const result = await Utils.setTronWeb(window.tronWeb);
    if (!result) {
      swal({
            title: 'Tron Wallet Needed or You Need Unlock Your Wallet',
            type: 'error'
        })
    }
    const tronWebState = {
        installed: !!window.tronWeb,
        loggedIn: window.tronWeb && window.tronWeb.ready
    };
    this.$store.commit('setTronWeb', tronWebState);
    this.updateCardInfo();
    this.currentTimestamp = Math.floor(Date.now() / 1000);
    this.loading = false;
  },

  methods: {
    transferAddress(address) {
      return Utils.transferAddress(address);
    },
    getInviteCode() {
              var sPageURL = decodeURIComponent(window.location.search.substring(1)),
              sURLVariables = sPageURL.split('&'),
              sParameterName,
              i;

              for (i = 0; i < sURLVariables.length; i++) {
                  sParameterName = sURLVariables[i].split('=');

                  if (sParameterName[0] === "r") {
                      return sParameterName[1] === undefined ? "": sParameterName[1];
                 }
              }
              return 1;
    },
    showAll() {
      $("#tab-all").addClass("is-active");
      $("#tab-all").addClass("active");
      $("#tab-my").removeClass("is-active");
      $("#tab-my").removeClass("active");
      $("#all-content").show();
      $("#my-content").hide();
    },
    showMy() {
      $("#tab-my").addClass("is-active");
      $("#tab-my").addClass("active");
      $("#tab-all").removeClass("is-active");
      $("#tab-all").removeClass("active");
      $("#my-content").show();
      $("#all-content").hide();
    },
    getCardName(id) {
      const name  = config.cards[id].name;
      return name;
    },
    withdrawFomoPot() {
      if (!this.tronWeb.loggedIn) {
        this.$toastr.e("No Tron Account. Found. Try Refresh This Page.");
        return;
      }
      // buy
      Utils.contract.withdrawFomoPool().send({
            shouldPollResponse: true,
            callValue: 0 
      }).then(res => {
        this.$toastr.s("Withdraw Success. Please wait ...");
       }).catch(err => {
         this.$toastr.e("Withdraw Failed. Please retry...");
        }).then(err => {
        });
      this.isScatterPaying = false;
      return null;
    },
    withdrawWorldPool(cardId) {
      if (!this.tronWeb.loggedIn) {
        this.$toastr.e("No Tron Account. Found. Try Refresh This Page.");
        return;
      }
      // buy
      Utils.contract.withdrawWorldPool(cardId).send({
            shouldPollResponse: true,
            callValue: 0
      }).then(res => {
        this.$toastr.s("Withdraw Success. Please wait ...");
       }).catch(err => {
         this.$toastr.e("Withdraw Failed. Please retry...");
        }).then(err => {
        });
      this.isScatterPaying = false;
      return null;
    },
    buyInviteIdAsync() {
      if (!this.tronWeb.loggedIn) {
        this.$toastr.e("No Tron Account. Found. Try Refresh This Page.");
        return;
      }
      // buy
      const invitePrice = 100000000;
      Utils.contract.buyInviteId().send({
            shouldPollResponse: true,
            callValue: invitePrice 
      }).then(res => {
        this.$toastr.s("Buy Success. Please wait ...");
       }).catch(err => {
         this.$toastr.e("Buy Failed.");
        }).then(err => {
        });
      this.isScatterPaying = false;
      return null;
    },
    async updateCardInfo() {
      function sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
      }
      var first = true;
      while (1) {
        const stats = await Utils.fetchStats();
        this.stats = stats;
        this.cardNumber = stats.cardNumber;
        this.startTime = stats.startTime;
        this.endTime = stats.endTime;
        this.priceList = stats.priceList
        this.ownerList = stats.ownerList
        this.address = Utils.tronWeb.defaultAddress.base58;
        this.transferAddress(stats.lastBuyer);
        // alert(this.ownerList[0]);
        // alert(this.transferAddress(this.ownerList[0]));
        // alert(this.address);
        var result = [];
        for (var i = 0; i < this.cardNumber; i++) {
          result.push({
            id: i,
            price: parseInt(this.priceList[i]),
            owner: this.ownerList[i]
          });
        }
        this.items = result;
        this.currentTimestamp = Math.floor(Date.now() / 1000);
        if (parseInt(this.startTime) > this.currentTimestamp) {
             this.gameStart = false;
             var interval = this.startTime - this.currentTimestamp;
             this.interval = interval;
        } else {
            this.gameStart = true;
            var interval = parseInt(this.endTime) - this.currentTimestamp;
            if (interval > 0) {
                this.interval  = interval;
            } else {
                this.interval = 0;
                this.gameEnd = true;
            }
        }
        if (this.interval > 0) {
            this.interval -= 1;
        }
        await sleep(1000);
      }
    },
    ...mapActions(['updateLandInfoAsync']),
    toDisplayedPrice(priceInWei) {
      const readable = toReadablePrice(priceInWei);
      return `${readable.price} ${readable.unit}`;
    },
  },
  watch: {},
  filter: {
      onlyMy: function (itemList) {
        if (!this.scatterAccount) {
          return [];
        } else {
          const result = itemList.filter(word => word.owner==this.scatterAccount.name);
          return result;
        }
    }
  }
};
</script>
<style scoped>
.loader-wrapper {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100vh;
}
.tabs a {
  color: #000;
}

.tabs li.is-active a {
  color: #fff;
}

.shadow-bg {
    background: rgba(0,0,0,0.7);
    border-radius: 8px;
}

.sbg {
    background: rgba(0,0,0,0.5);
    border-radius: 8px;
}

.atext {
  text-shadow: #cd9f6e 0 0 5px, #cdc690 0 0 20px, #cdcfa6 0 0 10px;
}

.sbg2 {
    background: rgba(0,0,0,0.8);
    border-radius: 8px;
}

</style>

