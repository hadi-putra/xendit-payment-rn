import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'xendit-payment-rn' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const XenditPaymentClient = NativeModules.XenditPaymentClient
  ? NativeModules.XenditPaymentClient
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export interface CardHolder {
  firstName: string;
  lastName: string;
  email?: string;
  phoneNumber?: string;
}

export interface CardInfo {
  cardNumber: string;
  cardExpMonth: string;
  cardExpYear: string;
  cardVcn?: string;
  cardHolder: CardHolder;
}

export interface BillingDetail {
  givenNames?: string;
  middleName?: string;
  surname?: string;
  email?: string;
  phoneNumber?: string;
  mobileNumber?: string;
  address?: BillingAddress;
}

export interface BillingAddress {
  category?: string;
  city?: string;
  country?: string;
  postalCode?: string;
  provinceState?: string;
  streetLine1?: string;
  streetLine2?: string;
}

export interface Customer {
  referenceId?: string;
  givenNames?: string;
  surname?: string;
  email?: string;
  phoneNumber?: string;
  mobileNumber?: string;
  description?: string;
  dateOfBirth?: string;
  nationality?: string;
}

export interface Token {
  id: string;
  status: string;
  maskedCardNumber: string;
  should3DS: boolean;
  authenticationId?: string;
  failureReason?: string;
  cardInfo?: CardDetail;
}

export interface Authentication {
  id: string;
  cardTokenId: string;
  authenticationUrl?: string;
  status: string;
  maskedCardNumber: string;
  requestPayload?: string;
  authenticationTransactionId?: string;
  threedsVersion?: string;
  failureReason?: string;
  cardInfo?: CardDetail;
}

export interface CardDetail {
  bank?: string;
  country?: string;
  type?: string;
  brand?: string;
  cardArtUrl?: string;
  fingerprint?: string;
}

export class XenditPayment {
  async multiply(a: number, b: number): Promise<number> {
    return XenditPaymentClient.multiply(a, b);
  }

  initialize(publicKey: string) {
    XenditPaymentClient.initialize(publicKey);
  }

  async createSingleUseToken(
    cardInfo: CardInfo,
    amount: number,
    shouldAuthenticate: boolean = false,
    onBehalfOf: string = '',
    currency: string = 'IDR',
    billingDetails?: BillingDetail,
    customer?: Customer
  ): Promise<Token> {
    return XenditPaymentClient.createSingleUseToken(
      cardInfo,
      amount,
      shouldAuthenticate,
      onBehalfOf,
      currency,
      billingDetails,
      customer
    );
  }

  async createMultipleUseToken(
    cardInfo: CardInfo,
    onBehalfOf: string = '',
    midLabel?: string,
    billingDetails?: BillingDetail,
    customer?: Customer
  ): Promise<Token> {
    return XenditPaymentClient.createMultipleUseToken(
      cardInfo,
      onBehalfOf,
      midLabel,
      billingDetails,
      customer
    );
  }

  async createAuthentication(
    tokenId: string,
    amount: number,
    currency: string = 'IDR',
    onBehalfOf: string = '',
    cardVcn?: string,
    midLabel?: string,
    cardHolder?: CardHolder
  ): Promise<Authentication> {
    return XenditPaymentClient.createAuthentication(
      tokenId,
      amount,
      currency,
      cardVcn,
      onBehalfOf,
      midLabel,
      cardHolder
    );
  }
}
