const PriceShorter = {
  formatPrice(price, unit = 'EOS') {
    return `${(price / 10000).toFixed(2)} ${unit}`;
  },
  install(Vue) {
    Vue.filter('short', (value, unit) => PriceShorter.formatPrice(value, unit));
  },
};

export default PriceShorter;
