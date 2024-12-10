package com.xenditpaymentrn

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReadableMap
import com.xendit.AuthenticationCallback
import com.xendit.Models.Authentication
import com.xendit.Models.Token
import com.xendit.Models.XenditError
import com.xendit.TokenCallback
import com.xendit.Xendit

class XenditPaymentClientModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  private lateinit var xendit: Xendit

  override fun getName(): String {
    return NAME
  }

  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  @ReactMethod
  fun multiply(a: Double, b: Double, promise: Promise) {
    promise.resolve(a * b)
  }

  @ReactMethod
  fun initialize(publicKey: String) {
    xendit = Xendit(reactApplicationContext, publicKey)
  }

  @ReactMethod
  fun createSingleUseToken(card: ReadableMap, amount: Double, 
                          shouldAuthenticate: Boolean,
                          onBehalfOf: String = "",
                          currency: String = "IDR",
                          billingDetails: ReadableMap? = null,
                          customer: ReadableMap? = null,
                          promise: Promise) {
    if (!this::xendit.isInitialized) {
      promise.reject(Throwable("Xendit hasn't been initialized. Please call init function"))
      return
    }

    xendit.createSingleUseToken(createCardObj(card), amount.toString(), shouldAuthenticate, onBehalfOf,
      billingDetails?.let { createBillingDetailsObject(it) }, 
      customer?.let { createCustomerObject(it) }, currency, object : TokenCallback() {
          override fun onSuccess(token: Token?) {
            promise.resolve(token?.toWritableMap())
          }

          override fun onError(error: XenditError?) {
            if (error == null){
              promise.reject("BAD_REQUEST", "Authentication Error")
            } else {
              promise.reject(error.errorCode, error.errorMessage)
            }
          }

      })
  }

  @ReactMethod
  fun createMultipleUseToken(card: ReadableMap, onBehalfOf: String = "", midLabel: String? = null,
                          billingDetails: ReadableMap? = null, customer: ReadableMap? = null,
                          promise: Promise) {
    if (!this::xendit.isInitialized) {
      promise.reject(Throwable("Xendit hasn't been initialized. Please call init function"))
      return
    }

    xendit.createMultipleUseToken(createCardObj(card), onBehalfOf,
      billingDetails?.let { createBillingDetailsObject(it) },
      customer?.let { createCustomerObject(it) }, midLabel, object : TokenCallback() {
          override fun onSuccess(token: Token?) {
            promise.resolve(token?.toWritableMap())
          }

          override fun onError(error: XenditError?) {
            if (error == null){
              promise.reject("BAD_REQUEST", "Authentication Error")
            } else {
              promise.reject(error.errorCode, error.errorMessage)
            }
          }
      })
  }

  @ReactMethod
  fun createAuthentication(tokenId: String, amount: Double, currency: String = "IDR",
                            cardVcn: String? = null, onBehalfOf: String = "", midLabel: String? = null,
                            cardHolder: ReadableMap? = null, promise: Promise) {
    if (!this::xendit.isInitialized) {
      promise.reject(Throwable("Xendit hasn't been initialized. Please call init function"))
      return
    }

    xendit.createAuthentication(tokenId, amount.toString(), currency,
      cardVcn, cardHolder?.let { createCardHolderObject(it) }, onBehalfOf, midLabel,
      object : AuthenticationCallback() {
          override fun onSuccess(authentication: Authentication?) {
              promise.resolve(authentication?.toWritableMap())
          }

          override fun onError(error: XenditError?) {
            if (error == null){
              promise.reject("BAD_REQUEST", "Authentication Error")
            } else {
              promise.reject(error.errorCode, error.errorMessage)
            }
          }
      })
  }

  companion object {
    const val NAME = "XenditPaymentClient"
  }
}
