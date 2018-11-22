<template>
  <header>
    <nav class="navbar is-light">
      <div class="navbar-brand">
        <router-link class="navbar-item"
                     :to="{ name: 'Home'}">
          <img src="/static/assets/logo.png">&nbsp;&nbsp; 快神话 
        </router-link>

        <a class="navbar-item" href="/static/assets/shenhua.pdf" target="_blank">
          游戏规则
        </a>

        <!-- <router-link class="navbar-item"
                     :to="{ name: 'BirthdayGift'}">
          {{$t('BirthdayGift')}}
        </router-link>         -->
      </div>

      <div class="navbar-end">
        <div v-if="scatterAccount" class="navbar-item">
          <div class="">
            {{scatterAccount.name}}
          </div>
        </div>
        <div v-else class="navbar-item">
          <button class="button is-primary" @click="loginScatterAsync">
          登录
          </button>
        </div>
      </div>

    </nav>
    <div v-if="infos.length > 0" class="notification is-danger content" >
        <p v-for="(info,index) in infos" :key="index">{{info}}</p>
    </div>
  </header>
</template>

<script>
import { mapActions, mapState } from 'vuex';


export default {
  name: 'Header',
  data() {
    return {
      network: {},
      infos: [],
    };
  },
  async created() {
  },
  methods: {
     ...mapActions(['connectScatterAsync', 'updateLandInfoAsync', 'loginScatterAsync', 'logoutScatterAsync', 'updateMarketInfoAsync', 'getGlobalInfo']),
    toast() {
      this.$toastr.s("test");
    },
  },
  computed: {
    ...mapState(['scatterAccount']),
    me() {
      return this.$store.state.me;
    },
  },
  watch: {
  },
};
</script>

<style>
.neon1 {
  color: #fff;
  font-family: Monoton;
  -webkit-animation: neon1 1.5s ease-in-out infinite alternate;
  -moz-animation: neon1 1.5s ease-in-out infinite alternate;
  animation: neon1 1.5s ease-in-out infinite alternate;
}

.neon1:hover {
  color: #FF1177;
  -webkit-animation: none;
  -moz-animation: none;
  animation: none;
}

</style>
