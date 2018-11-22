import { networks } from './network';
import cardsRaw from './cards.json';

export const appScatterName = 'CryptoMeetup';

export const network = networks.eosasia;

export const cards = cardsRaw;

export const i18n = [
  {
    locale: 'zh',
    aliases: ['zh', 'zh-cn', 'zh-hk', 'zh-sg', 'zh-tw'],
  },
];

export const referrerStorageKey = 'cryptomeetup_referrer';
