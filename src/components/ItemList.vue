<template>
  <div class="columns is-multiline is-mobile">
    <div v-for="item in items"
                 v-if="item &&(item.id!=69)&&(item.id!=64)"
                 :key=item.id.toString()
                 class="column
           is-half-mobile
           is-one-quarter-tablet
           is-3-desktop
           is-3-widescreen
           is-3-fullhd">
      <template>
        <div class="card" style="border-radius: 10px;">
          <div class="card-image" style="border: 1rem solid black; border-radius: 5px; background-color: #000;">
            <div class="columns" style="height: 5rem;">
              <div class="column is-5">
                <figure class="image is-16by9">
                  <img class="" v-lazy="getCardFlag(item.id)" style="border-radius: 5px;">
                </figure>
              </div>
            </div>
            <figure class="image is-5by4">
              <img class="is-rounded" v-lazy="getCardImage(item.id)">
            </figure>
          </div>
          <div class="card-content">
            <div class="content is-small has-text-centered">
              <div class="is-size-5"> {{getCardName(item.id)}}</div>
              <div>
                {{$t('Owner')}}：
                  <span v-if="item.owner"
                               :to="{ name: 'User', params:{address: item.owner}}">
                    {{transferAddress(item.owner).slice(0, 12)}}
                  </span>
              </div>
              <div class="button is-fullwidth is-info" @click="buyCardAsync(item.id, item.price)" style="border-radius: 8px;"> 
                <div> {{item.price | short}} </div>
              </div>
            </div>
          </div>
        </div>
      </template>
    </div>
  </div>
</template>

<script>
import API from '@/util/api';
import * as config from '@/config';
import { mapState, mapActions } from 'vuex';
import Utils from '@/utils';
import TronWeb from 'tronweb';
import swal from 'sweetalert';

export default {
  name: 'item-lists',
  props: ['items', 'endTime'],

  data: () => ({
    inviteCode: 1
  }),

  computed: {
     ...mapState(['scatterAccount', 'tronWeb']),
  },

  methods: {
    transferAddress(address) {
      return Utils.transferAddress(address);
    },
    getCardImage(id) {
      const imageId = config.cards[id].image_id;
      var image = '';
      if (id > 7) {
        if (id==65) {
          image = "http://static.togetthere.cn/bigcn.png";
        } else {
          image = `http://static.togetthere.cn/${imageId}.svg`;
        }
      } else {
        image = `http://static.togetthere.cn/${imageId}.png`;
      }
      return image;
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
    getCardFlag(id) {
      const imageId = config.cards[id].image_id;
      const image = `http://static.togetthere.cn/${imageId}.png`;
      return image;
    },
    getCardName(id) {
      name = config.cards[id].name;
      return name;
    },
    nextPrice(item_price) {
      return this.$API.getNextPrice(item_price);
    },
    async buyCardAsync(cardId, cardPrice) {
      const game_time = 1543492800;
      this.currentTimestamp = Math.floor(Date.now() / 1000);
      if (this.currentTimestamp < game_time) {
        this.$toastr.e("Game will start in"+(game_time- this.currentTimestamp).toString()+"seconds");
        return;
      }
      if (this.currentTimestamp > this.endTime) {
        this.$toastr.e("Game Already End.");
        return;
      }
      if (!this.tronWeb.loggedIn) {
        this.$toastr.e("No Tron Account. Found. Try Refresh This Page.");
        return;
      }
      // buy
      Utils.contract.buyCard(cardId, this.inviteCode).send({
            shouldPollResponse: true,
            callValue: cardPrice
      }).then(res => {
        this.$toastr.s("Buy Success. Please wait ...");
       }).catch(err => {
         this.$toastr.e("Buy Failed.");
        }).then(err => {
        });
        this.isScatterPaying = false;
        return null;
    },
    isMobile() {
      var check = false;
      (function(a){if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4))) check = true;})(navigator.userAgent||navigator.vendor||window.opera);
       return check;
    },
  },

  created() {
    this.inviteCode = this.getInviteCode();
  },

  watch: {
  },
  filters: {
    shortName: function (value) {
      if (!value) return ''
      value = value.toString()
      return value.slice(0, -4);
    }
  }
};
</script>
 <style scoped>
.item-slogan {
  overflow-wrap: break-word;
  word-wrap: break-word;
  word-break: break-all;
}
</style>

