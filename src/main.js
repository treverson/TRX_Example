import Vue from 'vue';
import '@/util/prototypeExtend';
import Buefy from 'buefy';

import VueMoment from 'vue-moment';
import Transitions from 'vue2-transitions';
import VueClipboard from 'vue-clipboard2';
import router from '@/router';
import store from '@/store';
import i18n from '@/i18n';
import API from '@/util/api';
import PriceFormatter from '@/util/priceFormatter';
import PriceShorter from '@/util/priceShorter';
import App from '@/App.vue';
import VueLazyload from 'vue-lazyload'

import 'vue2-toast/lib/toast.css';
import Toast from 'vue2-toast';

// import Toastr
import Toastr from 'vue-toastr';
// import toastr scss file: need webpack sass-loader
require('vue-toastr/src/vue-toastr.scss');
// Register plugin
Vue.use(Toastr, { 
	defaultTimeout: 1500,
	defaultProgressBar: false,
	defaultProgressBarValue: 0,
	defaultType: "error",
	defaultPosition: "toast-top-center",
	defaultCloseOnHover: true,
})

Vue.config.productionTip = false;
Vue.use(Toast);
Vue.use(Buefy);
Vue.use(VueMoment);
Vue.use(Transitions);
Vue.use(VueClipboard);
Vue.use(PriceFormatter);
Vue.use(PriceShorter);
Vue.use(API);
Vue.use(VueLazyload)

new Vue({
  router,
  store,
  i18n,
  render: h => h(App),
}).$mount('#app');

