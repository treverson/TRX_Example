const PriceShorter = {
  formatPrice(price, unit = 'TRX') {
    return `${(price / 1000000).toFixed(2)} ${unit}`;
  },
  install(Vue) {
    Vue.filter('short', (value, unit) => PriceShorter.formatPrice(value, unit));
  },
};

export default PriceShorter;
