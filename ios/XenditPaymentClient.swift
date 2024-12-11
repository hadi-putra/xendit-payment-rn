import Foundation
import Xendit
import UIKit
import React

enum ValidationError: Error {
  case badRequest(message: String)
}

@objc(XenditPaymentClient)
class XenditPaymentClient: NSObject {

  @objc(multiply:withB:withResolver:withRejecter:)
  func multiply(a: Float, b: Float, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
    resolve(a*b)
  }

  @objc(initialize:)
  func initialize(publicKey: String) -> Void {
    Xendit.publishableKey = publicKey
  }

  @objc(createSingleUseToken:withAmount:shouldAuthenticate:withOnBehalfOf:withCurrency:withBillingDetails:withCustomer:withResolver:withRejecter:)
  func createSingleUseToken(cardDict: NSDictionary, amount: NSNumber,
                            shouldAuthenticate: Bool,
                            onBehalfOf: String = "", currency: String = "IDR",
                            billingDetails: NSDictionary? = nil,
                            customer: NSDictionary? = nil,
                            resolve: @escaping RCTPromiseResolveBlock, 
                            reject: @escaping RCTPromiseRejectBlock) -> Void {
    do {
      let xenditCard = try self.mapToCardData(cardDict:cardDict)
      DispatchQueue.main.async {
        let tokenizationRequest = XenditTokenizationRequest.init(cardData: xenditCard, isSingleUse: true, shouldAuthenticate: shouldAuthenticate, amount: amount, currency: currency)
        if let billing = billingDetails {
          tokenizationRequest.billingDetails = self.maptToBillingDetail(billingDict: billing)
        }
        if let _customer = customer {
          tokenizationRequest.customer = self.mapToCustomer(customerDict: _customer)
        }
        let rootViewController = UIApplication.shared.delegate?.window??.rootViewController ?? UIViewController()
        Xendit.createToken(fromViewController: rootViewController, tokenizationRequest: tokenizationRequest, onBehalfOf: onBehalfOf) {
          (token, error) in
          if let _token = token {
            resolve(self.tokenToMap(token:_token))
          } else {
            reject(error?.errorCode, error?.message, error as? Error)
          }
        }
      }
    } catch {
      reject("BAD_REQUEST", "WRONG INPUT", nil)
    }
  }

  @objc(createMultipleUseToken:withOnBehalfOf:withMidLabel:withBillingDetails:withCustomer:withResolver:withRejecter:)
  func createMultipleUseToken(cardDict: NSDictionary, 
                            onBehalfOf: String = "",
                            midLabel: String? = nil,
                            billingDetails: NSDictionary? = nil,
                            customer: NSDictionary? = nil,
                            resolve: @escaping RCTPromiseResolveBlock, 
                            reject: @escaping RCTPromiseRejectBlock) -> Void {
    do {
      let xenditCard = try self.mapToCardData(cardDict:cardDict)
      DispatchQueue.main.async {
        let tokenizationRequest = XenditTokenizationRequest.init(cardData: xenditCard, isSingleUse: false, shouldAuthenticate: true, amount: nil, currency: nil)
        if let billing = billingDetails {
          tokenizationRequest.billingDetails = self.maptToBillingDetail(billingDict: billing)
        }
        if let _customer = customer {
          tokenizationRequest.customer = self.mapToCustomer(customerDict: _customer)
        }
        if let _midLabel = midLabel {
          tokenizationRequest.midLabel = _midLabel
        }

        let rootViewController = UIApplication.shared.delegate?.window??.rootViewController ?? UIViewController()
        Xendit.createToken(fromViewController: rootViewController, tokenizationRequest: tokenizationRequest, onBehalfOf: onBehalfOf) {
          (token, error) in
          if let _token = token {
            resolve(self.tokenToMap(token:_token))
          } else {
            reject(error?.errorCode, error?.message, error as? Error)
          }
        }
      }
    } catch {
      reject("BAD_REQUEST", "WRONG INPUT", nil)
    }
  }

