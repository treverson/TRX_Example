import Vue from 'vue';
import Router from 'vue-router';
import ListView from '@/views/ListView';

Vue.use(Router);

export default new Router({
  "mode": "history",
  scrollBehavior: () => ({ y: 0 }),
  routes: [
    {
      name: 'Home',
      path: '/',
      component: ListView,
    },
  ],
});
