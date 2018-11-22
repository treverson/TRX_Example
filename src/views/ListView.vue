<template>
  <div class="has-text-white">
    <div v-if="loading"
         class="loader-wrapper">
      <pulse-loader></pulse-loader>
    </div>

    <div v-if="gameStart">
      <div class="has-text-centered is-size-4">
        结束倒计时
      </div>
    </div>
    <div v-else>
      <div class="has-text-centered is-size-4 tb">
        开始倒计时
      </div>
    </div>
    <div class="has-text-centered is-size-4">
        {{h}}:{{m}}:{{s}}
    </div>
    
    <div class="has-text-centered is-size-4">
        奖池
    </div>

    <div class="has-text-centered is-size-4">
      {{global[0].pool | short}}
    </div>
    <div class="tabs">
      <ul>
        <li class="is-active" id="tab-all" @click="showAll()"><a>英雄列表</a></li>
        <li @click="showMy()" id="tab-my" class="has-text-white"><a>我的英雄</a></li>
      </ul>
    </div>

    <div id="all-content">
      <div class="control">
        <label class="radio">
          <input type="radio" name="answer" v-model="order" value="dec">
          降序
        </label>
        <label class="radio">
          <input type="radio" name="answer" v-model="order" value="inc">
          升序
        </label>
      </div>
      <ItemList :items='realList' />
    </div>
    <div id="my-content">
      <ItemList :items='myList' />
    </div>
  </div>
</template>

<script>
import PulseLoader from 'vue-spinner/src/PulseLoader';
import ItemList from '@/components/ItemList';
import API, { eos } from '@/util/api';
import { mapActions, mapState } from 'vuex';

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
      total: null,
      gameStart: false,
      interval: 0,
      order: "dec"
    };
  },

  computed: {
    ...mapState(['scatterAccount']),
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
    myList() {
      if (!this.scatterAccount) {
        return [];
      }
      var newItems = $.extend(true, [], this.items);
      var result = [];
      for (var i=0; i< newItems.length; i++) {
        if (newItems[i].owner == this.scatterAccount.name) {
          result.push(newItems[i]);
        }
      }
      return result;
    }
  },
  async created() {
    this.currentTimestamp = Math.floor(Date.now() / 1000);
    this.updateLandsInfo();
    this.loading = false;
  },

  methods: {
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
    async updateLandsInfo() {
      function sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
      }
      var first = true;
      while (1) {
        this.items = await API.getLandsInfoAsync();
        this.global = await API.getGlobalInfoAsync();
        this.currentTimestamp = Math.floor(Date.now() / 1000);
        if (parseInt(this.global[0].st) > this.currentTimestamp) {
             this.gameStart = false;
             var interval = this.global[0].st - this.currentTimestamp;
             this.interval = interval;
        } else {
            this.gameStart = true;
            var interval = parseInt(this.global[0].ed) - this.currentTimestamp;
            if (interval > 0) {
                this.interval  = interval;
            } else {
                this.interval = 0;
            }
        }
          first = false;
        }
        if (this.interval > 0) {
            this.interval -= 1;
        }
        await sleep(1000);
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
  color: #eeeef3;
}
.demo-text {
  margin: auto;
  position: absolute;
  top: 0; left: 0; bottom: 0; right: 0;
  width: 100%;

  display: table;
  height: auto;

  color: #fcfcfc;
  text-transform: uppercase;
  text-align: center;

  font-size: 8em;
  font-family: 'Open Sans', sans-serif;
  font-weight: 800;

  letter-spacing: -0.02em;
  line-height: 1.2em;
}


</style>