  @objc(createAuthentication:withAmount:withCurrency:withCardCvn:withOnBehalfOf:withMidLabel:withCardHolder:withResolver:withRejecter:)
  func createAuthentication(tokenId: String, amount: NSNumber, 
                            currency: String = "IDR", cardCvn: String? = nil,
                            onBehalfOf: String = "", midLabel: String? = nil,
                            cardHolder: NSDictionary? = nil,
                            resolve: @escaping RCTPromiseResolveBlock, 
                            reject: @escaping RCTPromiseRejectBlock) -> Void {
    
    DispatchQueue.main.async {

      if let _cardHolder = cardHolder {
        self.mapToCardHolder(cardHolderDict: _cardHolder)
      }

      let authenticationRequest = XenditAuthenticationRequest.init(tokenId: tokenId, amount: amount, currency: currency, cardData: _cardHolder)

      if let _midLabel = midLabel {
        authenticationRequest.midLabel = _midLabel
      }

      if let _cardCvn = cardCvn {
        authenticationRequest.cardCvn = cardCvn
      }

      let rootViewController = UIApplication.shared.delegate?.window??.rootViewController ?? UIViewController()
      Xendit.createAuthentication(fromViewController: rootViewController, authenticationRequest: authenticationRequest, onBehalfOf: onBehalfOf) {
        (authentication, error) in
        if let _authentication = authentication {
          resolve(self.authenticationToMap(authentication:_authentication))
        } else {
          reject(error?.errorCode, error?.message, error as? Error)
        }
      }
    }
  }

  private func mapToCardData(cardDict: NSDictionary) throws -> XenditCardData {
    guard let cardNumber = cardDict["cardNumber"] as? String,
          let cardExpMonth = cardDict["cardExpMonth"] as? String, 
          let cardExpYear = cardDict["cardExpYear"] as? String else {
      throw ValidationError.badRequest(message: "Bad Request")
    }

    let xenditCard = XenditCardData.init(cardNumber:cardNumber, cardExpMonth:cardExpMonth, cardExpYear:cardExpYear)
    xenditCard.cardCvn = cardDict["cardCvn"] as? String

    if let cardHolderDict = cardDict["cardHolder"] as? NSDictionary {
      xenditCard.cardHolderFirstName = cardHolderDict["firstName"] as? String
      xenditCard.cardHolderLastName = cardHolderDict["lastName"] as? String
      xenditCard.cardHolderEmail = cardHolderDict["email"] as? String
      xenditCard.cardHolderPhoneNumber = cardHolderDict["phoneNumber"] as? String
    }

    return xenditCard
  }

  private func maptToBillingDetail(billingDict: NSDictionary) -> XenditBillingDetails? {
    if billingDict.allKeys.isEmpty {
      return nil
    }
    
    let billingDetails = XenditBillingDetails.init()
    
    billingDetails.givenNames = billingDict["givenNames"] as? String
    billingDetails.middleName = billingDict["middleName"] as? String
    billingDetails.surname = billingDict["surname"] as? String
    billingDetails.email = billingDict["emai"] as? String
    billingDetails.phoneNumber = billingDict["phoneNumber"] as? String
    billingDetails.mobileNumber = billingDict["mobileNumber"] as? String
    
    if let addressDict = billingDict["address"] as? NSDictionary {
      billingDetails.address = self.mapToAddress(addressDict: addressDict)
    }
    
    return billingDetails
  }

  private func mapToAddress(addressDict: NSDictionary) -> XenditAddress? {
    if addressDict.allKeys.isEmpty {
      return nil
    }
    
    let address = XenditAddress.init()
    
    address.category = addressDict["category"] as? String
    address.city = addressDict["city"] as? String
    address.country = addressDict["country"] as? String
    address.postalCode = addressDict["postalCode"] as? String
    address.provinceState = addressDict["provinceState"] as? String
    address.streetLine1 = addressDict["streetLine1"] as? String
    address.streetLine2 = addressDict["streetLine2"] as? String
    
    return address
  }

  private func mapToCustomer(customerDict: NSDictionary) -> XenditCustomer? {
    if customerDict.allKeys.isEmpty {
      return nil
    }
    
    let customer = XenditCustomer.init()
    
    customer.referenceId = customerDict["referenceId"] as? String
    customer.givenNames = customerDict["givenNames"] as? String
    customer.surname = customerDict["surname"] as? String
    customer.email = customerDict["emai"] as? String
    customer.phoneNumber = customerDict["phoneNumber"] as? String
    customer.mobileNumber = customerDict["mobileNumber"] as? String
    customer.description = customerDict["description"] as? String
    customer.dateOfBirth = customerDict["dateOfBirth"] as? String
    customer.nationality = customerDict["nationality"] as? String
    
    return customer
  }

  private func mapToCardHolder(cardHolderDict: NSDictionary?) -> XenditCardHolderInformation? {
    if let _cardHolderDict = cardHolderDict {
      if _cardHolderDict.allKeys.isEmpty {
        return nil
      }

      let xenditCardHolder = XenditCardHolderInformation.init();

      xenditCardHolder.cardHolderFirstName = _cardHolderDict["firstName"] as? String
      xenditCardHolder.cardHolderLastName = _cardHolderDict["lastName"] as? String
      xenditCardHolder.cardHolderEmail = _cardHolderDict["email"] as? String
      xenditCardHolder.cardHolderPhoneNumber = _cardHolderDict["phoneNumber"] as? String

      return xenditCardHolder;
    } else {
      return nil
    }
  }

  private func tokenToMap(token: XenditCCToken) -> NSDictionary {
    let tokenDict: NSDictionary = [
      "id":token.id!,
      "authenticationId":token.authenticationId ?? NSNull(),
      "status":token.status!,
      "authenticationUrl":token.authenticationURL ?? NSNull(),
      "maskedCardNumber":token.maskedCardNumber ?? NSNull(),
      "should3DS":token.should3DS ?? false,
      "failureReason":token.failureReason ?? NSNull(),
      "cardInfo":self.cardMetaDataToMap(cardMetaData: token.cardInfo) ?? NSNull()
    ]
    
    return tokenDict
  }

  private func cardMetaDataToMap(cardMetaData: XenditCardMetadata?) -> NSDictionary? {
    if let data = cardMetaData {
      let metaDict: NSDictionary = [
        "bank":data.bank ?? NSNull(),
        "country":data.country ?? NSNull(),
        "type":data.type ?? NSNull(),
        "brand":data.brand ?? NSNull(),
        "cardArtUrl":data.cardArtUrl ?? NSNull(),
        "fingerprint":data.fingerprint ?? NSNull()
      ]
      
      if metaDict.allValues.allSatisfy({ $0 is NSNull }){
        return nil
      }
      
      return metaDict
    } else {
      return nil
    }
  }

  private func authenticationToMap(authentication: XenditAuthentication) -> NSDictionary {
    let authDict:NSDictionary = [
      "id":authentication.id ?? NSNull(),
      "cardTokenId":authentication.tokenId ?? NSNull(),
      "status":authentication.status!,
      "authenticationUrl":authentication.authenticationURL ?? NSNull(),
      "authenticationTransactionId":authentication.authenticationTransactionId ?? NSNull(),
      "requestPayload": authentication.requestPayload ?? NSNull(),
      "maskedCardNumber":authentication.maskedCardNumber ?? NSNull(),
      "threedsVersion": authentication.threedsVersion ?? NSNull(),
      "failureReason":authentication.failureReason ?? NSNull(),
      "cardInfo":self.cardMetaDataToMap(cardMetaData: authentication.cardInfo) ?? NSNull()
    ]

    return authDict
  }
}
